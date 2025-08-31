import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omarchy_calculator/src/engine/eval.dart';
import 'package:omarchy_calculator/src/engine/parse.dart' hide OtherError;

void main() {
  group('Basic Expressions', () {
    test('Empty expression', () {
      const expression = EmptyExpression();
      final result = eval(expression);
      expect(result, equals(SuccessEval(expression, Decimal.fromInt(0))));
    });

    test('Number expression', () {
      final expression = NumberExpression(Decimal.fromInt(42));
      final result = eval(expression);
      expect(result, equals(SuccessEval(expression, Decimal.fromInt(42))));
    });

    test('Decimal number expression', () {
      final expression = NumberExpression(Decimal.parse('3.14'));
      final result = eval(expression);
      expect(result, equals(SuccessEval(expression, Decimal.parse('3.14'))));
    });

    test('Negative number expression', () {
      final expression = NumberExpression(Decimal.fromInt(-15));
      final result = eval(expression);
      expect(result, equals(SuccessEval(expression, Decimal.fromInt(-15))));
    });
  });

  group('Unary Expressions', () {
    test('Negate positive number', () {
      final expression = UnaryExpression(
        UnaryOperator.negate,
        NumberExpression(Decimal.fromInt(10)),
      );
      final result = eval(expression);
      expect(result, equals(SuccessEval(expression, Decimal.fromInt(-10))));
    });

    test('Negate negative number', () {
      final expression = UnaryExpression(
        UnaryOperator.negate,
        NumberExpression(Decimal.fromInt(-10)),
      );
      final result = eval(expression);
      expect(result, equals(SuccessEval(expression, Decimal.fromInt(10))));
    });

    test('Negate decimal number', () {
      final expression = UnaryExpression(
        UnaryOperator.negate,
        NumberExpression(Decimal.parse('3.14')),
      );
      final result = eval(expression);
      expect(result, equals(SuccessEval(expression, Decimal.parse('-3.14'))));
    });
  });

  group('Binary Expressions', () {
    test('Addition', () {
      final expression = BinaryExpression(
        BinaryOperator.add,
        NumberExpression(Decimal.fromInt(5)),
        NumberExpression(Decimal.fromInt(3)),
      );
      final result = eval(expression);
      expect(result, equals(SuccessEval(expression, Decimal.fromInt(8))));
    });

    test('Subtraction', () {
      final expression = BinaryExpression(
        BinaryOperator.subtract,
        NumberExpression(Decimal.fromInt(10)),
        NumberExpression(Decimal.fromInt(4)),
      );
      final result = eval(expression);
      expect(result, equals(SuccessEval(expression, Decimal.fromInt(6))));
    });

    test('Multiplication', () {
      final expression = BinaryExpression(
        BinaryOperator.multiply,
        NumberExpression(Decimal.fromInt(6)),
        NumberExpression(Decimal.fromInt(7)),
      );
      final result = eval(expression);
      expect(result, equals(SuccessEval(expression, Decimal.fromInt(42))));
    });

    test('Division', () {
      final expression = BinaryExpression(
        BinaryOperator.divide,
        NumberExpression(Decimal.fromInt(20)),
        NumberExpression(Decimal.fromInt(5)),
      );
      final result = eval(expression);
      expect(result, equals(SuccessEval(expression, Decimal.fromInt(4))));
    });

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

    test('Power', () {
      final expression = BinaryExpression(
        BinaryOperator.power,
        NumberExpression(Decimal.fromInt(2)),
        NumberExpression(Decimal.fromInt(3)),
      );
      final result = eval(expression);
      expect(result, equals(SuccessEval(expression, Decimal.fromInt(8))));
    });
  });

  group('Complex Expressions', () {
    test('Multiple operations', () {
      // 2 + 3 * 4 - 5 should evaluate to 9
      final expression = BinaryExpression(
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
      );
      final result = eval(expression);
      expect(result, equals(SuccessEval(expression, Decimal.fromInt(9))));
    });

    test('Nested expressions', () {
      // (10 - 2) * (4 + 1) should evaluate to 40
      final expression = BinaryExpression(
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
      );
      final result = eval(expression);
      expect(result, equals(SuccessEval(expression, Decimal.fromInt(40))));
    });
  });

  group('Function Expressions', () {
    test('Square', () {
      final expression = FunctionExpression(
        MathFunction.square,
        NumberExpression(Decimal.fromInt(5)),
      );
      final result = eval(expression);
      expect(result, equals(SuccessEval(expression, Decimal.fromInt(25))));
    });

    test('Square root', () {
      final expression = FunctionExpression(
        MathFunction.squareRoot,
        NumberExpression(Decimal.fromInt(16)),
      );
      final result = eval(expression);
      expect(result, equals(SuccessEval(expression, Decimal.fromInt(4))));
    });

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
      final expression = ParenthesisGroupExpression(innerExpression);
      final result = eval(expression);
      expect(result, equals(SuccessEval(expression, Decimal.fromInt(8))));
    });

    test('Nested parenthesis groups', () {
      final innerExpression = ParenthesisGroupExpression(
        NumberExpression(Decimal.fromInt(10)),
      );
      final expression = ParenthesisGroupExpression(innerExpression);
      final result = eval(expression);
      expect(result, equals(SuccessEval(expression, Decimal.fromInt(10))));
    });

    test('Parenthesis group with function expression', () {
      final functionExpression = FunctionExpression(
        MathFunction.square,
        NumberExpression(Decimal.fromInt(5)),
      );
      final expression = ParenthesisGroupExpression(functionExpression);
      final result = eval(expression);
      expect(result, equals(SuccessEval(expression, Decimal.fromInt(25))));
    });

    test('Parenthesis group with error propagation', () {
      final errorExpression = BinaryExpression(
        BinaryOperator.divide,
        NumberExpression(Decimal.fromInt(10)),
        NumberExpression(Decimal.fromInt(0)),
      );
      final expression = ParenthesisGroupExpression(errorExpression);
      final result = eval(expression);
      expect(result, isA<FailureEval>());
      final error = (result as FailureEval).error;
      expect(error, isA<DivisionByZeroError>());
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
