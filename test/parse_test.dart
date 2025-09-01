import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omarchy_calculator/src/engine/parse.dart';
import 'package:omarchy_calculator/src/engine/tokenize.dart';

void testParse({
  required List<Token> tokens,
  required Expression expected,
  String? description,
}) {
  var effectiveDescription = tokens.map((e) => e.toString()).join(' ');

  if (description != null) {
    effectiveDescription = '$description: $effectiveDescription';
  }
  test(effectiveDescription, () {
    expect(parse(tokens), equals(expected));
  });
}

void main() {
  testParse(
    tokens: <Token>[],
    expected: EmptyExpression(),
    description: 'empty',
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
        ParenthesisGroupExpression(
          BinaryExpression(
            BinaryOperator.add,
            NumberExpression(Decimal.fromInt(3)),
            NumberExpression(Decimal.fromInt(4)),
          ),
          true,
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

  group('More basic arithmetic operations', () {
    testParse(
      tokens: <Token>[
        NumberToken('0'),
        OperatorToken(OperatorTokenType.plus),
        NumberToken('0'),
      ],
      expected: BinaryExpression(
        BinaryOperator.add,
        NumberExpression(Decimal.fromInt(0)),
        NumberExpression(Decimal.fromInt(0)),
      ),
    );

    testParse(
      tokens: <Token>[
        NumberToken('999999'),
        OperatorToken(OperatorTokenType.plus),
        NumberToken('1'),
      ],
      expected: BinaryExpression(
        BinaryOperator.add,
        NumberExpression(Decimal.fromInt(999999)),
        NumberExpression(Decimal.fromInt(1)),
      ),
    );

    testParse(
      tokens: <Token>[
        NumberToken('10.5'),
        OperatorToken(OperatorTokenType.minus),
        NumberToken('3.2'),
      ],
      expected: BinaryExpression(
        BinaryOperator.subtract,
        NumberExpression(Decimal.parse('10.5')),
        NumberExpression(Decimal.parse('3.2')),
      ),
    );

    testParse(
      tokens: <Token>[
        NumberToken('100'),
        OperatorToken(OperatorTokenType.multiply),
        NumberToken('0'),
      ],
      expected: BinaryExpression(
        BinaryOperator.multiply,
        NumberExpression(Decimal.fromInt(100)),
        NumberExpression(Decimal.fromInt(0)),
      ),
    );

    testParse(
      tokens: <Token>[
        NumberToken('22.5'),
        OperatorToken(OperatorTokenType.divide),
        NumberToken('4.5'),
      ],
      expected: BinaryExpression(
        BinaryOperator.divide,
        NumberExpression(Decimal.parse('22.5')),
        NumberExpression(Decimal.parse('4.5')),
      ),
    );

    testParse(
      tokens: <Token>[
        NumberToken('-5'),
        OperatorToken(OperatorTokenType.multiply),
        NumberToken('3'),
      ],
      expected: BinaryExpression(
        BinaryOperator.multiply,
        NumberExpression(Decimal.parse('-5')),
        NumberExpression(Decimal.fromInt(3)),
      ),
    );

    testParse(
      tokens: <Token>[
        NumberToken('-8'),
        OperatorToken(OperatorTokenType.multiply),
        NumberToken('-2'),
      ],
      expected: BinaryExpression(
        BinaryOperator.multiply,
        NumberExpression(Decimal.parse('-8')),
        NumberExpression(Decimal.parse('-2')),
      ),
    );
  });

  group('Extended operator precedence', () {
    testParse(
      tokens: <Token>[
        NumberToken('3'),
        OperatorToken(OperatorTokenType.multiply),
        NumberToken('4'),
        OperatorToken(OperatorTokenType.plus),
        NumberToken('5'),
      ],
      expected: BinaryExpression(
        BinaryOperator.add,
        BinaryExpression(
          BinaryOperator.multiply,
          NumberExpression(Decimal.fromInt(3)),
          NumberExpression(Decimal.fromInt(4)),
        ),
        NumberExpression(Decimal.fromInt(5)),
      ),
    );

    testParse(
      tokens: <Token>[
        NumberToken('20'),
        OperatorToken(OperatorTokenType.minus),
        NumberToken('12'),
        OperatorToken(OperatorTokenType.divide),
        NumberToken('3'),
      ],
      expected: BinaryExpression(
        BinaryOperator.subtract,
        NumberExpression(Decimal.fromInt(20)),
        BinaryExpression(
          BinaryOperator.divide,
          NumberExpression(Decimal.fromInt(12)),
          NumberExpression(Decimal.fromInt(3)),
        ),
      ),
    );

    testParse(
      tokens: <Token>[
        NumberToken('2'),
        OperatorToken(OperatorTokenType.plus),
        NumberToken('3'),
        OperatorToken(OperatorTokenType.power),
        NumberToken('2'),
        OperatorToken(OperatorTokenType.multiply),
        NumberToken('4'),
      ],
      expected: BinaryExpression(
        BinaryOperator.add,
        NumberExpression(Decimal.fromInt(2)),
        BinaryExpression(
          BinaryOperator.multiply,
          BinaryExpression(
            BinaryOperator.power,
            NumberExpression(Decimal.fromInt(3)),
            NumberExpression(Decimal.fromInt(2)),
          ),
          NumberExpression(Decimal.fromInt(4)),
        ),
      ),
    );

    testParse(
      tokens: <Token>[
        NumberToken('2'),
        OperatorToken(OperatorTokenType.power),
        NumberToken('3'),
        OperatorToken(OperatorTokenType.power),
        NumberToken('2'),
      ],
      expected: BinaryExpression(
        BinaryOperator.power,
        NumberExpression(Decimal.fromInt(2)),
        BinaryExpression(
          BinaryOperator.power,
          NumberExpression(Decimal.fromInt(3)),
          NumberExpression(Decimal.fromInt(2)),
        ),
      ),
    );

    testParse(
      tokens: <Token>[
        NumberToken('1'),
        OperatorToken(OperatorTokenType.plus),
        NumberToken('2'),
        OperatorToken(OperatorTokenType.multiply),
        NumberToken('3'),
        OperatorToken(OperatorTokenType.power),
        NumberToken('2'),
        OperatorToken(OperatorTokenType.minus),
        NumberToken('4'),
        OperatorToken(OperatorTokenType.divide),
        NumberToken('2'),
      ],
      expected: BinaryExpression(
        BinaryOperator.subtract,
        BinaryExpression(
          BinaryOperator.add,
          NumberExpression(Decimal.fromInt(1)),
          BinaryExpression(
            BinaryOperator.multiply,
            NumberExpression(Decimal.fromInt(2)),
            BinaryExpression(
              BinaryOperator.power,
              NumberExpression(Decimal.fromInt(3)),
              NumberExpression(Decimal.fromInt(2)),
            ),
          ),
        ),
        BinaryExpression(
          BinaryOperator.divide,
          NumberExpression(Decimal.fromInt(4)),
          NumberExpression(Decimal.fromInt(2)),
        ),
      ),
    );
  });

  group('Extended parentheses and nested expressions', () {
    testParse(
      tokens: <Token>[
        ParenthesisToken.open(),
        NumberToken('2'),
        OperatorToken(OperatorTokenType.plus),
        NumberToken('3'),
        ParenthesisToken.close(),
        OperatorToken(OperatorTokenType.multiply),
        NumberToken('4'),
      ],
      expected: BinaryExpression(
        BinaryOperator.multiply,
        ParenthesisGroupExpression(
          BinaryExpression(
            BinaryOperator.add,
            NumberExpression(Decimal.fromInt(2)),
            NumberExpression(Decimal.fromInt(3)),
          ),
          true,
        ),
        NumberExpression(Decimal.fromInt(4)),
      ),
    );

    testParse(
      tokens: <Token>[
        ParenthesisToken.open(),
        ParenthesisToken.open(),
        NumberToken('2'),
        OperatorToken(OperatorTokenType.plus),
        NumberToken('3'),
        ParenthesisToken.close(),
        OperatorToken(OperatorTokenType.multiply),
        NumberToken('4'),
        ParenthesisToken.close(),
        OperatorToken(OperatorTokenType.minus),
        NumberToken('1'),
      ],
      expected: BinaryExpression(
        BinaryOperator.subtract,
        ParenthesisGroupExpression(
          BinaryExpression(
            BinaryOperator.multiply,
            ParenthesisGroupExpression(
              BinaryExpression(
                BinaryOperator.add,
                NumberExpression(Decimal.fromInt(2)),
                NumberExpression(Decimal.fromInt(3)),
              ),
              true,
            ),
            NumberExpression(Decimal.fromInt(4)),
          ),
          true,
        ),
        NumberExpression(Decimal.fromInt(1)),
      ),
    );

    testParse(
      tokens: <Token>[
        ParenthesisToken.open(),
        NumberToken('5'),
        OperatorToken(OperatorTokenType.minus),
        NumberToken('2'),
        ParenthesisToken.close(),
        OperatorToken(OperatorTokenType.multiply),
        ParenthesisToken.open(),
        NumberToken('3'),
        OperatorToken(OperatorTokenType.plus),
        NumberToken('1'),
        ParenthesisToken.close(),
      ],
      expected: BinaryExpression(
        BinaryOperator.multiply,
        ParenthesisGroupExpression(
          BinaryExpression(
            BinaryOperator.subtract,
            NumberExpression(Decimal.fromInt(5)),
            NumberExpression(Decimal.fromInt(2)),
          ),
          true,
        ),
        ParenthesisGroupExpression(
          BinaryExpression(
            BinaryOperator.add,
            NumberExpression(Decimal.fromInt(3)),
            NumberExpression(Decimal.fromInt(1)),
          ),
          true,
        ),
      ),
    );

    testParse(
      tokens: <Token>[
        ParenthesisToken.open(),
        NumberToken('2'),
        OperatorToken(OperatorTokenType.plus),
        NumberToken('3'),
        ParenthesisToken.close(),
        OperatorToken(OperatorTokenType.power),
        NumberToken('2'),
      ],
      expected: BinaryExpression(
        BinaryOperator.power,
        ParenthesisGroupExpression(
          BinaryExpression(
            BinaryOperator.add,
            NumberExpression(Decimal.fromInt(2)),
            NumberExpression(Decimal.fromInt(3)),
          ),
          true,
        ),
        NumberExpression(Decimal.fromInt(2)),
      ),
    );
  });

  group('Decimal precision and edge cases', () {
    testParse(
      tokens: <Token>[NumberToken('0.00001')],
      expected: NumberExpression(Decimal.parse('0.00001')),
    );

    testParse(
      tokens: <Token>[NumberToken('3.141592653589793')],
      expected: NumberExpression(Decimal.parse('3.141592653589793')),
    );

    testParse(
      tokens: <Token>[
        NumberToken('0.1'),
        OperatorToken(OperatorTokenType.plus),
        NumberToken('0.2'),
      ],
      expected: BinaryExpression(
        BinaryOperator.add,
        NumberExpression(Decimal.parse('0.1')),
        NumberExpression(Decimal.parse('0.2')),
      ),
    );

    testParse(
      tokens: <Token>[NumberToken('-123.456')],
      expected: NumberExpression(Decimal.parse('-123.456')),
    );

    testParse(
      tokens: <Token>[
        NumberToken('0.0'),
        OperatorToken(OperatorTokenType.plus),
        NumberToken('0'),
      ],
      expected: BinaryExpression(
        BinaryOperator.add,
        NumberExpression(Decimal.parse('0.0')),
        NumberExpression(Decimal.fromInt(0)),
      ),
    );
  });

  group('Constants with operations', () {
    testParse(
      tokens: <Token>[
        NumberToken('2'),
        OperatorToken(OperatorTokenType.multiply),
        ConstantToken(Constant.pi),
      ],
      expected: BinaryExpression(
        BinaryOperator.multiply,
        NumberExpression(Decimal.fromInt(2)),
        ConstantExpression(Constant.pi),
      ),
    );

    testParse(
      tokens: <Token>[
        ConstantToken(Constant.euler),
        OperatorToken(OperatorTokenType.power),
        NumberToken('2'),
      ],
      expected: BinaryExpression(
        BinaryOperator.power,
        ConstantExpression(Constant.euler),
        NumberExpression(Decimal.fromInt(2)),
      ),
    );

    testParse(
      tokens: <Token>[
        ParenthesisToken.open(),
        ConstantToken(Constant.pi),
        OperatorToken(OperatorTokenType.plus),
        ConstantToken(Constant.euler),
        ParenthesisToken.close(),
        OperatorToken(OperatorTokenType.divide),
        NumberToken('2'),
      ],
      expected: BinaryExpression(
        BinaryOperator.divide,
        ParenthesisGroupExpression(
          BinaryExpression(
            BinaryOperator.add,
            ConstantExpression(Constant.pi),
            ConstantExpression(Constant.euler),
          ),
          true,
        ),
        NumberExpression(Decimal.fromInt(2)),
      ),
    );
  });

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
        NumberToken('25.0'),
        OperatorToken(OperatorTokenType.squareRoot),
      ],
      expected: FunctionExpression(
        MathFunction.squareRoot,
        NumberExpression(Decimal.parse('25.0')),
      ),
    );

    testParse(
      tokens: <Token>[
        NumberToken('50'),
        OperatorToken(OperatorTokenType.percent),
      ],
      expected: FunctionExpression(
        MathFunction.percent,
        NumberExpression(Decimal.fromInt(50)),
      ),
    );

    testParse(
      tokens: <Token>[NumberToken('0'), FunctionToken(FunctionTokenType.sin)],
      expected: FunctionExpression(
        MathFunction.sin,
        NumberExpression(Decimal.fromInt(0)),
      ),
    );

    testParse(
      tokens: <Token>[NumberToken('90'), FunctionToken(FunctionTokenType.cos)],
      expected: FunctionExpression(
        MathFunction.cos,
        NumberExpression(Decimal.fromInt(90)),
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
        NumberToken('-3'),
        FunctionToken(FunctionTokenType.square),
      ],
      expected: FunctionExpression(
        MathFunction.square,
        NumberExpression(Decimal.parse('-3')),
      ),
    );

    testParse(
      tokens: <Token>[
        NumberToken('10000'),
        OperatorToken(OperatorTokenType.squareRoot),
      ],
      expected: FunctionExpression(
        MathFunction.squareRoot,
        NumberExpression(Decimal.fromInt(10000)),
      ),
    );

    testParse(
      tokens: <Token>[
        ConstantToken(Constant.pi),
        FunctionToken(FunctionTokenType.sin),
      ],
      expected: FunctionExpression(
        MathFunction.sin,
        ConstantExpression(Constant.pi),
      ),
    );

    testParse(
      tokens: <Token>[
        NumberToken('25'),
        OperatorToken(OperatorTokenType.squareRoot),
        FunctionToken(FunctionTokenType.square),
      ],
      expected: FunctionExpression(
        MathFunction.square,
        FunctionExpression(
          MathFunction.squareRoot,
          NumberExpression(Decimal.fromInt(25)),
        ),
      ),
    );

    testParse(
      tokens: <Token>[
        NumberToken('30'),
        FunctionToken(FunctionTokenType.sin),
        OperatorToken(OperatorTokenType.plus),
        NumberToken('60'),
        FunctionToken(FunctionTokenType.cos),
      ],
      expected: BinaryExpression(
        BinaryOperator.add,
        FunctionExpression(
          MathFunction.sin,
          NumberExpression(Decimal.fromInt(30)),
        ),
        FunctionExpression(
          MathFunction.cos,
          NumberExpression(Decimal.fromInt(60)),
        ),
      ),
    );

    testParse(
      tokens: <Token>[
        NumberToken('2'),
        OperatorToken(OperatorTokenType.multiply),
        NumberToken('5'),
        FunctionToken(FunctionTokenType.square),
      ],
      expected: BinaryExpression(
        BinaryOperator.multiply,
        NumberExpression(Decimal.fromInt(2)),
        FunctionExpression(
          MathFunction.square,
          NumberExpression(Decimal.fromInt(5)),
        ),
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
        ParenthesisGroupExpression(
          BinaryExpression(
            BinaryOperator.add,
            NumberExpression(Decimal.fromInt(30)),
            NumberExpression(Decimal.fromInt(15)),
          ),
          true,
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
        ParenthesisGroupExpression(
          BinaryExpression(
            BinaryOperator.divide,
            NumberExpression(Decimal.fromInt(60)),
            NumberExpression(Decimal.fromInt(2)),
          ),
          true,
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

  group('Unary expressions and negative numbers', () {
    testParse(
      tokens: <Token>[
        OperatorToken(OperatorTokenType.minus),
        ParenthesisToken.open(),
        NumberToken('5'),
        OperatorToken(OperatorTokenType.plus),
        NumberToken('3'),
        ParenthesisToken.close(),
      ],
      expected: UnaryExpression(
        UnaryOperator.negate,
        ParenthesisGroupExpression(
          BinaryExpression(
            BinaryOperator.add,
            NumberExpression(Decimal.fromInt(5)),
            NumberExpression(Decimal.fromInt(3)),
          ),
          true,
        ),
      ),
    );

    testParse(
      tokens: <Token>[
        OperatorToken(OperatorTokenType.minus),
        OperatorToken(OperatorTokenType.minus),
        NumberToken('7'),
      ],
      expected: UnaryExpression(
        UnaryOperator.negate,
        NumberExpression(Decimal.parse('-7')),
      ),
    );

    testParse(
      tokens: <Token>[
        OperatorToken(OperatorTokenType.minus),
        NumberToken('4'),
        OperatorToken(OperatorTokenType.multiply),
        NumberToken('3'),
      ],
      expected: BinaryExpression(
        BinaryOperator.multiply,
        NumberExpression(Decimal.parse('-4')),
        NumberExpression(Decimal.fromInt(3)),
      ),
    );

    testParse(
      tokens: <Token>[
        OperatorToken(OperatorTokenType.minus),
        NumberToken('9'),
        OperatorToken(OperatorTokenType.squareRoot),
      ],
      expected: NumberExpression(Decimal.parse('-9')),
    );
  });

  group('Complex real-world calculator scenarios', () {
    testParse(
      tokens: <Token>[
        NumberToken('200'),
        OperatorToken(OperatorTokenType.multiply),
        NumberToken('15'),
        OperatorToken(OperatorTokenType.percent),
      ],
      expected: BinaryExpression(
        BinaryOperator.multiply,
        NumberExpression(Decimal.fromInt(200)),
        FunctionExpression(
          MathFunction.percent,
          NumberExpression(Decimal.fromInt(15)),
        ),
      ),
    );

    testParse(
      tokens: <Token>[
        NumberToken('1000'),
        OperatorToken(OperatorTokenType.multiply),
        ParenthesisToken.open(),
        NumberToken('1'),
        OperatorToken(OperatorTokenType.plus),
        NumberToken('0.05'),
        ParenthesisToken.close(),
        OperatorToken(OperatorTokenType.power),
        NumberToken('10'),
      ],
      expected: BinaryExpression(
        BinaryOperator.multiply,
        NumberExpression(Decimal.fromInt(1000)),
        BinaryExpression(
          BinaryOperator.power,
          ParenthesisGroupExpression(
            BinaryExpression(
              BinaryOperator.add,
              NumberExpression(Decimal.fromInt(1)),
              NumberExpression(Decimal.parse('0.05')),
            ),
            true,
          ),
          NumberExpression(Decimal.fromInt(10)),
        ),
      ),
    );

    testParse(
      tokens: <Token>[
        ConstantToken(Constant.pi),
        OperatorToken(OperatorTokenType.multiply),
        NumberToken('5'),
        FunctionToken(FunctionTokenType.square),
      ],
      expected: BinaryExpression(
        BinaryOperator.multiply,
        ConstantExpression(Constant.pi),
        FunctionExpression(
          MathFunction.square,
          NumberExpression(Decimal.fromInt(5)),
        ),
      ),
    );

    testParse(
      tokens: <Token>[
        OperatorToken(OperatorTokenType.minus),
        NumberToken('4'),
        OperatorToken(OperatorTokenType.multiply),
        NumberToken('2'),
        OperatorToken(OperatorTokenType.multiply),
        NumberToken('3'),
      ],
      expected: BinaryExpression(
        BinaryOperator.multiply,
        BinaryExpression(
          BinaryOperator.multiply,
          NumberExpression(Decimal.parse('-4')),
          NumberExpression(Decimal.fromInt(2)),
        ),
        NumberExpression(Decimal.fromInt(3)),
      ),
    );

    testParse(
      tokens: <Token>[
        NumberToken('0.5'),
        OperatorToken(OperatorTokenType.multiply),
        NumberToken('10'),
        OperatorToken(OperatorTokenType.multiply),
        NumberToken('5'),
        FunctionToken(FunctionTokenType.square),
      ],
      expected: BinaryExpression(
        BinaryOperator.multiply,
        BinaryExpression(
          BinaryOperator.multiply,
          NumberExpression(Decimal.parse('0.5')),
          NumberExpression(Decimal.fromInt(10)),
        ),
        FunctionExpression(
          MathFunction.square,
          NumberExpression(Decimal.fromInt(5)),
        ),
      ),
    );

    testParse(
      tokens: <Token>[
        ParenthesisToken.open(),
        NumberToken('32'),
        OperatorToken(OperatorTokenType.minus),
        NumberToken('32'),
        ParenthesisToken.close(),
        OperatorToken(OperatorTokenType.multiply),
        NumberToken('5'),
        OperatorToken(OperatorTokenType.divide),
        NumberToken('9'),
      ],
      expected: BinaryExpression(
        BinaryOperator.divide,
        BinaryExpression(
          BinaryOperator.multiply,
          ParenthesisGroupExpression(
            BinaryExpression(
              BinaryOperator.subtract,
              NumberExpression(Decimal.fromInt(32)),
              NumberExpression(Decimal.fromInt(32)),
            ),
            true,
          ),
          NumberExpression(Decimal.fromInt(5)),
        ),
        NumberExpression(Decimal.fromInt(9)),
      ),
    );

    testParse(
      tokens: <Token>[
        NumberToken('10'),
        OperatorToken(OperatorTokenType.power),
        ParenthesisToken.open(),
        NumberToken('2'),
        OperatorToken(OperatorTokenType.plus),
        NumberToken('3'),
        OperatorToken(OperatorTokenType.multiply),
        NumberToken('0.5'),
        ParenthesisToken.close(),
      ],
      expected: BinaryExpression(
        BinaryOperator.power,
        NumberExpression(Decimal.fromInt(10)),
        ParenthesisGroupExpression(
          BinaryExpression(
            BinaryOperator.add,
            NumberExpression(Decimal.fromInt(2)),
            BinaryExpression(
              BinaryOperator.multiply,
              NumberExpression(Decimal.fromInt(3)),
              NumberExpression(Decimal.parse('0.5')),
            ),
          ),
          true,
        ),
      ),
    );

    testParse(
      tokens: <Token>[
        NumberToken('30'),
        FunctionToken(FunctionTokenType.sin),
        FunctionToken(FunctionTokenType.square),
        OperatorToken(OperatorTokenType.plus),
        NumberToken('30'),
        FunctionToken(FunctionTokenType.cos),
        FunctionToken(FunctionTokenType.square),
      ],
      expected: BinaryExpression(
        BinaryOperator.add,
        FunctionExpression(
          MathFunction.square,
          FunctionExpression(
            MathFunction.sin,
            NumberExpression(Decimal.fromInt(30)),
          ),
        ),
        FunctionExpression(
          MathFunction.square,
          FunctionExpression(
            MathFunction.cos,
            NumberExpression(Decimal.fromInt(30)),
          ),
        ),
      ),
    );
  });

  group('Edge cases and special scenarios', () {
    testParse(
      tokens: <Token>[
        ParenthesisToken.open(),
        NumberToken('42'),
        ParenthesisToken.close(),
      ],
      expected: ParenthesisGroupExpression(
        NumberExpression(Decimal.fromInt(42)),
        true,
      ),
    );

    testParse(
      tokens: <Token>[
        ParenthesisToken.open(),
        ParenthesisToken.open(),
        ConstantToken(Constant.pi),
        ParenthesisToken.close(),
        ParenthesisToken.close(),
      ],
      expected: ParenthesisGroupExpression(
        ParenthesisGroupExpression(ConstantExpression(Constant.pi), true),
        true,
      ),
    );

    testParse(
      tokens: <Token>[
        ParenthesisToken.open(),
        ConstantToken(Constant.euler),
        ParenthesisToken.close(),
        FunctionToken(FunctionTokenType.square),
      ],
      expected: FunctionExpression(
        MathFunction.square,
        ParenthesisGroupExpression(ConstantExpression(Constant.euler), true),
      ),
    );

    testParse(
      tokens: <Token>[
        ParenthesisToken.open(),
        NumberToken('2'),
        OperatorToken(OperatorTokenType.multiply),
        ConstantToken(Constant.pi),
        OperatorToken(OperatorTokenType.plus),
        NumberToken('3'),
        FunctionToken(FunctionTokenType.square),
        ParenthesisToken.close(),
        OperatorToken(OperatorTokenType.power),
        NumberToken('2'),
        OperatorToken(OperatorTokenType.minus),
        NumberToken('10'),
        OperatorToken(OperatorTokenType.squareRoot),
      ],
      expected: BinaryExpression(
        BinaryOperator.subtract,
        BinaryExpression(
          BinaryOperator.power,
          ParenthesisGroupExpression(
            BinaryExpression(
              BinaryOperator.add,
              BinaryExpression(
                BinaryOperator.multiply,
                NumberExpression(Decimal.fromInt(2)),
                ConstantExpression(Constant.pi),
              ),
              FunctionExpression(
                MathFunction.square,
                NumberExpression(Decimal.fromInt(3)),
              ),
            ),
            true,
          ),
          NumberExpression(Decimal.fromInt(2)),
        ),
        FunctionExpression(
          MathFunction.squareRoot,
          NumberExpression(Decimal.fromInt(10)),
        ),
      ),
    );
  });
}
