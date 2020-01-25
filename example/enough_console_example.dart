import 'package:enough_console/enough_console.dart';

void main() async {
  var console = Console(reset: true);
  console.print(
      '1 hello - rows=${console.numberOfRows}, cols=${console.numberOfColumns}');
  console.print('2 oh my');
  await console.readInput('next (1)');
  console.returnToLineMark();
  console.success('this should stay');
  console.addLineMark();
  console.print(
      '12456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890 90ABC DEFGH IJKLMNO PQRST UVWX YZ a bcd efg hijklmno pqrstuv wxyz 123 456 789 0_->>> _ABC_ _DEF_ _GHJ_ _KLM_ _OPQ_ _RST_ _UVW_ _XYZ_ _abc_ _def_ _ghj_ _klm_ _nop_ _qrs_ _tuv_ _wxy_ ____z_____',
      TextStyle(
          foreground: Color.green,
          background: Color.white,
          padding: Box.distributed(1),
          margin: Box.horizonal(3),
          wrap: Wrap.word));
  await console.readInput('next (2)');
  console.returnToLineMark();
  console.previousLine();
  console.print(
      'top left',
      TextStyle(
          foreground: Color.white,
          background: Color.darkblue,
          horizontalAlignment: HorizontalAlignment.left,
          verticalAlignment: VerticalAlignment.top));
  console.print(
      'top right',
      TextStyle(
          foreground: Color.darkblue,
          background: Color.white,
          horizontalAlignment: HorizontalAlignment.right,
          verticalAlignment: VerticalAlignment.top));
  console.print(
      'bottom left',
      TextStyle(
          foreground: Color.white,
          background: Color.red,
          horizontalAlignment: HorizontalAlignment.left,
          verticalAlignment: VerticalAlignment.bottom));
  console.print(
      'CENTER',
      TextStyle(
          foreground: Color.white,
          background: Color.red,
          horizontalAlignment: HorizontalAlignment.center,
          verticalAlignment: VerticalAlignment.center));
  console.print(
      'bottom right',
      TextStyle(
          foreground: Color.green,
          background: Color.white,
          horizontalAlignment: HorizontalAlignment.right,
          verticalAlignment: VerticalAlignment.bottom));

  //await console.readInput('done');
}

