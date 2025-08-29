import 'package:flutter_test/flutter_test.dart';
import 'package:omarchy_calculator/src/engine/input.dart';
import 'package:omarchy_calculator/src/engine/tokenize.dart';

void main() {
  test('60 / 2 -> 2', () {
    const tokens = [
      NumberToken('60'),
      OperatorToken(OperatorTokenType.divide),
      NumberToken('2'),
    ];
    const expected = '2';
    expect(input(tokens), equals(expected));
  });
  test('60 / 2 = 14 -> 14', () {
    const tokens = [
      NumberToken('60'),
      OperatorToken(OperatorTokenType.divide),
      NumberToken('2'),
      OperatorToken(OperatorTokenType.equals),
      NumberToken('14'),
    ];
    const expected = '14';
    expect(input(tokens), equals(expected));
  });
}
