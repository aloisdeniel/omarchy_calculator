import 'package:decimal/decimal.dart';
import 'package:omarchy_calculator/src/engine/tokenize.dart';

Expression parse(List<Token> tokens) {
  if (tokens.isEmpty) return const EmptyExpression();

  // Split by equals sign
  final calculations = tokens.fold(<List<Token>>[], (result, token) {
    if (token is OperatorToken && token.operator == OperatorTokenType.equals) {
      result.add([]);
    } else {
      if (result.isEmpty) {
        result.add([]);
      }
      result.last.add(token);
    }
    return result;
  });

  Expression? lastExpression;
  for (final calculation in calculations.where((x) => x.isNotEmpty)) {
    final step = _parseExpression(
      lastExpression != null ? PreviousResultExpression(lastExpression) : null,
      calculation,
      0,
    );

    lastExpression = step.expression is EmptyExpression
        ? null
        : step.expression;
  }

  return lastExpression ?? const EmptyExpression();
}

_ParsingStep _parseExpression(
  Expression? lastExpression,
  List<Token> tokens,
  int index,
) {
  /// If the expression starts with an operator, we
  /// insert the last expression as the left operand.
  if (index == 0 && lastExpression != null && tokens.isNotEmpty) {
    final token = tokens.first;
    if (token case OperatorToken()) {
      final right = _parseAddSubExpression(null, tokens, 1);
      return _ParsingStep(
        BinaryExpression(
          token.operator.toBinaryOperator(),
          lastExpression,
          right.expression,
        ),
        right.nextIndex,
      );
    }
  }
  return _parseAddSubExpression(lastExpression, tokens, index);
}

_ParsingStep _parseAddSubExpression(
  Expression? lastExpression,
  List<Token> tokens,
  int index,
) {
  var result = _parseMulDivExpression(lastExpression, tokens, index);

  while (result.nextIndex < tokens.length) {
    final token = tokens[result.nextIndex];
    if (token is OperatorToken &&
        (token.operator == OperatorTokenType.plus ||
            token.operator == OperatorTokenType.minus)) {
      final right = _parseMulDivExpression(
        lastExpression,
        tokens,
        result.nextIndex + 1,
      );
      result = _ParsingStep(
        BinaryExpression(
          token.operator.toBinaryOperator(),
          result.expression,
          right.expression,
        ),
        right.nextIndex,
      );
    } else {
      break;
    }
  }
  return result;
}

_ParsingStep _parseMulDivExpression(
  Expression? lastExpression,
  List<Token> tokens,
  int index,
) {
  var result = _parsePowerExpression(lastExpression, tokens, index);

  while (result.nextIndex < tokens.length) {
    final token = tokens[result.nextIndex];
    if (token is OperatorToken &&
        (token.operator == OperatorTokenType.multiply ||
            token.operator == OperatorTokenType.divide)) {
      final right = _parsePowerExpression(
        lastExpression,
        tokens,
        result.nextIndex + 1,
      );
      result = _ParsingStep(
        BinaryExpression(
          token.operator.toBinaryOperator(),
          result.expression,
          right.expression,
        ),
        right.nextIndex,
      );
    } else {
      break;
    }
  }
  return result;
}

_ParsingStep _parsePowerExpression(
  Expression? lastExpression,
  List<Token> tokens,
  int index,
) {
  var result = _parseUnaryExpression(lastExpression, tokens, index);

  if (result.nextIndex < tokens.length) {
    final token = tokens[result.nextIndex];
    if (token is OperatorToken && token.operator == OperatorTokenType.power) {
      final right = _parsePowerExpression(
        lastExpression,
        tokens,
        result.nextIndex + 1,
      );
      result = _ParsingStep(
        BinaryExpression(
          BinaryOperator.power,
          result.expression,
          right.expression,
        ),
        right.nextIndex,
      );
    }
  }
  return result;
}

_ParsingStep _parseUnaryExpression(
  Expression? lastExpression,
  List<Token> tokens,
  int index,
) {
  if (index >= tokens.length) {
    return _ParsingStep(const EmptyExpression(), index);
  }

  final token = tokens[index];

  if (token is OperatorToken && token.operator == OperatorTokenType.minus) {
    if (index + 1 < tokens.length && tokens[index + 1] is NumberToken) {
      final numberToken = tokens[index + 1] as NumberToken;
      return _ParsingStep(
        NumberExpression(Decimal.parse('-${numberToken.value}')),
        index + 2,
      );
    } else {
      final operand = _parseUnaryExpression(lastExpression, tokens, index + 1);
      return _ParsingStep(
        UnaryExpression(UnaryOperator.negate, operand.expression),
        operand.nextIndex,
      );
    }
  }

  return _parsePostfixExpression(lastExpression, tokens, index);
}

_ParsingStep _parsePostfixExpression(
  Expression? lastExpression,
  List<Token> tokens,
  int index,
) {
  var result = _parsePrimaryExpression(lastExpression, tokens, index);

  while (result.nextIndex < tokens.length) {
    final token = tokens[result.nextIndex];
    if (token is OperatorToken &&
        (token.operator == OperatorTokenType.percent ||
            token.operator == OperatorTokenType.squareRoot)) {
      result = _ParsingStep(
        FunctionExpression(token.operator.toMathFunction(), result.expression),
        result.nextIndex + 1,
      );
    } else if (token is FunctionToken) {
      result = _ParsingStep(
        FunctionExpression(token.name.toMathFunction(), result.expression),
        result.nextIndex + 1,
      );
    } else {
      break;
    }
  }

  return result;
}

_ParsingStep _parsePrimaryExpression(
  Expression? lastExpression,
  List<Token> tokens,
  int index,
) {
  if (index >= tokens.length) {
    return _ParsingStep(const EmptyExpression(), index);
  }

  final token = tokens[index];
  switch (token) {
    case NumberToken(value: final value):
      return _ParsingStep(NumberExpression(Decimal.parse(value)), index + 1);

    case ConstantToken(:final name):
      return _ParsingStep(ConstantExpression(name), index + 1);

    case ParenthesisToken(isOpen: true):
      final inner = _parseAddSubExpression(lastExpression, tokens, index + 1);
      if (inner.nextIndex >= tokens.length ||
          tokens[inner.nextIndex] is! ParenthesisToken ||
          (tokens[inner.nextIndex] as ParenthesisToken).isOpen) {
        return _ParsingStep(const EmptyExpression(), index + 1);
      }
      return _ParsingStep(
        ParenthesisGroupExpression(inner.expression),
        inner.nextIndex + 1,
      );

    case CommandToken():
      return _ParsingStep(const EmptyExpression(), index + 1);

    default:
      return _ParsingStep(const EmptyExpression(), index + 1);
  }
}

class _ParsingStep {
  _ParsingStep(this.expression, this.nextIndex);
  final Expression expression;
  final int nextIndex;
}

sealed class ParsingError {
  const ParsingError();
}

class OtherError extends ParsingError {
  const OtherError(this.message);
  final String message;
  @override
  String toString() => 'Other error: $message';
}

sealed class Expression {
  const Expression();
}

class EmptyExpression extends Expression {
  const EmptyExpression();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EmptyExpression;
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return '()';
  }
}

class ConstantExpression extends Expression {
  const ConstantExpression(this.name);
  final Constant name;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConstantExpression && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() {
    return '$name';
  }
}

class NumberExpression extends Expression {
  const NumberExpression(this.value);
  final Decimal value;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NumberExpression && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() {
    return '$value';
  }
}

enum UnaryOperator {
  negate('-');

  const UnaryOperator(this.symbol);
  final String symbol;
}

class PreviousResultExpression extends Expression {
  const PreviousResultExpression(this.expression, {this.result});
  final Expression expression;
  final Decimal? result;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PreviousResultExpression &&
        other.expression == expression &&
        other.result == result;
  }

  @override
  int get hashCode => Object.hash(expression, result);

  @override
  String toString() {
    return '(=> $expression)';
  }
}

class UnaryExpression extends Expression {
  const UnaryExpression(this.operator, this.operand);
  final UnaryOperator operator;
  final Expression operand;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UnaryExpression &&
        other.operator == operator &&
        other.operand == operand;
  }

  @override
  int get hashCode => Object.hash(operator, operand);

  @override
  String toString() {
    return '(${operator.symbol} $operand)';
  }
}

enum BinaryOperator {
  add('+'),
  subtract('-'),
  multiply('*'),
  divide('/'),
  power('^');

  const BinaryOperator(this.symbol);
  final String symbol;
}

class BinaryExpression extends Expression {
  const BinaryExpression(this.operator, this.left, this.right);
  final BinaryOperator operator;
  final Expression left;
  final Expression right;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BinaryExpression &&
        other.operator == operator &&
        other.left == left &&
        other.right == right;
  }

  @override
  int get hashCode => Object.hash(operator, left, right);

  @override
  String toString() {
    return '(${operator.symbol} $left $right)';
  }
}

enum MathFunction {
  sin,
  cos,
  tan,
  square,
  squareRoot,
  percent;

  @override
  String toString() {
    switch (this) {
      case MathFunction.sin:
        return 'sin';
      case MathFunction.cos:
        return 'cos';
      case MathFunction.tan:
        return 'tan';
      case MathFunction.square:
        return 'x²';
      case MathFunction.squareRoot:
        return '√';
      case MathFunction.percent:
        return '%';
    }
  }
}

class ParenthesisGroupExpression extends Expression {
  const ParenthesisGroupExpression(this.expression);
  final Expression expression;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ParenthesisGroupExpression &&
        other.expression == expression;
  }

  @override
  int get hashCode => expression.hashCode;

  @override
  String toString() {
    return '($expression)';
  }
}

class FunctionExpression extends Expression {
  const FunctionExpression(this.function, this.argument);
  final MathFunction function;
  final Expression argument;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FunctionExpression &&
        other.function == function &&
        other.argument == argument;
  }

  @override
  int get hashCode => Object.hash(function, argument);

  @override
  String toString() {
    return '($function $argument)';
  }
}

extension on FunctionTokenType {
  MathFunction toMathFunction() {
    switch (this) {
      case FunctionTokenType.sin:
        return MathFunction.sin;
      case FunctionTokenType.cos:
        return MathFunction.cos;
      case FunctionTokenType.tan:
        return MathFunction.tan;
      case FunctionTokenType.square:
        return MathFunction.square;
    }
  }
}

extension on OperatorTokenType {
  BinaryOperator toBinaryOperator() {
    switch (this) {
      case OperatorTokenType.plus:
        return BinaryOperator.add;
      case OperatorTokenType.minus:
        return BinaryOperator.subtract;
      case OperatorTokenType.multiply:
        return BinaryOperator.multiply;
      case OperatorTokenType.divide:
        return BinaryOperator.divide;
      case OperatorTokenType.power:
        return BinaryOperator.power;
      case OperatorTokenType.squareRoot:
      case OperatorTokenType.percent:
      case OperatorTokenType.equals:
        throw UnimplementedError();
    }
  }

  MathFunction toMathFunction() {
    switch (this) {
      case OperatorTokenType.squareRoot:
        return MathFunction.squareRoot;
      case OperatorTokenType.percent:
        return MathFunction.percent;
      case OperatorTokenType.equals:
      case OperatorTokenType.plus:
      case OperatorTokenType.minus:
      case OperatorTokenType.multiply:
      case OperatorTokenType.divide:
      case OperatorTokenType.power:
        throw UnimplementedError();
    }
  }
}
