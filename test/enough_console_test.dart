import 'package:enough_console/enough_console.dart';
import 'package:test/test.dart';

void main() {
  test('wrapAtWordBoundary without space', () {
    var text = '123456789012345678901234567890';
    var lines = Console.wrapAtWordBoundary(text, 4);
    expect(lines != null, true);
    expect(lines.length, 8);
    expect(lines[0].text, '1234');
    expect(lines[1].text, '5678');
    expect(lines[2].text, '9012');
    expect(lines[3].text, '3456');
    expect(lines[4].text, '7890');
    expect(lines[5].text, '1234');
    expect(lines[6].text, '5678');
    expect(lines[7].text, '90');
  });

  test('wrapAtWordBoundary with space', () {
    var text = '123 45 6789 012 34 5 678 90 1234 56 7890';
    var lines = Console.wrapAtWordBoundary(text, 4);
    expect(lines != null, true);
    expect(lines.length, 10);
    expect(lines[0].text, '123');
    expect(lines[1].text, '45');
    expect(lines[2].text, '6789');
    expect(lines[3].text, '012');
    expect(lines[4].text, '34 5');
    expect(lines[5].text, '678');
    expect(lines[6].text, '90');
    expect(lines[7].text, '1234');
    expect(lines[8].text, '56');
    expect(lines[9].text, '7890');
  });
}
