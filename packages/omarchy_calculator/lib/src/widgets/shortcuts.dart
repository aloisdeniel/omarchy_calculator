import 'package:calc_engine/calc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class AppShortcut {
  const AppShortcut(
    this.command, {
    this.characters = const [],
    this.keys = const [],
  });

  final List<String> characters;
  final List<LogicalKeyboardKey> keys;
  final Command command;
}

class AppShortcuts extends StatefulWidget {
  const AppShortcuts({
    super.key,
    this.shortcuts,
    required this.child,
    required this.onCommand,
  });

  static final defaultShortcuts = [
    AppShortcut(Command.digit(0), characters: ['0']),
    AppShortcut(Command.digit(1), characters: ['1']),
    AppShortcut(Command.digit(2), characters: ['2']),
    AppShortcut(Command.digit(3), characters: ['3']),
    AppShortcut(Command.digit(4), characters: ['4']),
    AppShortcut(Command.digit(5), characters: ['5']),
    AppShortcut(Command.digit(6), characters: ['6']),
    AppShortcut(Command.digit(7), characters: ['7']),
    AppShortcut(Command.digit(8), characters: ['8']),
    AppShortcut(Command.digit(9), characters: ['9']),
    AppShortcut(Command.openParenthesis(), characters: ['(']),
    AppShortcut(Command.closeParenthesis(), characters: [')']),
    AppShortcut(Command.decimalPoint(), characters: ['.', ',']),
    AppShortcut(Command.function('percent'), characters: ['%']),
    AppShortcut(
      Command.equals(),
      characters: ['='],
      keys: [LogicalKeyboardKey.enter],
    ),
    AppShortcut(
      Command.operator(OperatorType.multiply),
      characters: ['*'],
      keys: [LogicalKeyboardKey.numpadMultiply],
    ),
    AppShortcut(
      Command.operator(OperatorType.divide),
      characters: ['/'],
      keys: [LogicalKeyboardKey.numpadDivide],
    ),
    AppShortcut(
      Command.operator(OperatorType.minus),
      characters: ['-'],
      keys: [LogicalKeyboardKey.numpadSubtract],
    ),
    AppShortcut(
      Command.operator(OperatorType.plus),
      characters: ['+'],
      keys: [LogicalKeyboardKey.numpadAdd],
    ),
    AppShortcut(Command.backspace(), keys: [LogicalKeyboardKey.backspace]),
  ];

  final List<AppShortcut>? shortcuts;
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
      final shortcut = shortcuts
          .where((x) {
            return x.characters.contains(event.character) ||
                x.keys.contains(event.logicalKey);
          })
          .map((e) => e.command)
          .firstOrNull;
      if (shortcut != null) widget.onCommand(shortcut);
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
