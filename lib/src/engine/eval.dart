import 'dart:math' as math;
import 'package:decimal/decimal.dart';
import 'package:omarchy_calculator/src/engine/base.dart';
import 'package:omarchy_calculator/src/engine/parse.dart' hide OtherError;

EvalResult eval(Expression expression) {
  try {
    return _evaluateExpression(expression);
  } catch (e) {
    if (e is EvalError) {
      return EvalResult.failure(expression, e);
    }
    return EvalResult.failure(expression, OtherError(e.toString()));
  }
}

/// Runs [eval] on any [PreviousResultExpression] within the
/// given [expression] and replaces its expression with
/// the [NumberExpression] of the result if successful.
Expression evalPreviousExpressions(Expression expression) {
  switch (expression) {
    case PreviousResultExpression(:final expression):
      final result = eval(expression);
      return result is SuccessEval
          ? PreviousResultExpression(expression, result: result.result)
          : expression;
    case BinaryExpression(:final operator, :final left, :final right):
      return BinaryExpression(
        operator,
        evalPreviousExpressions(left),
        evalPreviousExpressions(right),
      );
    case UnaryExpression(operator: final operator, operand: final operand):
      return UnaryExpression(operator, evalPreviousExpressions(operand));
    case FunctionExpression(:final function, :final argument):
      return FunctionExpression(function, evalPreviousExpressions(argument));
    case ParenthesisGroupExpression(:final expression, :final isClosed):
      return ParenthesisGroupExpression(
        evalPreviousExpressions(expression),
        isClosed,
      );
    case EmptyExpression():
    case ConstantExpression():
    case NumberExpression():
      return expression;
  }
}

EvalResult _evaluateExpression(Expression expression) {
  switch (expression) {
    case EmptyExpression():
      return EvalResult.success(expression, Decimal.fromInt(0));

    case NumberExpression(value: final value):
      return EvalResult.success(expression, value);

    case UnaryExpression(operator: final operator, operand: final operand):
      final operandResult = _evaluateExpression(operand);

      if (operandResult is FailureEval) {
        return operandResult;
      }

      final operandValue = (operandResult as SuccessEval).result;

      switch (operator) {
        case UnaryOperator.negate:
          return EvalResult.success(expression, -operandValue);
      }

    case BinaryExpression(
      operator: final operator,
      left: final left,
      right: final right,
    ):
      var leftResult = _evaluateExpression(left);

      if (leftResult is FailureEval) {
        return leftResult;
      }

      final rightResult = _evaluateExpression(right);

      if (rightResult is FailureEval) {
        return rightResult;
      }

      final leftValue = (leftResult as SuccessEval).result;
      final rightValue = (rightResult as SuccessEval).result;

      switch (operator) {
        case BinaryOperator.add:
          return EvalResult.success(expression, leftValue + rightValue);

        case BinaryOperator.subtract:
          return EvalResult.success(expression, leftValue - rightValue);

        case BinaryOperator.multiply:
          return EvalResult.success(expression, leftValue * rightValue);

        case BinaryOperator.divide:
          if (rightValue == Decimal.fromInt(0)) {
            return EvalResult.failure(expression, const DivisionByZeroError());
          }
          // Convert the rational result back to a decimal
          final result = (leftValue / rightValue).toDecimal();
          return EvalResult.success(expression, result);

        case BinaryOperator.power:
          try {
            // Convert to double for power operation, then back to Decimal
            final result = math.pow(
              leftValue.toDouble(),
              rightValue.toDouble(),
            );
            return EvalResult.success(
              expression,
              Decimal.parse(result.toString()),
            );
          } catch (e) {
            return EvalResult.failure(
              expression,
              OtherError('Error calculating power: $e'),
            );
          }
      }

    case ParenthesisGroupExpression(:final expression, :final isClosed):
      if (!isClosed) {
        return EvalResult.failure(expression, const UnclosedParenthesisError());
      }
      return _evaluateExpression(expression);

    case FunctionExpression(function: final function, argument: final argument):
      final argumentResult = _evaluateExpression(argument);

      if (argumentResult is FailureEval) {
        return argumentResult;
      }

      final argumentValue = (argumentResult as SuccessEval).result;

      switch (function) {
        case MathFunction.sin:
          // Convert degrees to radians for trigonometric functions
          final radians =
              argumentValue *
              Decimal.parse(math.pi.toString()) /
              Decimal.fromInt(180);
          return EvalResult.success(
            expression,
            Decimal.parse(math.sin(radians.toDouble()).toString()),
          );

        case MathFunction.cos:
          final radians =
              argumentValue *
              Decimal.parse(math.pi.toString()) /
              Decimal.fromInt(180);
          return EvalResult.success(
            expression,
            Decimal.parse(math.cos(radians.toDouble()).toString()),
          );

        case MathFunction.tan:
          final radians =
              argumentValue *
              Decimal.parse(math.pi.toString()) /
              Decimal.fromInt(180);
          // Check if angle is 90 degrees or equivalent (+-90, +-270, etc.)
          final normalizedDegrees = argumentValue.remainder(
            Decimal.fromInt(180),
          );
          if (normalizedDegrees == Decimal.fromInt(90) ||
              normalizedDegrees == Decimal.fromInt(-90)) {
            return EvalResult.failure(
              expression,
              OtherError('Invalid tangent result'),
            );
          }
          final tanValue = math.tan(radians.toDouble());
          if (tanValue.isInfinite || tanValue.isNaN) {
            return EvalResult.failure(
              expression,
              OtherError('Invalid tangent result'),
            );
          }
          return EvalResult.success(
            expression,
            Decimal.parse(tanValue.toString()),
          );

        case MathFunction.square:
          return EvalResult.success(expression, argumentValue * argumentValue);

        case MathFunction.squareRoot:
          if (argumentValue < Decimal.fromInt(0)) {
            return EvalResult.failure(
              expression,
              OtherError('Cannot calculate square root of negative number'),
            );
          }
          return EvalResult.success(
            expression,
            Decimal.parse(math.sqrt(argumentValue.toDouble()).toString()),
          );

        case MathFunction.percent:
          // Convert the rational result back to a decimal
          final result = (argumentValue / Decimal.fromInt(100)).toDecimal();
          return EvalResult.success(expression, result);
      }
    case ConstantExpression(:final name):
      return EvalResult.success(
        expression,
        Decimal.parse(switch (name) {
          Constant.pi => math.pi.toString(),
          Constant.euler => math.e.toString(),
        }),
      );
    case PreviousResultExpression(:final expression):
      return eval(expression);
  }
}

sealed class EvalResult {
  const EvalResult(this.expression);

  final Expression expression;

  const factory EvalResult.success(Expression expression, Decimal result) =
      SuccessEval;

  const factory EvalResult.failure(Expression expression, EvalError error) =
      FailureEval;
}

class SuccessEval extends EvalResult {
  const SuccessEval(super.expression, this.result);
  final Decimal result;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SuccessEval && other.result == result;
  }

  @override
  int get hashCode => result.hashCode;

  @override
  String toString() => 'SuccessEval(${result.toString()})';
}

class FailureEval extends EvalResult {
  const FailureEval(super.expression, this.error);
  final EvalError error;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FailureEval && other.error.toString() == error.toString();
  }

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() => 'FailureEval(${error.toString()})';
}

sealed class EvalError {
  const EvalError();
}

class DivisionByZeroError extends EvalError {
  const DivisionByZeroError();

  @override
  bool operator ==(Object other) => other is DivisionByZeroError;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'Division by zero error';
}

class UnclosedParenthesisError extends EvalError {
  const UnclosedParenthesisError();

  @override
  bool operator ==(Object other) => other is UnclosedParenthesisError;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'Unclosed parenthesis error';
}

class OtherError extends EvalError {
  const OtherError(this.message);
  final String message;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OtherError && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() => 'Other error: $message';
}
