import 'dart:async';
import 'dart:io';

import 'package:console/console.dart' as cnsl;
import 'package:enough_console/src/stack.dart';

class Console {
  int get numberOfRows => stdout.terminalLines;
  int get numberOfColumns => stdout.terminalColumns;

  final Stack<int> _lineMarks = Stack<int>();
  int _currentLine = 1;
  Progress _progress;

  static const TextStyle _errorStyle =
      TextStyle(foreground: Color.white, background: Color.red);
  static const TextStyle _warningStyle =
      TextStyle(foreground: Color.darkblue, background: Color.lightgray);
  static const TextStyle _successStyle =
      TextStyle(foreground: Color.white, background: Color.green);

  Console({bool reset = false}) {
    if (reset) {
      cnsl.Console.resetAll();
      cnsl.Console.eraseDisplay(1);
      cnsl.Console.restoreCursor();
    }
  }

  void addLineMark() {
    _lineMarks.put(_currentLine);
  }

  void returnToLineMark(
      {bool returnToPreviousLine = true, bool includeCurrentLine = true}) {
    if (includeCurrentLine) {
      cnsl.Console.overwriteLine('');
    }
    var previousLine = _lineMarks.isEmpty ? 1 : _lineMarks.pop();
    if (returnToPreviousLine) {
      var lines = previousLine - _currentLine;

      var gone = 0;
      if (lines < 0) {
        // go up
        while (gone >= lines) {
          cnsl.Console.previousLine();
          cnsl.Console.overwriteLine('');
          gone--;
        }
      } else {
        while (gone <= lines) {
          cnsl.Console.nextLine();
          cnsl.Console.overwriteLine('');
          gone++;
        }
        cnsl.Console.previousLine(lines);
      }
      _currentLine = previousLine;
    }
  }

  void moveToRow(VerticalAlignment vertical, int height) {
    int row;
    if (vertical == VerticalAlignment.top) {
      row = 1;
    } else if (vertical == VerticalAlignment.bottom) {
      row = numberOfRows - height;
    } else if (vertical == VerticalAlignment.center) {
      row = (numberOfRows - height) ~/ 2;
    }
    cnsl.Console.moveCursor(row: row);
    _currentLine = row;
  }

  void nextLine([int count = 1]) {
    cnsl.Console.nextLine(count);
    _currentLine += count;
  }

  void previousLine([int count = 1]) {
    cnsl.Console.previousLine(count);
    _currentLine -= count;
  }

  void clearCurrentLine({String text = ''}) {
    cnsl.Console.overwriteLine(text);
  }

  void clearLine(int row, {String text = ''}) {
    cnsl.Console.saveCursor();
    cnsl.Console.moveCursor(column: 0, row: row);
    cnsl.Console.overwriteLine(text);
    cnsl.Console.restoreCursor();
  }

  void clearLines(int lines, {bool includeCurrentLine = true}) {
    if (includeCurrentLine) {
      cnsl.Console.overwriteLine('');
    }
    var gone = 0;
    if (lines < 0) {
      // go up
      while (gone > lines) {
        cnsl.Console.previousLine();
        cnsl.Console.overwriteLine('');
        gone--;
      }
    } else {
      while (gone < lines) {
        cnsl.Console.nextLine();
        cnsl.Console.overwriteLine('');
        gone++;
      }
      cnsl.Console.previousLine(lines);
    }
    _currentLine += lines;
  }

  void overwriteLine([String text = '']) {
    cnsl.Console.overwriteLine(text);
  }

  void print(String text, [TextStyle style]) {
    var lines = wrap(text, style);
    if (style != null) {
      if (style.background != null) {
        cnsl.Console.setBackgroundColor(style.background.index + 1);
      }
      if (style.foreground != null) {
        cnsl.Console.setTextColor(style.foreground.index + 1);
      }
      if (style.verticalAlignment != VerticalAlignment.none) {
        moveToRow(style.verticalAlignment, lines.length);
      }
    }
    for (var line in lines) {
      cnsl.Console.moveCursor(column: line.column, row: _currentLine);
      stdout.writeln(line.text);
      _currentLine++;
    }
    if (style != null) {
      if (style.background != null) {
        cnsl.Console.resetBackgroundColor();
      }
      if (style.foreground != null) {
        cnsl.Console.resetTextColor();
      }
    }
  }

  void printRaw(String text) {
    stdout.write(text);
    var lines = text.split('\n');
    _currentLine += lines.length;
  }

  void write(String text) {
    cnsl.Console.write(text);
  }

  void setBold([bool bold = true]) {
    cnsl.Console.setBold(bold);
  }

  void printAt(int col, int row, String text) {
    cnsl.Console.saveCursor();
    cnsl.Console.moveCursor(column: col, row: row);
    stdout.write(text);
    cnsl.Console.restoreCursor();
  }

  void list(Iterable elements) {
    for (var i = 0; i < elements.length; i++) {
      print('[${i + 1}] ${elements.elementAt(i)}');
    }
  }

  T parseListChoice<T>(String text, List<T> options,
      {errorCaseMessage = 'Invalid choice: ', bool errorCaseAddText = true}) {
    var index = int.tryParse(text);
    if (index != null && index > 0 && index <= options.length) {
      return options[index - 1];
    } else {
      error(errorCaseMessage + (errorCaseAddText ? text : ''));
      previousLine(2);
      overwriteLine();
      return null;
    }
  }

  void moveCursor({int column, int row}) {
    // if (column == null) {
    //   cnsl.Console.moveCursor(row: row);
    // } else if (row == null) {
    //   cnsl.Console.moveCursor(column: column);
    // } else {
    cnsl.Console.moveCursor(column: column, row: row);
    // }
  }

  void reset() {
    cnsl.Console.resetAll();
    cnsl.Console.eraseDisplay(1);
    moveCursor(column: 1, row: 1);
    cnsl.Console.showCursor();
  }

  List<TextLine> wrap(String text, TextStyle style, [int terminalColumns]) {
    terminalColumns ??= numberOfColumns;
    if (style != null) {
      return wrapWithStyle(text, style, terminalColumns);
    } else {
      return wrapAtCharacterBoundary(text, terminalColumns);
    }
  }

  static List<TextLine> wrapAtCharacterBoundary(String text, int maxColums) {
    var lines = <TextLine>[];
    var breakPos = 0;
    while (breakPos < text.length) {
      breakPos += maxColums;
      String part;
      if (breakPos >= text.length) {
        part = text.substring(breakPos - maxColums);
      } else {
        part = text.substring(breakPos - maxColums, breakPos);
      }
      lines.add(TextLine(part));
    }
    return lines;
  }

  static List<TextLine> wrapAtWordBoundary(String text, int maxColums) {
    var lines = <TextLine>[];
    var breakPos = 0;
    while (breakPos < text.length) {
      var nextBreakPos = breakPos + maxColums;
      if (nextBreakPos >= text.length) {
        lines.add(TextLine(text.substring(breakPos)));
      } else {
        var wrapIndex = text.lastIndexOf(' ', nextBreakPos);
        if (wrapIndex > breakPos) {
          lines.add(TextLine(text.substring(breakPos, wrapIndex)));
          nextBreakPos = wrapIndex + 1;
        } else {
          lines.add(TextLine(text.substring(breakPos, nextBreakPos)));
        }
      }
      breakPos = nextBreakPos;
    }
    return lines;
  }

  static List<TextLine> wrapWithStyle(
      String text, TextStyle style, int terminalColumns) {
    var maxColumns = (style.maxColumnsPercentage * terminalColumns) ~/ 100;
    var paddingLeftText = _pad(style.padding.left);
    var paddingRightText = _pad(style.padding.right);
    maxColumns -= style.padding.horizonal + style.margin.horizonal;
    var lines = (style.wrap == Wrap.character)
        ? wrapAtCharacterBoundary(text, maxColumns)
        : wrapAtWordBoundary(text, maxColumns);
    var maxLineLength = 0;
    for (var line in lines) {
      if (line.length > maxLineLength) {
        maxLineLength = line.length;
      }
    }

    var startColumn;
    if (style.horizontalAlignment == HorizontalAlignment.left ||
        style.horizontalAlignment == HorizontalAlignment.right) {
      if (style.horizontalAlignment == HorizontalAlignment.left) {
        startColumn = style.margin.left + 1;
      } else {
        startColumn = terminalColumns -
            maxLineLength -
            style.padding.horizonal -
            style.margin.right;
      }
      for (var line in lines) {
        line.column = startColumn;
        var pad = _pad(maxLineLength - line.length);
        line.text = paddingLeftText + line.text + paddingRightText + pad;
      }
    } else if (style.horizontalAlignment == HorizontalAlignment.center) {
      startColumn = (terminalColumns -
              maxLineLength -
              style.padding.horizonal -
              style.margin.horizonal) ~/
          2;
      for (var line in lines) {
        line.column = startColumn;
        var pad = _pad((maxLineLength - line.length) ~/ 2);
        line.text = pad + paddingLeftText + line.text + paddingRightText + pad;
      }
    }
    if (style.padding.vertical > 0) {
      var pad = _pad(maxLineLength + style.padding.horizonal);
      for (var i = 0; i < style.padding.top; i++) {
        lines.insert(0, TextLine(pad, startColumn));
      }
      for (var i = 0; i < style.padding.bottom; i++) {
        lines.add(TextLine(pad, startColumn));
      }
    }
    if (style.margin.vertical > 0) {
      var pad = '';
      for (var i = 0; i < style.margin.top; i++) {
        lines.insert(0, TextLine(pad, startColumn));
      }
      for (var i = 0; i < style.margin.bottom; i++) {
        lines.add(TextLine(pad, startColumn));
      }
    }
    return lines;
  }

  static String _pad(int length) {
    if (length == 0) {
      return '';
    }
    var buffer = StringBuffer();
    for (var i = 0; i < length; i++) {
      buffer.write(' ');
    }
    return buffer.toString();
  }

  // color IDs (PowerShell):
  // 1 = red
  // 2 = green
  // 3 = white
  // 4 = blue
  // 5 = darkblue
  // 6 = turquoise
  // 7 = light gray
  void error(String message) {
    cnsl.Console.overwriteLine('');
    print(message, _errorStyle);
  }

  void warn(String message) {
    cnsl.Console.overwriteLine('');
    print(message, _warningStyle);
  }

  void success(String message) {
    cnsl.Console.overwriteLine('');
    print(message, _successStyle);
  }

  Future<String> readInput(String message, {bool isSecret = false}) {
    _currentLine++;
    return cnsl.readInput(message, secret: isSecret);
  }

  void hideCursor() {
    cnsl.Console.hideCursor();
  }

  void showCursor() {
    cnsl.Console.showCursor();
  }

  void moveCursorBack([int columns = 1]) {
    cnsl.Console.moveCursorBack(columns);
  }

  void startProgress() {
    _progress ??= Progress(this);
    _progress.start();
  }

  void stopProgress() {
    if (_progress != null) {
      _progress.stop();
    }
  }
}

enum Color {
  // 1 = red
  // 2 = green
  // 3 = white
  // 4 = blue
  // 5 = darkblue
  // 6 = turquoise
  // 7 = light gray
  red,
  green,
  white,
  blue,
  darkblue,
  turquoise,
  lightgray
}

enum HorizontalAlignment { left, center, right, none }

enum VerticalAlignment { top, center, bottom, none }

enum Wrap { character, word }

class Box {
  static const empty = Box.emptyBox();
  final int left;
  final int right;
  final int top;
  final int bottom;
  int get horizonal => left + right;
  int get vertical => top + bottom;

  const Box(this.left, this.right, this.top, this.bottom);
  const Box.distributed(int common) : this(common, common, common, common);
  const Box.horizonal(int w) : this(w, w, 0, 0);
  const Box.vertical(int h) : this(0, 0, h, h);
  const Box.emptyBox() : this(0, 0, 0, 0);
}

class TextStyle {
  final Color foreground;
  final Color background;
  final HorizontalAlignment horizontalAlignment;
  final VerticalAlignment verticalAlignment;
  final Wrap wrap;
  final int maxColumnsPercentage;
  //final HorizontalAlignment textAlignment;
  final Box padding;
  final Box margin;

  const TextStyle(
      {this.foreground,
      this.background,
      this.horizontalAlignment = HorizontalAlignment.left,
      this.verticalAlignment = VerticalAlignment.none,
      this.wrap = Wrap.character,
      this.maxColumnsPercentage = 100,
      //this.textAlignment = HorizontalAlignment.left,
      this.padding = Box.empty,
      this.margin = Box.empty});
}

class TextLine {
  int column;
  String text;
  int get length => text.length;

  TextLine(this.text, [this.column = 0]);
}

class Progress {
  static const List<String> _indicators = ['|', '/', '-', r'\'];
  int _current;
  bool _isStopRequested = false;
  final Console _console;

  Progress(this._console);

  void start() {
    _console.hideCursor();
    Timer.periodic(Duration(milliseconds: 200), _next);
    _current = 0;
    _write(_indicators[0]);
  }

  void stop() {
    _isStopRequested = true;
    _write(' ');
    _console.showCursor();
  }

  void _write(String indicator) {
    _console.write(indicator);
    _console.moveCursorBack();
  }

  void _next(Timer timer) {
    if (_isStopRequested) {
      timer.cancel();
    } else {
      _current++;
      if (_current >= _indicators.length) {
        _current = 0;
      }
      _write(_indicators[_current]);
    }
  }
}

