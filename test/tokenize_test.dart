import 'package:flutter_test/flutter_test.dart';
import 'package:omarchy_calculator/src/engine/command.dart';
import 'package:omarchy_calculator/src/engine/tokenize.dart';

void testTokenize({
  required List<Command> commands,
  required List<Token> expected,
  String? description,
}) {
  var effectiveDescription = commands.map((e) => e.toString()).join(' ');
  if (description != null) {
    effectiveDescription = '$description: $effectiveDescription';
  }
  test(effectiveDescription, () {
    expect(tokenize(commands), equals(expected));
  });
}

void main() {
  testTokenize(
    commands: const [Command.digit(1), Command.digit(2), Command.digit(3)],
    expected: [NumberToken('123')],
    description: 'Integer number',
  );

  testTokenize(
    commands: const [Command.decimalPoint()],
    expected: const [NumberToken('0')],
    description: 'Only decimal point',
  );
  testTokenize(
    commands: const [
      Command.digit(1),
      Command.digit(2),
      Command.digit(3),
      Command.decimalPoint(),
    ],
    expected: const [NumberToken('123')],
  );
  testTokenize(
    commands: const [
      Command.digit(1),
      Command.digit(2),
      Command.digit(3),
      Command.decimalPoint(),
      Command.digit(4),
      Command.digit(5),
      Command.digit(6),
    ],
    expected: const [NumberToken('123.456')],
    description: 'Decimal number',
  );

  testTokenize(
    commands: const [
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
    ],
    expected: const [NumberToken('123.456789')],
    description: 'Multiple decimal points',
  );

  group('Multiply', () {
    testTokenize(
      commands: const [
        Command.digit(1),
        Command.digit(2),
        Command.operator(OperatorType.multiply),
        Command.digit(4),
        Command.digit(5),
      ],
      expected: const [
        NumberToken('12'),
        OperatorToken(OperatorTokenType.multiply),
        NumberToken('45'),
      ],
      description: 'when surrounded',
    );

    testTokenize(
      commands: const [
        Command.digit(1),
        Command.digit(2),
        Command.operator(OperatorType.multiply),
      ],
      expected: const [
        NumberToken('12'),
        OperatorToken(OperatorTokenType.multiply),
      ],
      description: 'when last',
    );
    testTokenize(
      commands: const [
        Command.operator(OperatorType.multiply),
        Command.digit(1),
        Command.digit(2),
      ],
      expected: const [
        OperatorToken(OperatorTokenType.multiply),
        NumberToken('12'),
      ],
      description: 'when first',
    );
  });

  testTokenize(
    commands: [Command.pi(), Command.euler()],
    expected: const [ConstantToken(Constant.pi), ConstantToken(Constant.euler)],
    description: 'Constants',
  );
  testTokenize(
    commands: const [Command.square(), Command.cosine()],
    expected: const [
      FunctionToken(FunctionTokenType.square),
      FunctionToken(FunctionTokenType.cos),
    ],
    description: 'Functions',
  );

  group('Clear', () {
    testTokenize(
      commands: const [
        Command.digit(1),
        Command.digit(2),
        Command.clearAll(),
        Command.digit(4),
        Command.digit(5),
      ],
      expected: const [NumberToken('45')],
      description: 'when surrounded',
    );

    testTokenize(
      commands: const [Command.digit(1), Command.digit(2), Command.clearAll()],
      expected: const [],
      description: 'when last',
    );
    testTokenize(
      commands: const [Command.clearAll(), Command.digit(1), Command.digit(2)],
      expected: const [NumberToken('12')],
      description: 'when first',
    );
  });

  testTokenize(
    commands: const [
      Command.digit(6),
      Command.digit(0),
      Command.operator(OperatorType.divide),
      Command.digit(2),
      Command.equals(),
      Command.digit(1),
      Command.digit(4),
    ],
    expected: const <Token>[
      NumberToken('60'),
      OperatorToken(OperatorTokenType.divide),
      NumberToken('2'),
      OperatorToken(OperatorTokenType.equals),
      NumberToken('14'),
    ],
    description: 'Equals followed with a number',
  );
}
