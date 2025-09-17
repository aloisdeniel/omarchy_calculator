import 'package:calc_engine/calc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:omarchy_calculator/src/commands.dart';

class AppShortcut {
  const AppShortcut(
    this.command, {
    this.characters = const [],
    this.keys = const [],
  });

  factory AppShortcut.calc(
    Command command, {
    List<String> characters = const [],
    List<LogicalKeyboardKey> keys = const [],
  }) => AppShortcut(
    CalculatorCommand(command),
    characters: characters,
    keys: keys,
  );

  final List<String> characters;
  final List<LogicalKeyboardKey> keys;
  final AppCommand command;
}

class AppShortcuts extends StatefulWidget {
  const AppShortcuts({
    super.key,
    this.shortcuts,
    required this.child,
    required this.onCommand,
  });

  static final defaultShortcuts = [
    AppShortcut.calc(Command.digit(0), characters: ['0']),
    AppShortcut.calc(Command.digit(1), characters: ['1']),
    AppShortcut.calc(Command.digit(2), characters: ['2']),
    AppShortcut.calc(Command.digit(3), characters: ['3']),
    AppShortcut.calc(Command.digit(4), characters: ['4']),
    AppShortcut.calc(Command.digit(5), characters: ['5']),
    AppShortcut.calc(Command.digit(6), characters: ['6']),
    AppShortcut.calc(Command.digit(7), characters: ['7']),
    AppShortcut.calc(Command.digit(8), characters: ['8']),
    AppShortcut.calc(Command.digit(9), characters: ['9']),
    AppShortcut.calc(Command.openParenthesis(), characters: ['(']),
    AppShortcut.calc(Command.closeParenthesis(), characters: [')']),
    AppShortcut.calc(Command.decimalPoint(), characters: ['.', ',']),
    AppShortcut.calc(Command.function('percent'), characters: ['%']),
    AppShortcut.calc(
      Command.equals(),
      characters: ['='],
      keys: [LogicalKeyboardKey.enter],
    ),
    AppShortcut.calc(
      Command.operator(OperatorType.multiply),
      characters: ['*'],
      keys: [LogicalKeyboardKey.numpadMultiply],
    ),
    AppShortcut.calc(
      Command.operator(OperatorType.divide),
      characters: ['/'],
      keys: [LogicalKeyboardKey.numpadDivide],
    ),
    AppShortcut.calc(
      Command.operator(OperatorType.minus),
      characters: ['-'],
      keys: [LogicalKeyboardKey.numpadSubtract],
    ),
    AppShortcut.calc(
      Command.operator(OperatorType.plus),
      characters: ['+'],
      keys: [LogicalKeyboardKey.numpadAdd],
    ),
    AppShortcut.calc(Command.backspace(), keys: [LogicalKeyboardKey.backspace]),
    AppShortcut(ToggleHistoryCommand(), keys: [LogicalKeyboardKey.escape]),
    AppShortcut(
      PreviousButtonLayoutCommand(),
      keys: [LogicalKeyboardKey.arrowLeft],
    ),
    AppShortcut(
      NextButtonLayoutCommand(),
      keys: [LogicalKeyboardKey.arrowRight],
    ),
  ];

  final List<AppShortcut>? shortcuts;
  final ValueChanged<AppCommand> onCommand;
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
