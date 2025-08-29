import 'package:omarchy_calculator/src/engine/command.dart';
import 'package:omarchy_calculator/src/notifier.dart';
import 'package:omarchy_calculator/src/widgets/buttons.dart';
import 'package:omarchy_calculator/src/widgets/display.dart';
import 'package:omarchy_calculator/src/widgets/history.dart';
import 'package:flutter/services.dart';
import 'package:flutter_omarchy/flutter_omarchy.dart';

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return OmarchyApp(
      debugShowCheckedModeBanner: false,
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final notifier = CalculatorNotifier();
  final _focusNode = FocusNode();
  final _mainPane = GlobalKey();

  final _simulatedPress = <Command, SimulatedPressController>{
    for (final row in ButtonGrid.rows)
      for (final action in row) action: SimulatedPressController(),
  };

  @override
  void dispose() {
    super.dispose();
    for (final controller in _simulatedPress.values) {
      controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    return AnimatedBuilder(
      animation: notifier,
      builder: (context, _) {
        return OmarchyScaffold(
          child: LayoutBuilder(
            builder: (context, layout) {
              if (layout.maxWidth < 40 || layout.maxHeight < 84) {
                return Center(
                  child: Icon(
                    OmarchyIcons.faMaximize,
                    color: theme.colors.normal.black,
                  ),
                );
              }
              Widget child = Column(
                key: _mainPane,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 14),
                  Display(
                    state: notifier.state,
                    isCondensed: layout.maxHeight < 1000,
                  ),
                  if (layout.maxWidth > 100 && layout.maxHeight > 220) ...[
                    const SizedBox(height: 14),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 14.0,
                          right: 14.0,
                          bottom: 14.0,
                        ),
                        child: ButtonGrid(
                          simulated: _simulatedPress,
                          onPressed: (action) {
                            setState(() {
                              notifier.execute(action);
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ],
              );

              if (layout.maxWidth > 1200) {
                child = Row(
                  children: [
                    Expanded(
                      child: FadeIn(
                        child: HistoryPane(
                          history: notifier.history,
                          onSelect: (v) {},
                          onClear: notifier.history.isNotEmpty
                              ? () {
                                  notifier.clearHistory();
                                }
                              : null,
                        ),
                      ),
                    ),
                    OmarchyDivider.horizontal(),
                    SizedBox(width: 1000, child: child),
                  ],
                );
              }

              return Focus(
                focusNode: _focusNode,
                descendantsAreFocusable: true,
                skipTraversal: false,
                autofocus: true,
                onKeyEvent: (node, event) {
                  print(' event: $event');
                  if (event is! KeyDownEvent) return KeyEventResult.ignored;
                  void press(Command action) {
                    setState(() {
                      notifier.execute(action);
                    });
                    _simulatedPress[action]?.press();
                  }

                  if (event.logicalKey == LogicalKeyboardKey.digit0 ||
                      event.logicalKey == LogicalKeyboardKey.numpad0) {
                    press(const Digit(0));
                    return KeyEventResult.handled;
                  }
                  if (event.logicalKey == LogicalKeyboardKey.digit1 ||
                      event.logicalKey == LogicalKeyboardKey.numpad1) {
                    press(const Digit(1));
                    return KeyEventResult.handled;
                  }
                  if (event.logicalKey == LogicalKeyboardKey.digit2 ||
                      event.logicalKey == LogicalKeyboardKey.numpad2) {
                    press(const Digit(2));
                    return KeyEventResult.handled;
                  }
                  if (event.logicalKey == LogicalKeyboardKey.digit3 ||
                      event.logicalKey == LogicalKeyboardKey.numpad3) {
                    press(const Digit(3));
                    return KeyEventResult.handled;
                  }
                  if (event.logicalKey == LogicalKeyboardKey.digit4 ||
                      event.logicalKey == LogicalKeyboardKey.numpad4) {
                    press(const Digit(4));
                    return KeyEventResult.handled;
                  }
                  if (event.logicalKey == LogicalKeyboardKey.digit5 ||
                      event.logicalKey == LogicalKeyboardKey.numpad5) {
                    press(const Digit(5));
                    return KeyEventResult.handled;
                  }
                  if (event.logicalKey == LogicalKeyboardKey.digit6 ||
                      event.logicalKey == LogicalKeyboardKey.numpad6) {
                    press(const Digit(6));
                    return KeyEventResult.handled;
                  }
                  if (event.logicalKey == LogicalKeyboardKey.digit7 ||
                      event.logicalKey == LogicalKeyboardKey.numpad7) {
                    press(const Digit(7));
                    return KeyEventResult.handled;
                  }
                  if (event.logicalKey == LogicalKeyboardKey.digit8 ||
                      event.logicalKey == LogicalKeyboardKey.numpad8) {
                    press(const Digit(8));
                    return KeyEventResult.handled;
                  }
                  if (event.logicalKey == LogicalKeyboardKey.digit9 ||
                      event.logicalKey == LogicalKeyboardKey.numpad9) {
                    press(const Digit(9));
                    return KeyEventResult.handled;
                  }
                  if (event.logicalKey == LogicalKeyboardKey.add ||
                      event.logicalKey == LogicalKeyboardKey.numpadAdd ||
                      event.character == '+') {
                    press(const Operator.plus());
                    return KeyEventResult.handled;
                  }
                  if (event.logicalKey == LogicalKeyboardKey.asterisk ||
                      event.logicalKey == LogicalKeyboardKey.numpadMultiply ||
                      event.character == '*') {
                    press(const Operator.multiply());
                    return KeyEventResult.handled;
                  }
                  if (event.logicalKey == LogicalKeyboardKey.minus ||
                      event.logicalKey == LogicalKeyboardKey.numpadSubtract ||
                      event.character == '-') {
                    press(const Operator.minus());
                    return KeyEventResult.handled;
                  }
                  if (event.logicalKey == LogicalKeyboardKey.slash ||
                      event.logicalKey == LogicalKeyboardKey.numpadDivide ||
                      event.character == '/') {
                    press(const Operator.divide());
                    return KeyEventResult.handled;
                  }
                  if (event.logicalKey == LogicalKeyboardKey.equal ||
                      event.logicalKey == LogicalKeyboardKey.enter ||
                      event.logicalKey == LogicalKeyboardKey.numpadEnter ||
                      event.logicalKey == LogicalKeyboardKey.numpadEqual ||
                      event.character == '=') {
                    press(const Equals());
                    return KeyEventResult.handled;
                  }
                  if (event.logicalKey == LogicalKeyboardKey.period ||
                      event.logicalKey == LogicalKeyboardKey.comma ||
                      event.logicalKey == LogicalKeyboardKey.numpadDecimal ||
                      event.character == '.' ||
                      event.character == ',') {
                    press(const DecimalPoint());
                    return KeyEventResult.handled;
                  }
                  if (event.logicalKey == LogicalKeyboardKey.delete ||
                      event.logicalKey == LogicalKeyboardKey.backspace) {
                    press(const Backspace());
                    return KeyEventResult.handled;
                  }
                  return KeyEventResult.ignored;
                },
                child: child,
              );
            },
          ),
        );
      },
    );
  }
}
