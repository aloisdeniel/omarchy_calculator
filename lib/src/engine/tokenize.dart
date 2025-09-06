import 'package:decimal/decimal.dart';
import 'package:omarchy_calculator/src/engine/base.dart';
import 'package:omarchy_calculator/src/engine/command.dart';

List<Token> tokenize(List<Command> commands) {
  var current = '';
  final result = <Token>[];
  var currentIsNegative = false;

  void clearCurrent() {
    current = '';
    currentIsNegative = false;
  }

  void flushCurrent() {
    if (current.isNotEmpty) {
      if (currentIsNegative) {
        result.add(OperatorToken(OperatorTokenType.minus));
      }
      if (current.endsWith('.')) {
        current = current.substring(0, current.length - 1);
      }
      result.add(NumberToken(current));
    }
    clearCurrent();
  }

  for (var i = 0; i < commands.length; i++) {
    final cmd = commands[i];
    switch (cmd) {
      case Digit(value: final value):
        current += '$value';
      case DecimalPoint():
        if (!current.contains('.')) {
          if (current.isEmpty) {
            current = '0.';
          } else {
            current += '.';
          }
        }
      case ToggleSign():
        currentIsNegative = !currentIsNegative;
      case ClearAll():
        clearCurrent();
        result.clear();
      case ClearEntry():
        clearCurrent();
      case Backspace():
        if (current.isNotEmpty) {
          current = current.substring(0, current.length - 1);
        } else if (result.isNotEmpty) {
          final last = result.removeLast();
          if (last is NumberToken) {
            current = last.value.toString();
            if (current.isNotEmpty) {
              current = current.substring(0, current.length - 1);
            }
          }
        }
      case MemoryClear():
      case MemoryRecall():
      case MemoryAdd():
      case MemorySubtract():
        break;
      case Sine():
        flushCurrent();
        result.add(const FunctionToken(MathFunction.sin));
      case Cosine():
        flushCurrent();
        result.add(const FunctionToken(MathFunction.cos));
      case Tangent():
        flushCurrent();
        result.add(const FunctionToken(MathFunction.tan));
      case OpenParenthesis():
        flushCurrent();
        result.add(const ParenthesisToken.open());
      case CloseParenthesis():
        flushCurrent();
        result.add(const ParenthesisToken.close());
      case ConstantCommand(:final constant):
        flushCurrent();
        result.add(ConstantToken(constant));
      case Power():
        flushCurrent();
        result.add(const OperatorToken(OperatorTokenType.power));
      case Percent():
        flushCurrent();
        result.add(const FunctionToken(MathFunction.percent));
      case SquareRoot():
        flushCurrent();
        result.add(const FunctionToken(MathFunction.squareRoot));
      case Square():
        flushCurrent();
        result.add(const FunctionToken(MathFunction.square));
      case Operator(type: OperatorType.plus):
        flushCurrent();
        result.add(const OperatorToken(OperatorTokenType.plus));
      case Operator(type: OperatorType.minus):
        flushCurrent();
        result.add(const OperatorToken(OperatorTokenType.minus));
      case Operator(type: OperatorType.power):
        flushCurrent();
        result.add(const OperatorToken(OperatorTokenType.power));
      case Operator(type: OperatorType.divide):
        flushCurrent();
        result.add(const OperatorToken(OperatorTokenType.divide));
      case Operator(type: OperatorType.multiply):
        flushCurrent();
        result.add(const OperatorToken(OperatorTokenType.multiply));
      case Equals():
        flushCurrent();
        result.add(const EqualsToken());
    }
  }

  flushCurrent();
  return result;
}

sealed class Token {
  const Token();
}

class ParenthesisToken extends Token {
  const ParenthesisToken.open() : isOpen = true;
  const ParenthesisToken.close() : isOpen = false;
  final bool isOpen;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ParenthesisToken && other.isOpen == isOpen;
  }

  @override
  int get hashCode => isOpen.hashCode;
}

class NumberToken extends Token {
  const NumberToken(this.value);

  final String value;

  Decimal asDecimal() {
    final result = Decimal.parse(value);
    assert(result >= Decimal.zero, 'Negation should be handled separately.');
    return result;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NumberToken && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() {
    return value;
  }
}

class OperatorToken extends Token {
  const OperatorToken(this.operator);

  const OperatorToken.minus() : operator = OperatorTokenType.minus;
  const OperatorToken.plus() : operator = OperatorTokenType.plus;
  const OperatorToken.multiply() : operator = OperatorTokenType.multiply;
  const OperatorToken.divide() : operator = OperatorTokenType.divide;
  const OperatorToken.power() : operator = OperatorTokenType.power;

  final OperatorTokenType operator;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OperatorToken && other.operator == operator;
  }

  @override
  int get hashCode => operator.hashCode;

  @override
  String toString() {
    return '<$operator>';
  }
}

enum OperatorTokenType {
  plus,
  minus,
  multiply,
  divide,
  power;

  @override
  String toString() {
    return switch (this) {
      OperatorTokenType.plus => '+',
      OperatorTokenType.minus => '-',
      OperatorTokenType.multiply => '×',
      OperatorTokenType.divide => '÷',
      OperatorTokenType.power => '^',
    };
  }
}

class FunctionToken extends Token {
  const FunctionToken(this.function);

  const FunctionToken.square() : function = MathFunction.square;
  const FunctionToken.cos() : function = MathFunction.cos;
  const FunctionToken.sin() : function = MathFunction.sin;
  const FunctionToken.tan() : function = MathFunction.tan;
  const FunctionToken.squareRoot() : function = MathFunction.squareRoot;
  const FunctionToken.percent() : function = MathFunction.percent;

  final MathFunction function;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FunctionToken && other.function == function;
  }

  @override
  int get hashCode => function.hashCode;

  @override
  String toString() {
    return '{$function}';
  }
}

class ConstantToken extends Token {
  const ConstantToken(this.name);
  final Constant name;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConstantToken && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() {
    return '[$name]';
  }
}

class EqualsToken extends Token {
  const EqualsToken();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CommandToken;
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() {
    return '=';
  }
}

/// For representing commands that do not fit into other categories.
class CommandToken extends Token {
  const CommandToken(this.command);
  final CommandToken command;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CommandToken && other.command == command;
  }

  @override
  int get hashCode => command.hashCode;

  @override
  String toString() {
    return 'cmd.$command.';
  }
}
