import 'package:calc_engine/calc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class AppShortcuts extends StatefulWidget {
  const AppShortcuts({
    super.key,
    this.shortcuts,
    required this.child,
    required this.onCommand,
  });

  static final defaultShortcuts = {
    LogicalKeyboardKey.digit0: Command.digit(0),
    LogicalKeyboardKey.digit1: Command.digit(1),
    LogicalKeyboardKey.digit2: Command.digit(2),
    LogicalKeyboardKey.digit3: Command.digit(3),
    LogicalKeyboardKey.digit4: Command.digit(4),
    LogicalKeyboardKey.digit5: Command.digit(5),
    LogicalKeyboardKey.digit6: Command.digit(6),
    LogicalKeyboardKey.digit7: Command.digit(7),
    LogicalKeyboardKey.digit8: Command.digit(8),
    LogicalKeyboardKey.digit9: Command.digit(9),
    LogicalKeyboardKey.parenthesisLeft: Command.openParenthesis(),
    LogicalKeyboardKey.parenthesisRight: Command.closeParenthesis(),
    LogicalKeyboardKey.comma: Command.decimalPoint(),
    LogicalKeyboardKey.period: Command.decimalPoint(),
    LogicalKeyboardKey.percent: Command.function('percent'),
    LogicalKeyboardKey.equal: Command.equals(),
    LogicalKeyboardKey.enter: Command.equals(),
    LogicalKeyboardKey.numpadEqual: Command.equals(),
    LogicalKeyboardKey.asterisk: Command.operator(OperatorType.multiply),
    LogicalKeyboardKey.numpadMultiply: Command.operator(OperatorType.multiply),
    LogicalKeyboardKey.keyX: Command.operator(OperatorType.multiply),
    LogicalKeyboardKey.slash: Command.operator(OperatorType.divide),
    LogicalKeyboardKey.numpadDivide: Command.operator(OperatorType.divide),
    LogicalKeyboardKey.minus: Command.operator(OperatorType.minus),
    LogicalKeyboardKey.add: Command.operator(OperatorType.plus),
    LogicalKeyboardKey.backspace: Command.backspace(),
  };

  final Map<LogicalKeyboardKey, Command>? shortcuts;
  final ValueChanged<Command> onCommand;
  final Widget child;

  @override
  State<AppShortcuts> createState() => _AppShortcutsState();
}

class _AppShortcutsState extends State<AppShortcuts> {
  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handler);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handler);
    super.dispose();
  }

  bool _handler(KeyEvent event) {
    if (event is KeyDownEvent) {
      final shortcuts = widget.shortcuts ?? AppShortcuts.defaultShortcuts;
      final shortcut = shortcuts[event.logicalKey];
      if (shortcut != null) widget.onCommand(shortcut);
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
