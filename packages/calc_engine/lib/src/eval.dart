import 'dart:math' as math;
import 'package:calc_engine/src/context.dart';
import 'package:decimal/decimal.dart';
import 'package:calc_engine/src/parse.dart';

EvalResult eval(CalcContext context, Expression expression) {
  try {
    return _evaluateExpression(context, expression);
  } catch (e) {
    if (e is EvalError) {
      return EvalResult.failure(expression, e);
    }
    return EvalResult.failure(expression, OtherEvalError(e.toString()));
  }
}

/// Runs [eval] on any [PreviousResultExpression] within the
/// given [expression] and replaces its expression with
/// the [NumberExpression] of the result if successful.
Expression evalPreviousExpressions(CalcContext context, Expression expression) {
  switch (expression) {
    case PreviousResultExpression(:final expression):
      final result = eval(context, expression);
      return result is SuccessEval
          ? PreviousResultExpression(expression, result: result.result)
          : expression;
    case BinaryExpression(:final operator, :final left, :final right):
      return BinaryExpression(
        operator,
        evalPreviousExpressions(context, left),
        evalPreviousExpressions(context, right),
      );
    case UnaryExpression(operator: final operator, operand: final operand):
      return UnaryExpression(
        operator,
        evalPreviousExpressions(context, operand),
      );
    case FunctionExpression(:final function, :final arguments, :final isClosed):
      return FunctionExpression(
        function,
        arguments.map((x) => evalPreviousExpressions(context, x)).toList(),
        isClosed: isClosed,
      );
    case ParenthesisGroupExpression(:final expression, :final isClosed):
      return ParenthesisGroupExpression(
        evalPreviousExpressions(context, expression),
        isClosed,
      );
    case EmptyExpression():
    case ConstantExpression():
    case NumberExpression():
      return expression;
    case UnknownFunctionExpression(
      :final function,
      :final arguments,
      :final isClosed,
    ):
      return UnknownFunctionExpression(
        function,
        arguments.map((x) => evalPreviousExpressions(context, x)).toList(),
        isClosed: isClosed,
      );
    case UnknownConstantExpression():
      return expression;
  }
}

EvalResult _evaluateExpression(CalcContext context, Expression expression) {
  switch (expression) {
    case EmptyExpression():
      return EvalResult.failure(expression, const UncompletedError());

    case NumberExpression(value: final value):
      return EvalResult.success(expression, value);

    case UnaryExpression(operator: final operator, operand: final operand):
      final operandResult = _evaluateExpression(context, operand);

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
      var leftResult = _evaluateExpression(context, left);

      if (leftResult is FailureEval) {
        return leftResult;
      }

      final rightResult = _evaluateExpression(context, right);

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
          final result = (leftValue / rightValue).toDecimal(
            scaleOnInfinitePrecision: 20,
          );
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
              OtherEvalError('Error calculating power: $e'),
            );
          }
      }

    case ParenthesisGroupExpression(:final expression, :final isClosed):
      if (!isClosed) {
        return EvalResult.failure(expression, const UnclosedParenthesisError());
      }
      return _evaluateExpression(context, expression);

    case FunctionExpression(:final function, :final arguments):
      try {
        final argumentValues = <Decimal>[];
        for (final arg in arguments) {
          final argResult = _evaluateExpression(context, arg);
          if (argResult is FailureEval) {
            return argResult;
          }
          argumentValues.add((argResult as SuccessEval).result);
        }
        return EvalResult.success(
          expression,
          function.evaluate(context, argumentValues),
        );
      } catch (e) {
        return EvalResult.failure(
          expression,
          e is EvalError ? e : OtherEvalError('$e'),
        );
      }

    case ConstantExpression(:final name):
      return EvalResult.success(expression, name.value);

    case UnknownFunctionExpression(:final function):
      return EvalResult.failure(
        expression,
        OtherEvalError('Unknown function: $function'),
      );

    case UnknownConstantExpression(:final name):
      return EvalResult.failure(
        expression,
        OtherEvalError('Unknown constant: $name'),
      );

    case PreviousResultExpression(:final expression):
      return eval(context, expression);
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

class UncompletedError extends EvalError {
  const UncompletedError();

  @override
  bool operator ==(Object other) => other is UncompletedError;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'Uncompleted expression error';
}

class DivisionByZeroError extends EvalError {
  const DivisionByZeroError();

  @override
  bool operator ==(Object other) => other is DivisionByZeroError;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'Division by zero';
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

class OtherEvalError extends EvalError {
  const OtherEvalError(this.message);
  final String message;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OtherEvalError && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;

  @override
  String toString() => 'Other error: $message';
}
