import 'package:flutter_test/flutter_test.dart';
import 'package:omarchy_calculator/src/engine/command.dart';
import 'package:omarchy_calculator/src/engine/tokenize.dart';

void testTokenize(
  String description, {
  required List<Command> commands,
  required List<Token> expected,
}) {
  test(description, () {
    print('commands:${commands.join(' ')}');
    print('expected:${expected.join(' ')}');
    expect(tokenize(commands), equals(expected));
  });
}

void main() {
  testTokenize(
    'Integer number',
    commands: const [Command.digit(1), Command.digit(2), Command.digit(3)],
    expected: [NumberToken('123')],
  );

  test('Only decimal point', () {
    const commands = [Command.decimalPoint()];
    const expected = [NumberToken('0')];
    expect(tokenize(commands), equals(expected));
  });
  test('Uncompleted decimal number', () {
    const commands = [
      Command.digit(1),
      Command.digit(2),
      Command.digit(3),
      Command.decimalPoint(),
    ];
    const expected = [NumberToken('123')];
    expect(tokenize(commands), equals(expected));
  });
  test('Decimal number', () {
    const commands = [
      Command.digit(1),
      Command.digit(2),
      Command.digit(3),
      Command.decimalPoint(),
      Command.digit(4),
      Command.digit(5),
      Command.digit(6),
    ];
    const expected = [NumberToken('123.456')];
    expect(tokenize(commands), equals(expected));
  });

  test('Multiple decimal points', () {
    const commands = [
      Command.digit(1),
      Command.digit(2),
      Command.digit(3),
      Command.decimalPoint(),
      Command.digit(4),
      Command.digit(5),
      Command.digit(6),
      Command.decimalPoint(),
      Command.digit(7),
      Command.digit(8),
      Command.digit(9),
    ];
    const expected = [NumberToken('123.456789')];
    expect(tokenize(commands), equals(expected));
  });

  group('Multiply', () {
    test('when surrounded', () {
      const commands = [
        Command.digit(1),
        Command.digit(2),
        Command.operator(OperatorType.multiply),
        Command.digit(4),
        Command.digit(5),
      ];
      const expected = [
        NumberToken('12'),
        OperatorToken(OperatorTokenType.multiply),
        NumberToken('45'),
      ];
      expect(tokenize(commands), equals(expected));
    });

    test('when last', () {
      const commands = [
        Command.digit(1),
        Command.digit(2),
        Command.operator(OperatorType.multiply),
      ];
      const expected = [
        NumberToken('12'),
        OperatorToken(OperatorTokenType.multiply),
      ];
      expect(tokenize(commands), equals(expected));
    });
    test('when first', () {
      const commands = [
        Command.operator(OperatorType.multiply),
        Command.digit(1),
        Command.digit(2),
      ];
      const expected = [
        OperatorToken(OperatorTokenType.multiply),
        NumberToken('12'),
      ];
      expect(tokenize(commands), equals(expected));
    });
  });

  test('Constants', () {
    const commands = [Command.pi(), Command.euler()];
    const expected = [
      ConstantToken(Constant.pi),
      ConstantToken(Constant.euler),
    ];
    expect(tokenize(commands), equals(expected));
  });
  test('Functions', () {
    const commands = [Command.square(), Command.cosine()];
    const expected = [
      FunctionToken(FunctionTokenType.square),
      FunctionToken(FunctionTokenType.cos),
    ];
    expect(tokenize(commands), equals(expected));
  });

  group('Clear', () {
    test('when surrounded', () {
      const commands = [
        Command.digit(1),
        Command.digit(2),
        Command.clearAll(),
        Command.digit(4),
        Command.digit(5),
      ];
      const expected = [NumberToken('45')];
      expect(tokenize(commands), equals(expected));
    });

    test('when last', () {
      const commands = [Command.digit(1), Command.digit(2), Command.clearAll()];
      const expected = [];
      expect(tokenize(commands), equals(expected));
    });
    test('when first', () {
      const commands = [Command.clearAll(), Command.digit(1), Command.digit(2)];
      const expected = [NumberToken('12')];
      expect(tokenize(commands), equals(expected));
    });
  });

  test('Equals followed with a number', () {
    const commands = [
      Command.digit(6),
      Command.digit(0),
      Command.operator(OperatorType.divide),
      Command.digit(2),
      Command.equals(),
      Command.digit(1),
      Command.digit(4),
    ];
    const expected = <Token>[
      NumberToken('60'),
      OperatorToken(OperatorTokenType.divide),
      NumberToken('2'),
      OperatorToken(OperatorTokenType.equals),
      NumberToken('14'),
    ];
    expect(tokenize(commands), equals(expected));
  });
}
