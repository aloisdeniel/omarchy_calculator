import 'package:omarchy_calculator/src/engine/command.dart';

List<Token> tokenize(List<Command> commands) {
  var current = '';
  var currentIsNegative = false;
  final result = <Token>[];

  void flushCurrent() {
    if (current.isNotEmpty) {
      if (currentIsNegative) {
        current = '-$current';
      }
      if (current.endsWith('.')) {
        current = current.substring(0, current.length - 1);
      }
      result.add(NumberToken(current));
      current = '';
      currentIsNegative = false;
    }
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
        current = '';
        currentIsNegative = false;
        result.clear();
      case ClearEntry():
        current = '';
        currentIsNegative = false;
      case Backspace():
        if (current.isNotEmpty) {
          current = current.substring(0, current.length - 1);
        } else if (result.isNotEmpty) {
          final last = result.removeLast();
          if (last is NumberToken) {
            current = last.value;
            if (current.startsWith('-')) {
              currentIsNegative = true;
              current = current.substring(1);
            }
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
        result.add(const FunctionToken(FunctionTokenType.sin));
      case Cosine():
        flushCurrent();
        result.add(const FunctionToken(FunctionTokenType.cos));
      case Tangent():
        flushCurrent();
        result.add(const FunctionToken(FunctionTokenType.tan));
      case OpenParenthesis():
        flushCurrent();
        result.add(const ParenthesisToken.open());
      case CloseParenthesis():
        flushCurrent();
        result.add(const ParenthesisToken.close());
      case ConstantCommand(:final constant):
        flushCurrent();
        result.add(ConstantToken(constant));
      case Percent():
        flushCurrent();
        result.add(const OperatorToken(OperatorTokenType.percent));
      case SquareRoot():
        flushCurrent();
        result.add(const OperatorToken(OperatorTokenType.squareRoot));
      case Power():
        flushCurrent();
        result.add(const OperatorToken(OperatorTokenType.power));
      case Square():
        flushCurrent();
        result.add(const FunctionToken(FunctionTokenType.square));
      case Operator(type: OperatorType.plus):
        flushCurrent();
        result.add(const OperatorToken(OperatorTokenType.plus));
      case Operator(type: OperatorType.minus):
        if (current.isEmpty &&
            (i == 0 ||
                commands[i - 1] is Operator ||
                commands[i - 1] is OpenParenthesis)) {
          currentIsNegative = !currentIsNegative;
        } else {
          flushCurrent();
          result.add(const OperatorToken(OperatorTokenType.minus));
        }
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
        result.add(const OperatorToken(OperatorTokenType.equals));
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
    return 'op[${operator.name}]';
  }
}

enum OperatorTokenType {
  plus,
  minus,
  multiply,
  divide,
  power,
  squareRoot,
  percent,
  equals,
}

class FunctionToken extends Token {
  const FunctionToken(this.name);
  final FunctionTokenType name;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FunctionToken && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() {
    return 'func[${name.name}]';
  }
}

enum FunctionTokenType { square, sin, cos, tan }

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
    return 'const[${name.name}]';
  }
}

enum Constant { pi, euler }

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
    return 'cmd[$command]';
  }
}
