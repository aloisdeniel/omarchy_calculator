import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omarchy_calculator/src/engine/base.dart';
import 'package:omarchy_calculator/src/engine/eval.dart';
import 'package:omarchy_calculator/src/engine/parse.dart' hide OtherError;

void testEval({
  required Expression expr,
  required EvalResult Function(Expression expr) expected,
  String? description,
}) {
  var effectiveDescription = expr.toString();

  if (description != null) {
    effectiveDescription = '$description: $effectiveDescription';
  }
  test(effectiveDescription, () {
    expect(eval(expr), equals(expected(expr)));
  });
}

void main() {
  group('Basic Expressions', () {
    testEval(
      expr: EmptyExpression(),
      expected: (e) => SuccessEval(e, Decimal.fromInt(0)),
    );

    testEval(
      expr: NumberExpression(Decimal.fromInt(42)),
      expected: (expr) => SuccessEval(expr, Decimal.fromInt(42)),
      description: 'Number expression',
    );

    testEval(
      expr: NumberExpression(Decimal.parse('3.14')),
      expected: (expr) => SuccessEval(expr, Decimal.parse('3.14')),
      description: 'Decimal number expression',
    );

    testEval(
      expr: NumberExpression(Decimal.fromInt(-15)),
      expected: (expr) => SuccessEval(expr, Decimal.fromInt(-15)),
      description: 'Negative number expression',
    );
  });

  group('Unary Expressions', () {
    testEval(
      expr: UnaryExpression(
        UnaryOperator.negate,
        NumberExpression(Decimal.fromInt(10)),
      ),
      expected: (expr) => SuccessEval(expr, Decimal.fromInt(-10)),
      description: 'Negate positive number',
    );

    testEval(
      expr: UnaryExpression(
        UnaryOperator.negate,
        NumberExpression(Decimal.fromInt(-10)),
      ),
      expected: (expr) => SuccessEval(expr, Decimal.fromInt(10)),
      description: 'Negate negative number',
    );

    testEval(
      expr: UnaryExpression(
        UnaryOperator.negate,
        NumberExpression(Decimal.parse('3.14')),
      ),
      expected: (expr) => SuccessEval(expr, Decimal.parse('-3.14')),
      description: 'Negate decimal number',
    );
  });

  group('Binary Expressions', () {
    testEval(
      expr: BinaryExpression(
        BinaryOperator.add,
        NumberExpression(Decimal.fromInt(5)),
        NumberExpression(Decimal.fromInt(3)),
      ),
      expected: (expr) => SuccessEval(expr, Decimal.fromInt(8)),
      description: 'Addition',
    );

    testEval(
      expr: BinaryExpression(
        BinaryOperator.subtract,
        NumberExpression(Decimal.fromInt(10)),
        NumberExpression(Decimal.fromInt(4)),
      ),
      expected: (expr) => SuccessEval(expr, Decimal.fromInt(6)),
      description: 'Subtraction',
    );

    testEval(
      expr: BinaryExpression(
        BinaryOperator.multiply,
        NumberExpression(Decimal.fromInt(6)),
        NumberExpression(Decimal.fromInt(7)),
      ),
      expected: (expr) => SuccessEval(expr, Decimal.fromInt(42)),
      description: 'Multiplication',
    );

    testEval(
      expr: BinaryExpression(
        BinaryOperator.divide,
        NumberExpression(Decimal.fromInt(20)),
        NumberExpression(Decimal.fromInt(5)),
      ),
      expected: (expr) => SuccessEval(expr, Decimal.fromInt(4)),
      description: 'Division',
    );

    test('Division by zero', () {
      final expression = BinaryExpression(
        BinaryOperator.divide,
        NumberExpression(Decimal.fromInt(10)),
        NumberExpression(Decimal.fromInt(0)),
      );
      final result = eval(expression);
      expect(result, isA<FailureEval>());
      final error = (result as FailureEval).error;
      expect(error, isA<DivisionByZeroError>());
    });

    testEval(
      expr: BinaryExpression(
        BinaryOperator.power,
        NumberExpression(Decimal.fromInt(2)),
        NumberExpression(Decimal.fromInt(3)),
      ),
      expected: (expr) => SuccessEval(expr, Decimal.fromInt(8)),
      description: 'Power',
    );
  });

  group('Complex Expressions', () {
    testEval(
      // 2 + 3 * 4 - 5 should evaluate to 9
      expr: BinaryExpression(
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
      expected: (expr) => SuccessEval(expr, Decimal.fromInt(9)),
      description: 'Multiple operations',
    );

    testEval(
      // (10 - 2) * (4 + 1) should evaluate to 40
      expr: BinaryExpression(
        BinaryOperator.multiply,
        BinaryExpression(
          BinaryOperator.subtract,
          NumberExpression(Decimal.fromInt(10)),
          NumberExpression(Decimal.fromInt(2)),
        ),
        BinaryExpression(
          BinaryOperator.add,
          NumberExpression(Decimal.fromInt(4)),
          NumberExpression(Decimal.fromInt(1)),
        ),
      ),
      expected: (expr) => SuccessEval(expr, Decimal.fromInt(40)),
      description: 'Nested expressions',
    );
  });

  group('Function Expressions', () {
    testEval(
      expr: FunctionExpression(
        MathFunction.square,
        NumberExpression(Decimal.fromInt(5)),
      ),
      expected: (expr) => SuccessEval(expr, Decimal.fromInt(25)),
      description: 'Square',
    );

    testEval(
      expr: FunctionExpression(
        MathFunction.squareRoot,
        NumberExpression(Decimal.fromInt(16)),
      ),
      expected: (expr) => SuccessEval(expr, Decimal.fromInt(4)),
      description: 'Square root',
    );

    test('Square root of negative number', () {
      final expression = FunctionExpression(
        MathFunction.squareRoot,
        NumberExpression(Decimal.fromInt(-4)),
      );
      final result = eval(expression);
      expect(result, isA<FailureEval>());
      final error = (result as FailureEval).error;
      expect(error, isA<OtherError>());
      expect(
        error.toString(),
        contains('Cannot calculate square root of negative number'),
      );
    });

    test('Sine', () {
      final expression = FunctionExpression(
        MathFunction.sin,
        NumberExpression(Decimal.fromInt(30)), // Sin(30°) = 0.5
      );
      final result = eval(expression);
      final sinValue = (result as SuccessEval).result;
      expect(sinValue.toDouble(), closeTo(0.5, 0.0001));
    });

    test('Cosine', () {
      final expression = FunctionExpression(
        MathFunction.cos,
        NumberExpression(Decimal.fromInt(60)), // Cos(60°) = 0.5
      );
      final result = eval(expression);
      final cosValue = (result as SuccessEval).result;
      expect(cosValue.toDouble(), closeTo(0.5, 0.0001));
    });

    test('Tangent', () {
      final expression = FunctionExpression(
        MathFunction.tan,
        NumberExpression(Decimal.fromInt(45)), // Tan(45°) = 1
      );
      final result = eval(expression);
      final tanValue = (result as SuccessEval).result;
      expect(tanValue.toDouble(), closeTo(1.0, 0.0001));
    });

    test('Percent', () {
      final expression = FunctionExpression(
        MathFunction.percent,
        NumberExpression(Decimal.fromInt(50)),
      );
      final result = eval(expression);
      expect(result, equals(SuccessEval(expression, Decimal.parse('0.5'))));
    });
  });

  group('Parenthesis Group Expressions', () {
    test('Simple parenthesis group', () {
      final expression = ParenthesisGroupExpression(
        NumberExpression(Decimal.fromInt(42)),
        true,
      );
      final result = eval(expression);
      expect(result, equals(SuccessEval(expression, Decimal.fromInt(42))));
    });

    test('Parenthesis group with binary expression', () {
      final innerExpression = BinaryExpression(
        BinaryOperator.add,
        NumberExpression(Decimal.fromInt(5)),
        NumberExpression(Decimal.fromInt(3)),
      );
      final expression = ParenthesisGroupExpression(innerExpression, true);
      final result = eval(expression);
      expect(result, equals(SuccessEval(expression, Decimal.fromInt(8))));
    });

    test('Nested parenthesis groups', () {
      final innerExpression = ParenthesisGroupExpression(
        NumberExpression(Decimal.fromInt(10)),
        true,
      );
      final expression = ParenthesisGroupExpression(innerExpression, true);
      final result = eval(expression);
      expect(result, equals(SuccessEval(expression, Decimal.fromInt(10))));
    });

    test('Parenthesis group with function expression', () {
      final functionExpression = FunctionExpression(
        MathFunction.square,
        NumberExpression(Decimal.fromInt(5)),
      );
      final expression = ParenthesisGroupExpression(functionExpression, true);
      final result = eval(expression);
      expect(result, equals(SuccessEval(expression, Decimal.fromInt(25))));
    });

    test('Parenthesis group with error propagation', () {
      final errorExpression = BinaryExpression(
        BinaryOperator.divide,
        NumberExpression(Decimal.fromInt(10)),
        NumberExpression(Decimal.fromInt(0)),
      );
      final expression = ParenthesisGroupExpression(errorExpression, true);
      final result = eval(expression);
      expect(result, isA<FailureEval>());
      final error = (result as FailureEval).error;
      expect(error, isA<DivisionByZeroError>());
    });
  });

  group('Unmatched Parentheses', () {
    test('Simple unmatched opening parenthesis', () {
      final expression = ParenthesisGroupExpression(
        NumberExpression(Decimal.fromInt(42)),
        false, // isClosed = false indicates unmatched parenthesis
      );
      final result = eval(expression);
      expect(result, isA<FailureEval>());
      final error = (result as FailureEval).error;
      expect(error, isA<UnclosedParenthesisError>());
      expect(error.toString(), equals('Unclosed parenthesis error'));
    });

    test('Unmatched opening parenthesis with binary expression', () {
      final expression = ParenthesisGroupExpression(
        BinaryExpression(
          BinaryOperator.add,
          NumberExpression(Decimal.fromInt(5)),
          NumberExpression(Decimal.fromInt(3)),
        ),
        false,
      );
      final result = eval(expression);
      expect(result, isA<FailureEval>());
      final error = (result as FailureEval).error;
      expect(error, isA<UnclosedParenthesisError>());
    });

    test('Unmatched opening parenthesis with function expression', () {
      final expression = ParenthesisGroupExpression(
        FunctionExpression(
          MathFunction.square,
          NumberExpression(Decimal.fromInt(5)),
        ),
        false,
      );
      final result = eval(expression);
      expect(result, isA<FailureEval>());
      final error = (result as FailureEval).error;
      expect(error, isA<UnclosedParenthesisError>());
    });

    test('Unmatched opening parenthesis with constant', () {
      final expression = ParenthesisGroupExpression(
        ConstantExpression(Constant.pi),
        false,
      );
      final result = eval(expression);
      expect(result, isA<FailureEval>());
      final error = (result as FailureEval).error;
      expect(error, isA<UnclosedParenthesisError>());
    });

    test('Multiple nested unmatched opening parentheses', () {
      final expression = ParenthesisGroupExpression(
        ParenthesisGroupExpression(
          NumberExpression(Decimal.fromInt(10)),
          false, // Inner parenthesis is also unmatched
        ),
        false, // Outer parenthesis is unmatched
      );
      final result = eval(expression);
      expect(result, isA<FailureEval>());
      final error = (result as FailureEval).error;
      expect(error, isA<UnclosedParenthesisError>());
    });

    test('Unmatched opening parenthesis in binary expression left operand', () {
      final expression = BinaryExpression(
        BinaryOperator.multiply,
        ParenthesisGroupExpression(NumberExpression(Decimal.fromInt(5)), false),
        NumberExpression(Decimal.fromInt(3)),
      );
      final result = eval(expression);
      expect(result, isA<FailureEval>());
      final error = (result as FailureEval).error;
      expect(error, isA<UnclosedParenthesisError>());
    });

    test(
      'Unmatched opening parenthesis in binary expression right operand',
      () {
        final expression = BinaryExpression(
          BinaryOperator.add,
          NumberExpression(Decimal.fromInt(10)),
          ParenthesisGroupExpression(
            BinaryExpression(
              BinaryOperator.subtract,
              NumberExpression(Decimal.fromInt(8)),
              NumberExpression(Decimal.fromInt(3)),
            ),
            false,
          ),
        );
        final result = eval(expression);
        expect(result, isA<FailureEval>());
        final error = (result as FailureEval).error;
        expect(error, isA<UnclosedParenthesisError>());
      },
    );

    test('Unmatched opening parenthesis in function argument', () {
      final expression = FunctionExpression(
        MathFunction.squareRoot,
        ParenthesisGroupExpression(
          NumberExpression(Decimal.fromInt(16)),
          false,
        ),
      );
      final result = eval(expression);
      expect(result, isA<FailureEval>());
      final error = (result as FailureEval).error;
      expect(error, isA<UnclosedParenthesisError>());
    });

    test('Unmatched opening parenthesis in unary expression operand', () {
      final expression = UnaryExpression(
        UnaryOperator.negate,
        ParenthesisGroupExpression(NumberExpression(Decimal.fromInt(7)), false),
      );
      final result = eval(expression);
      expect(result, isA<FailureEval>());
      final error = (result as FailureEval).error;
      expect(error, isA<UnclosedParenthesisError>());
    });

    test('Mixed matched and unmatched parentheses', () {
      final expression = ParenthesisGroupExpression(
        BinaryExpression(
          BinaryOperator.multiply,
          NumberExpression(Decimal.fromInt(2)),
          ParenthesisGroupExpression(
            BinaryExpression(
              BinaryOperator.add,
              NumberExpression(Decimal.fromInt(3)),
              NumberExpression(Decimal.fromInt(4)),
            ),
            true, // This inner parenthesis is matched
          ),
        ),
        false, // But the outer parenthesis is unmatched
      );
      final result = eval(expression);
      expect(result, isA<FailureEval>());
      final error = (result as FailureEval).error;
      expect(error, isA<UnclosedParenthesisError>());
    });

    test('Unmatched opening parenthesis with complex nested expression', () {
      final expression = ParenthesisGroupExpression(
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
        false,
      );
      final result = eval(expression);
      expect(result, isA<FailureEval>());
      final error = (result as FailureEval).error;
      expect(error, isA<UnclosedParenthesisError>());
    });
  });

  group('Error Handling', () {
    test('Invalid tangent (90 degrees)', () {
      final expression = FunctionExpression(
        MathFunction.tan,
        NumberExpression(Decimal.fromInt(90)), // Tan(90°) is undefined
      );
      final result = eval(expression);
      expect(result, isA<FailureEval>());
      final error = (result as FailureEval).error;
      expect(error, isA<OtherError>());
      expect(error.toString(), contains('Invalid tangent result'));
    });
  });
}
