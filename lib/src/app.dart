import 'package:omarchy_calculator/src/engine/command.dart';
import 'package:omarchy_calculator/src/notifier.dart';
import 'package:omarchy_calculator/src/widgets/buttons.dart';
import 'package:omarchy_calculator/src/widgets/display.dart';
import 'package:omarchy_calculator/src/widgets/history.dart';
import 'package:flutter_omarchy/flutter_omarchy.dart';
import 'package:omarchy_calculator/src/widgets/shortcuts.dart';

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
    return AppShortcuts(
      onCommand: (command) {
        final sim = _simulatedPress[command];
        sim?.press();
        notifier.execute(command);
      },
      child: AnimatedBuilder(
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
                            onSelect: (v) {
                              notifier.restore(v);
                            },
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

                return child;
              },
            ),
          );
        },
      ),
    );
  }
}

class CommandIntent extends Intent {
  const CommandIntent(this.command);
  final Command command;
}

class CommandAction extends Action<CommandIntent> {
  CommandAction(this.simulatedPress);

  final Map<Command, SimulatedPressController> simulatedPress;

  @override
  void invoke(covariant CommandIntent intent) {
    simulatedPress[intent.command]?.press();
  }
}
