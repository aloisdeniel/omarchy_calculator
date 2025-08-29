import 'dart:math' as math;

import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omarchy_calculator/src/engine/parse.dart';
import 'package:omarchy_calculator/src/engine/tokenize.dart';

void testParse({
  required List<Token> tokens,
  required Expression expected,
  String? description,
}) {
  final effectiveDescription =
      description ?? tokens.map((e) => e.toString()).join(' ');
  test(effectiveDescription, () {
    expect(parse(tokens), equals(expected));
  });
}

void main() {
  testParse(
    description: 'empty',
    tokens: <Token>[],
    expected: EmptyExpression(),
  );

  testParse(
    tokens: <Token>[NumberToken('123')],
    expected: NumberExpression(Decimal.fromInt(123)),
  );

  testParse(
    tokens: <Token>[NumberToken('123.456')],
    expected: NumberExpression(Decimal.parse('123.456')),
  );

  testParse(
    tokens: <Token>[NumberToken('-123')],
    expected: NumberExpression(Decimal.parse('-123')),
  );

  group('Binary operations', () {
    testParse(
      tokens: <Token>[
        NumberToken('5'),
        OperatorToken(OperatorTokenType.plus),
        NumberToken('3'),
      ],
      expected: BinaryExpression(
        BinaryOperator.add,
        NumberExpression(Decimal.fromInt(5)),
        NumberExpression(Decimal.fromInt(3)),
      ),
    );

    testParse(
      tokens: <Token>[
        NumberToken('10'),
        OperatorToken(OperatorTokenType.minus),
        OperatorToken(OperatorTokenType.minus),
        NumberToken('4'),
      ],
      expected: BinaryExpression(
        BinaryOperator.subtract,
        NumberExpression(Decimal.fromInt(10)),
        NumberExpression(Decimal.fromInt(-4)),
      ),
    );

    testParse(
      tokens: <Token>[
        NumberToken('10'),
        OperatorToken(OperatorTokenType.minus),
        NumberToken('4'),
      ],
      expected: BinaryExpression(
        BinaryOperator.subtract,
        NumberExpression(Decimal.fromInt(10)),
        NumberExpression(Decimal.fromInt(4)),
      ),
    );

    testParse(
      tokens: <Token>[
        NumberToken('6'),
        OperatorToken(OperatorTokenType.multiply),
        NumberToken('7'),
      ],
      expected: BinaryExpression(
        BinaryOperator.multiply,
        NumberExpression(Decimal.fromInt(6)),
        NumberExpression(Decimal.fromInt(7)),
      ),
    );

    testParse(
      tokens: <Token>[
        NumberToken('20'),
        OperatorToken(OperatorTokenType.divide),
        NumberToken('5'),
      ],
      expected: BinaryExpression(
        BinaryOperator.divide,
        NumberExpression(Decimal.fromInt(20)),
        NumberExpression(Decimal.fromInt(5)),
      ),
    );

    testParse(
      tokens: <Token>[
        NumberToken('2'),
        OperatorToken(OperatorTokenType.power),
        NumberToken('3'),
      ],
      expected: BinaryExpression(
        BinaryOperator.power,
        NumberExpression(Decimal.fromInt(2)),
        NumberExpression(Decimal.fromInt(3)),
      ),
    );
  });

  group('Operator precedence', () {
    testParse(
      tokens: <Token>[
        NumberToken('2'),
        OperatorToken(OperatorTokenType.plus),
        NumberToken('3'),
        OperatorToken(OperatorTokenType.multiply),
        NumberToken('4'),
      ],
      expected: BinaryExpression(
        BinaryOperator.add,
        NumberExpression(Decimal.fromInt(2)),
        BinaryExpression(
          BinaryOperator.multiply,
          NumberExpression(Decimal.fromInt(3)),
          NumberExpression(Decimal.fromInt(4)),
        ),
      ),
    );

    testParse(
      tokens: <Token>[
        NumberToken('10'),
        OperatorToken(OperatorTokenType.minus),
        NumberToken('6'),
        OperatorToken(OperatorTokenType.divide),
        NumberToken('2'),
      ],
      expected: BinaryExpression(
        BinaryOperator.subtract,
        NumberExpression(Decimal.fromInt(10)),
        BinaryExpression(
          BinaryOperator.divide,
          NumberExpression(Decimal.fromInt(6)),
          NumberExpression(Decimal.fromInt(2)),
        ),
      ),
    );

    testParse(
      tokens: <Token>[
        NumberToken('2'),
        OperatorToken(OperatorTokenType.multiply),
        NumberToken('3'),
        OperatorToken(OperatorTokenType.power),
        NumberToken('2'),
      ],
      expected: BinaryExpression(
        BinaryOperator.multiply,
        NumberExpression(Decimal.fromInt(2)),
        BinaryExpression(
          BinaryOperator.power,
          NumberExpression(Decimal.fromInt(3)),
          NumberExpression(Decimal.fromInt(2)),
        ),
      ),
    );
  });

  group('Complex expressions', () {
    testParse(
      tokens: <Token>[
        NumberToken('2'),
        OperatorToken(OperatorTokenType.plus),
        NumberToken('3'),
        OperatorToken(OperatorTokenType.multiply),
        NumberToken('4'),
        OperatorToken(OperatorTokenType.minus),
        NumberToken('5'),
      ],
      expected: BinaryExpression(
        BinaryOperator.subtract,
        BinaryExpression(
          BinaryOperator.add,
          NumberExpression(Decimal.fromInt(2)),
          BinaryExpression(
            BinaryOperator.multiply,
            NumberExpression(Decimal.fromInt(3)),
            NumberExpression(Decimal.fromInt(4)),
          ),
        ),
        NumberExpression(Decimal.fromInt(5)),
      ),
    );

    testParse(
      tokens: <Token>[
        NumberToken('2'),
        OperatorToken(OperatorTokenType.multiply),
        ParenthesisToken.open(),
        NumberToken('3'),
        OperatorToken(OperatorTokenType.plus),
        NumberToken('4'),
        ParenthesisToken.close(),
      ],
      expected: BinaryExpression(
        BinaryOperator.multiply,
        NumberExpression(Decimal.fromInt(2)),
        BinaryExpression(
          BinaryOperator.add,
          NumberExpression(Decimal.fromInt(3)),
          NumberExpression(Decimal.fromInt(4)),
        ),
      ),
    );
  });

  group('Constants', () {
    testParse(
      tokens: <Token>[ConstantToken(Constant.pi)],
      expected: ConstantExpression(Constant.pi),
    );

    testParse(
      tokens: <Token>[ConstantToken(Constant.euler)],
      expected: ConstantExpression(Constant.euler),
    );
  });

  testParse(
    tokens: <Token>[
      NumberToken('5'),
      OperatorToken(OperatorTokenType.plus),
      NumberToken('3'),
      OperatorToken(OperatorTokenType.equals),
    ],
    expected: BinaryExpression(
      BinaryOperator.add,
      NumberExpression(Decimal.fromInt(5)),
      NumberExpression(Decimal.fromInt(3)),
    ),
  );

  group('Function expressions', () {
    testParse(
      tokens: <Token>[
        NumberToken('16'),
        OperatorToken(OperatorTokenType.squareRoot),
      ],
      expected: FunctionExpression(
        MathFunction.squareRoot,
        NumberExpression(Decimal.fromInt(16)),
      ),
    );

    testParse(
      tokens: <Token>[NumberToken('30'), FunctionToken(FunctionTokenType.sin)],
      expected: FunctionExpression(
        MathFunction.sin,
        NumberExpression(Decimal.fromInt(30)),
      ),
    );

    testParse(
      tokens: <Token>[NumberToken('60'), FunctionToken(FunctionTokenType.cos)],
      expected: FunctionExpression(
        MathFunction.cos,
        NumberExpression(Decimal.fromInt(60)),
      ),
    );

    testParse(
      tokens: <Token>[NumberToken('45'), FunctionToken(FunctionTokenType.tan)],
      expected: FunctionExpression(
        MathFunction.tan,
        NumberExpression(Decimal.fromInt(45)),
      ),
    );

    testParse(
      tokens: <Token>[
        NumberToken('5'),
        FunctionToken(FunctionTokenType.square),
      ],
      expected: FunctionExpression(
        MathFunction.square,
        NumberExpression(Decimal.fromInt(5)),
      ),
    );

    testParse(
      tokens: <Token>[
        ParenthesisToken.open(),
        NumberToken('30'),
        OperatorToken(OperatorTokenType.plus),
        NumberToken('15'),
        ParenthesisToken.close(),
        FunctionToken(FunctionTokenType.sin),
      ],
      expected: FunctionExpression(
        MathFunction.sin,
        BinaryExpression(
          BinaryOperator.add,
          NumberExpression(Decimal.fromInt(30)),
          NumberExpression(Decimal.fromInt(15)),
        ),
      ),
    );

    testParse(
      tokens: <Token>[
        ParenthesisToken.open(),
        NumberToken('60'),
        OperatorToken(OperatorTokenType.divide),
        NumberToken('2'),
        ParenthesisToken.close(),
        FunctionToken(FunctionTokenType.cos),
      ],
      expected: FunctionExpression(
        MathFunction.cos,
        BinaryExpression(
          BinaryOperator.divide,
          NumberExpression(Decimal.fromInt(60)),
          NumberExpression(Decimal.fromInt(2)),
        ),
      ),
    );

    testParse(
      tokens: <Token>[
        NumberToken('60'),
        OperatorToken(OperatorTokenType.divide),
        NumberToken('2'),
        OperatorToken(OperatorTokenType.equals),
        NumberToken('14.2'),
      ],
      expected: NumberExpression(Decimal.parse('14.2')),
    );
    testParse(
      tokens: <Token>[
        NumberToken('3'),
        FunctionToken(FunctionTokenType.square),
        OperatorToken(OperatorTokenType.divide),
        NumberToken('2'),
        OperatorToken(OperatorTokenType.equals),
        OperatorToken(OperatorTokenType.plus),
        NumberToken('3'),
      ],
      expected: BinaryExpression(
        BinaryOperator.add,
        PreviousResultExpression(
          BinaryExpression(
            BinaryOperator.divide,
            FunctionExpression(
              MathFunction.square,
              NumberExpression(Decimal.fromInt(3)),
            ),
            NumberExpression(Decimal.fromInt(2)),
          ),
        ),
        NumberExpression(Decimal.fromInt(3)),
      ),
    );

    testParse(
      tokens: <Token>[
        NumberToken('56'),
        OperatorToken(OperatorTokenType.minus),
        NumberToken('2'),
        OperatorToken(OperatorTokenType.equals),
        OperatorToken(OperatorTokenType.plus),
        NumberToken('2'),
      ],
      expected: BinaryExpression(
        BinaryOperator.add,
        PreviousResultExpression(
          BinaryExpression(
            BinaryOperator.subtract,
            NumberExpression(Decimal.fromInt(56)),
            NumberExpression(Decimal.fromInt(2)),
          ),
        ),
        NumberExpression(Decimal.fromInt(2)),
      ),
    );

    testParse(
      tokens: <Token>[
        NumberToken('56'),
        OperatorToken(OperatorTokenType.minus),
        NumberToken('2'),
        OperatorToken(OperatorTokenType.equals),
        OperatorToken(OperatorTokenType.plus),
        NumberToken('3'),
        OperatorToken(OperatorTokenType.equals),
        OperatorToken(OperatorTokenType.multiply),
        NumberToken('8'),
      ],
      expected: BinaryExpression(
        BinaryOperator.multiply,
        PreviousResultExpression(
          BinaryExpression(
            BinaryOperator.add,
            PreviousResultExpression(
              BinaryExpression(
                BinaryOperator.subtract,
                NumberExpression(Decimal.fromInt(56)),
                NumberExpression(Decimal.fromInt(2)),
              ),
            ),
            NumberExpression(Decimal.fromInt(3)),
          ),
        ),
        NumberExpression(Decimal.fromInt(8)),
      ),
    );

    testParse(
      tokens: <Token>[
        NumberToken('56'),
        OperatorToken(OperatorTokenType.minus),
        NumberToken('2'),
        OperatorToken(OperatorTokenType.equals),
        OperatorToken(OperatorTokenType.plus),
        NumberToken('3'),
        OperatorToken(OperatorTokenType.equals),
        OperatorToken(OperatorTokenType.multiply),
        NumberToken('8'),
        OperatorToken(OperatorTokenType.equals),
        OperatorToken(OperatorTokenType.minus),
        NumberToken('5'),
      ],
      expected: BinaryExpression(
        BinaryOperator.subtract,
        PreviousResultExpression(
          BinaryExpression(
            BinaryOperator.multiply,
            PreviousResultExpression(
              BinaryExpression(
                BinaryOperator.add,
                PreviousResultExpression(
                  BinaryExpression(
                    BinaryOperator.subtract,
                    NumberExpression(Decimal.fromInt(56)),
                    NumberExpression(Decimal.fromInt(2)),
                  ),
                ),
                NumberExpression(Decimal.fromInt(3)),
              ),
            ),
            NumberExpression(Decimal.fromInt(8)),
          ),
        ),
        NumberExpression(Decimal.fromInt(5)),
      ),
    );
  });
}
