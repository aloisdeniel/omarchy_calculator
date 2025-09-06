import 'package:omarchy_calculator/src/engine/base.dart';

/// Base class for calculator actions.
sealed class Command {
  const Command();

  /// Parse a string [input] into a list of commands.
  ///
  /// Ignores unrecognized characters and patterns.
  static List<Command> parse(String input) {
    final commands = <Command>[];

    for (var i = 0; i < input.length; i++) {
      final char = input[i];
      switch (char) {
        case ' ' || '\t' || '\r' || '\n':
          // Skip whitespaces
          break;
        case '0' || '1' || '2' || '3' || '4' || '5' || '6' || '7' || '8' || '9':
          commands.add(Command.digit(int.parse(char)));
        case '*' || 'x' || '×':
          commands.add(const Command.operator(OperatorType.multiply));
        case '/' || '÷':
          commands.add(const Command.operator(OperatorType.divide));
        case '+':
          commands.add(const Command.operator(OperatorType.plus));
        case '-':
          commands.add(const Command.operator(OperatorType.minus));
        case '.' || ',':
          commands.add(const Command.decimalPoint());
        case '=':
          commands.add(const Command.equals());
        case '(':
          commands.add(const Command.openParenthesis());
        case ')':
          commands.add(const Command.closeParenthesis());
        case '^':
          commands.add(const Command.power());
        case 'π':
          commands.add(Command.pi());
        case 'e':
          commands.add(Command.euler());
        case '%':
          commands.add(const Command.percent());
        case '±':
          commands.add(const Command.toggleSign());
        case '√':
          commands.add(const Command.squareRoot());
        case '²':
          commands.add(const Command.square());
        default:
          const patterns = {
            'cos': Command.cosine(),
            'sin': Command.cosine(),
            'tan': Command.tangent(),
            'CA': Command.clearAll(),
            'CE': Command.clearEntry(),
            'BS': Command.backspace(),
            'pi': ConstantCommand(Constant.pi),
            'plus': Command.operator(OperatorType.plus),
            'minus': Command.operator(OperatorType.minus),
            'mul': Command.operator(OperatorType.multiply),
            'div': Command.operator(OperatorType.divide),
            'M+': Command.memoryAdd(),
            'M-': Command.memorySubtract(),
            'MR': Command.memoryRecall(),
            'MC': Command.memoryClear(),
            'sqr': Command.square(),
            'sqrt': Command.squareRoot(),
            'pow': Command.power(),
          };

          for (final pattern in patterns.entries) {
            if (input.startsWith(pattern.key, i)) {
              commands.add(pattern.value);
              i += pattern.key.length - 1;
              break;
            }
          }
      }
    }

    return commands;
  }

  const factory Command.digit(int value) = Digit;

  const factory Command.decimalPoint() = DecimalPoint;

  const factory Command.operator(OperatorType type) = Operator;

  const factory Command.equals() = Equals;

  const factory Command.clearAll() = ClearAll;

  const factory Command.clearEntry() = ClearEntry;

  const factory Command.backspace() = Backspace;

  const factory Command.toggleSign() = ToggleSign;

  const factory Command.percent() = Percent;

  const factory Command.squareRoot() = SquareRoot;

  const factory Command.square() = Square;

  const factory Command.memoryAdd() = MemoryAdd;

  const factory Command.memorySubtract() = MemorySubtract;

  const factory Command.memoryRecall() = MemoryRecall;

  const factory Command.memoryClear() = MemoryClear;

  const factory Command.power() = Power;

  const factory Command.openParenthesis() = OpenParenthesis;

  const factory Command.closeParenthesis() = CloseParenthesis;

  const factory Command.sine() = Sine;

  const factory Command.cosine() = Cosine;

  const factory Command.tangent() = Tangent;

  factory Command.pi() => const ConstantCommand(Constant.pi);

  factory Command.euler() => const ConstantCommand(Constant.euler);
}

class Digit extends Command {
  final int value; // must be 0..9
  const Digit(this.value) : assert(value >= 0 && value <= 9);

  @override
  String toString() {
    return value.toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Digit && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;
}

class DecimalPoint extends Command {
  const DecimalPoint();

  @override
  String toString() {
    return '.';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DecimalPoint;
  }

  @override
  int get hashCode => runtimeType.hashCode;
}

class Operator extends Command {
  final OperatorType type;
  const Operator(this.type);

  const Operator.plus() : type = OperatorType.plus;
  const Operator.minus() : type = OperatorType.minus;
  const Operator.multiply() : type = OperatorType.multiply;
  const Operator.divide() : type = OperatorType.divide;
  const Operator.power() : type = OperatorType.power;

  @override
  String toString() {
    return type.toSymbol();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Operator && other.type == type;
  }

  @override
  int get hashCode => type.hashCode;
}

enum OperatorType {
  plus,
  minus,
  multiply,
  divide,
  power;

  String toSymbol() {
    switch (this) {
      case OperatorType.plus:
        return '+';
      case OperatorType.minus:
        return '-';
      case OperatorType.multiply:
        return '×';
      case OperatorType.divide:
        return '÷';
      case OperatorType.power:
        return '^';
    }
  }
}

/// Evaluate the current expression
class Equals extends Command {
  const Equals();
  @override
  String toString() {
    return '=';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Equals;
  }

  @override
  int get hashCode => runtimeType.hashCode;
}

/// Clear everything (AC)
class ClearAll extends Command {
  const ClearAll();
  @override
  String toString() {
    return 'AC';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClearAll;
  }

  @override
  int get hashCode => runtimeType.hashCode;
}

/// Clear only the current entry (CE)
class ClearEntry extends Command {
  const ClearEntry();
  @override
  String toString() {
    return 'CE';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClearEntry;
  }

  @override
  int get hashCode => runtimeType.hashCode;
}

/// Delete last character of the current entry
class Backspace extends Command {
  const Backspace();

  @override
  String toString() {
    return 'CE';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Backspace;
  }

  @override
  int get hashCode => runtimeType.hashCode;
}

/// Toggle sign of the current entry (±)
class ToggleSign extends Command {
  const ToggleSign();

  @override
  String toString() {
    return '±';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ToggleSign;
  }

  @override
  int get hashCode => runtimeType.hashCode;
}

/// Convert current entry to a percentage (divide by 100)
class Percent extends Command {
  const Percent();

  @override
  String toString() {
    return '%';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Percent;
  }

  @override
  int get hashCode => runtimeType.hashCode;
}

/// Calculate square root of the current entry
class SquareRoot extends Command {
  const SquareRoot();

  @override
  String toString() {
    return '√';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SquareRoot;
  }

  @override
  int get hashCode => runtimeType.hashCode;
}

/// Calculate square of the current entry
class Square extends Command {
  const Square();

  @override
  String toString() {
    return 'x²';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Square;
  }

  @override
  int get hashCode => runtimeType.hashCode;
}

/// Memory operations
sealed class Memory extends Command {
  const Memory();
}

/// Memory store (M+)
class MemoryAdd extends Memory {
  const MemoryAdd();

  @override
  String toString() {
    return 'M+';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MemoryAdd;
  }

  @override
  int get hashCode => runtimeType.hashCode;
}

/// Memory subtract (M-)
class MemorySubtract extends Memory {
  const MemorySubtract();

  @override
  String toString() {
    return 'M-';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MemorySubtract;
  }

  @override
  int get hashCode => runtimeType.hashCode;
}

/// Memory recall (MR)
class MemoryRecall extends Memory {
  const MemoryRecall();

  @override
  String toString() {
    return 'MR';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MemoryRecall;
  }

  @override
  int get hashCode => runtimeType.hashCode;
}

/// Memory clear (MC)
class MemoryClear extends Memory {
  const MemoryClear();

  @override
  String toString() {
    return 'MC';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MemoryClear;
  }

  @override
  int get hashCode => runtimeType.hashCode;
}

/// Power operation (x^y)
class Power extends Command {
  const Power();

  @override
  String toString() {
    return 'x^y';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Power;
  }

  @override
  int get hashCode => runtimeType.hashCode;
}

/// Open parenthesis
class OpenParenthesis extends Command {
  const OpenParenthesis();

  @override
  String toString() {
    return '(';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OpenParenthesis;
  }

  @override
  int get hashCode => runtimeType.hashCode;
}

/// Close parenthesis
class CloseParenthesis extends Command {
  const CloseParenthesis();

  @override
  String toString() {
    return ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CloseParenthesis;
  }

  @override
  int get hashCode => runtimeType.hashCode;
}

/// Trigonometric operations
sealed class Trigonometric extends Command {
  const Trigonometric();
}

/// Sine function
class Sine extends Trigonometric {
  const Sine();

  @override
  String toString() {
    return 'sin';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Sine;
  }

  @override
  int get hashCode => runtimeType.hashCode;
}

/// Cosine function
class Cosine extends Trigonometric {
  const Cosine();

  @override
  String toString() {
    return 'cos';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Cosine;
  }

  @override
  int get hashCode => runtimeType.hashCode;
}

/// Tangent function
class Tangent extends Trigonometric {
  const Tangent();

  @override
  String toString() {
    return 'tan';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Tangent;
  }

  @override
  int get hashCode => runtimeType.hashCode;
}

/// Pi constant (π)
class ConstantCommand extends Command {
  const ConstantCommand(this.constant);

  final Constant constant;

  @override
  String toString() {
    return constant.toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConstantCommand && other.constant == constant;
  }

  @override
  int get hashCode => runtimeType.hashCode;
}
