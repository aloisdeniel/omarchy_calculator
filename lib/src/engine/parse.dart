import 'package:decimal/decimal.dart';
import 'package:omarchy_calculator/src/engine/base.dart';
import 'package:omarchy_calculator/src/engine/tokenize.dart';

Expression parse(List<Token> tokens) {
  if (tokens.isEmpty) return const EmptyExpression();

  // Split by equals sign
  final calculations = tokens.fold(<List<Token>>[], (result, token) {
    if (token is EqualsToken) {
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
    final parser = _Parser(calculation);
    final step = parser.readExpression(
      lastExpression != null ? PreviousResultExpression(lastExpression) : null,
    );

    lastExpression = step is EmptyExpression ? null : step;
  }

  return lastExpression ?? const EmptyExpression();
}

class _Parser {
  _Parser(this.tokens);
  final List<Token> tokens;
  int _index = 0;

  Token? peekToken([int offset = 0]) {
    final index = _index + offset;
    if (index >= 0 && index < tokens.length) {
      return tokens[index];
    }
    return null;
  }

  Token? readToken() {
    final result = peekToken();
    if (result != null) _index++;
    return result;
  }

  Expression? readExpression(Expression? lastExpression) {
    if (_index == 0 && lastExpression != null && tokens.isNotEmpty) {
      final token = tokens.first;
      if (token case OperatorToken()) {
        _index++;
        final right = readAddSubExpression(null);
        return BinaryExpression(
          BinaryOperator.fromToken(token.operator),
          lastExpression,
          right ?? const EmptyExpression(),
        );
      }
    }
    return readAddSubExpression(lastExpression);
  }

  Expression? readAddSubExpression(Expression? lastExpression) {
    var result = readMulDivExpression(lastExpression);

    while (result != null) {
      final token = peekToken();
      if (token is OperatorToken &&
          (token.operator == OperatorTokenType.plus ||
              token.operator == OperatorTokenType.minus)) {
        final finalOperator = _resolveConsecutiveOperators(tokens);

        final right = readMulDivExpression(lastExpression);
        result = BinaryExpression(
          BinaryOperator.fromToken(finalOperator!),
          result,
          right ?? const EmptyExpression(),
        );
      } else {
        break;
      }
    }
    return result;
  }

  Expression? readMulDivExpression(Expression? lastExpression) {
    var result = readPowerExpression(lastExpression);

    while (result != null) {
      final token = peekToken();
      if (token is OperatorToken &&
          (token.operator == OperatorTokenType.multiply ||
              token.operator == OperatorTokenType.divide)) {
        final finalOperator = _resolveConsecutiveOperators(tokens);

        final right = readPowerExpression(lastExpression);
        result = BinaryExpression(
          BinaryOperator.fromToken(finalOperator!),
          result,
          right ?? const EmptyExpression(),
        );
      } else {
        break;
      }
    }
    return result;
  }

  Expression? readPowerExpression(Expression? lastExpression) {
    var result = readUnaryExpression(lastExpression);

    if (result != null) {
      final token = peekToken();
      if (token is OperatorToken && token.operator == OperatorTokenType.power) {
        _index++;
        final right = readPowerExpression(lastExpression);
        result = BinaryExpression(
          BinaryOperator.power,
          result,
          right ?? EmptyExpression(),
        );
      }
    }
    return result;
  }

  Expression? readUnaryExpression(Expression? lastExpression) {
    if (_index >= tokens.length) {
      return null;
    }

    var token = peekToken();

    if (token is OperatorToken && token.operator == OperatorTokenType.minus) {
      _index++;

      // We skip all consecutive minus signs
      token = peekToken();
      while (token is OperatorToken &&
          token.operator == OperatorTokenType.minus) {
        _index++;
        token = peekToken();
      }

      final operand = readPostfixExpression(lastExpression);
      return UnaryExpression(
        UnaryOperator.negate,
        operand ?? const EmptyExpression(),
      );
    }

    return readPostfixExpression(lastExpression);
  }

  Expression? readPostfixExpression(Expression? lastExpression) {
    var result = readPrimaryExpression(lastExpression);

    while (result != null) {
      final token = peekToken();
      if (token is FunctionToken) {
        _index++;
        result = FunctionExpression(token.function, result);
      } else {
        break;
      }
    }

    return result;
  }

  Expression? readPrimaryExpression(Expression? lastExpression) {
    if (_index >= tokens.length) {
      return null;
    }

    final token = readToken();
    switch (token) {
      case NumberToken():
        return NumberExpression(token.asDecimal());

      case ConstantToken(:final name):
        return ConstantExpression(name);

      case ParenthesisToken(isOpen: true):
        final inner = readAddSubExpression(lastExpression);

        if (inner == null) {
          return ParenthesisGroupExpression(const EmptyExpression(), false);
        }

        final following = peekToken();
        if (following == null ||
            following is! ParenthesisToken ||
            following.isOpen) {
          return ParenthesisGroupExpression(inner, false);
        }

        _index++;
        return ParenthesisGroupExpression(inner, true);

      default:
        return null;
    }
  }

  /// Resolves consecutive operators according to standard mathematical rules.
  OperatorTokenType? _resolveConsecutiveOperators(List<Token> tokens) {
    if (_index >= tokens.length) {
      throw ArgumentError('Index out of range');
    }

    var token = peekToken();
    OperatorTokenType? result;
    while (token is OperatorToken) {
      _index++;
      final nextToken = peekToken();
      final nextNextToken = peekToken(1);

      // Something like "* - 4" should be treated as "* ( -4 )"
      // but not "- - 4" which is "-4"
      final isFollowedByNegate =
          token.operator != OperatorTokenType.minus &&
          (nextToken is OperatorToken &&
              nextToken.operator == OperatorTokenType.minus) &&
          (nextNextToken is NumberToken ||
              (nextNextToken is ParenthesisToken && nextNextToken.isOpen));

      if (nextToken is! OperatorToken || isFollowedByNegate) {
        result = token.operator;
        break;
      }

      switch ((token.operator, nextToken.operator)) {
        // +
        case (OperatorTokenType.plus, OperatorTokenType.plus):
          result = OperatorTokenType.plus;
        case (OperatorTokenType.plus, OperatorTokenType.minus):
          result = OperatorTokenType.minus;
        case (OperatorTokenType.plus, final next):
          result = next;

        // -
        case (OperatorTokenType.minus, OperatorTokenType.plus):
          result = OperatorTokenType.minus;
        case (OperatorTokenType.minus, OperatorTokenType.minus):
          result = OperatorTokenType.minus;
        case (OperatorTokenType.minus, final next):
          result = next;
        // *
        case (OperatorTokenType.multiply, OperatorTokenType.plus):
          result = OperatorTokenType.multiply;
        case (OperatorTokenType.multiply, OperatorTokenType.minus):
          result = OperatorTokenType.multiply;
        case (OperatorTokenType.multiply, final next):
          result = next;

        // /
        case (OperatorTokenType.divide, OperatorTokenType.plus):
          result = OperatorTokenType.divide;
        case (OperatorTokenType.divide, OperatorTokenType.minus):
          result = OperatorTokenType.divide;
        case (OperatorTokenType.divide, final next):
          result = next;

        // ^
        case (OperatorTokenType.power, OperatorTokenType.plus):
          result = OperatorTokenType.power;
        case (OperatorTokenType.power, OperatorTokenType.minus):
          result = OperatorTokenType.power;
        case (OperatorTokenType.power, final next):
          result = next;
      }

      token = nextToken;
    }

    return result;
  }
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

  const UnaryExpression.negate(this.operand) : operator = UnaryOperator.negate;

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
  multiply('×'),
  divide('÷'),
  power('^');

  const BinaryOperator(this.symbol);

  factory BinaryOperator.fromToken(OperatorTokenType token) {
    switch (token) {
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
    }
  }

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

class ParenthesisGroupExpression extends Expression {
  const ParenthesisGroupExpression(this.expression, this.isClosed);
  final Expression expression;
  final bool isClosed;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ParenthesisGroupExpression &&
        other.isClosed == isClosed &&
        other.expression == expression;
  }

  @override
  int get hashCode => Object.hash(expression, isClosed);

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
