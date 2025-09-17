import 'dart:async';

import 'package:omarchy_calculator/src/commands.dart';
import 'package:omarchy_calculator/src/features/calculator/screen.dart';
import 'package:omarchy_calculator/src/features/calculator/state/event.dart';
import 'package:omarchy_calculator/src/features/calculator/state/notifier.dart';
import 'package:omarchy_calculator/src/features/config/state/config.dart';
import 'package:omarchy_calculator/src/features/config/state/notifier.dart';
import 'package:omarchy_calculator/src/features/history/screen.dart';
import 'package:flutter_omarchy/flutter_omarchy.dart';
import 'package:omarchy_calculator/src/features/history/state/notifier.dart';
import 'package:omarchy_calculator/src/widgets/shortcuts.dart';

class CalculatorApp extends StatefulWidget {
  const CalculatorApp({
    super.key,
    this.theme,
    this.config,
    this.calculator,
    this.history,
  });

  final CalculatorNotifier? calculator;
  final HistoryNotifier? history;
  final ConfigNotifier? config;
  final OmarchyThemeData? theme;

  @override
  State<CalculatorApp> createState() => _CalculatorAppState();
}

class _CalculatorAppState extends State<CalculatorApp> {
  late final calculator = widget.calculator ?? CalculatorNotifier();
  late final history =
      widget.history ?? HistoryNotifier(context: calculator.context);
  late final config = widget.config ?? ConfigNotifier();

  @override
  void dispose() {
    calculator.dispose();
    history.dispose();
    config.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotifiersScope(
      calculator: calculator,
      history: history,
      child: OmarchyApp(
        debugShowCheckedModeBanner: false,
        theme: widget.theme,
        home: const AppLayout(),
      ),
    );
  }
}

class AppLayout extends StatefulWidget {
  const AppLayout({super.key});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  final layouts = [ButtonLayout.base(), ButtonLayout.scientific()];
  final _mainPane = GlobalKey();
  NotifiersScope? scope;
  final _appCommands = StreamController<AppCommand>.broadcast();
  StreamSubscription<CalculatorEvent>? _calculatorEvents;
  final OmarchySidePanelController _sidePanelController =
      OmarchySidePanelController();

  void _onCalculatorEvent(CalculatorEvent event) {
    if (event is CalculatorCalculateResultEvent) {
      scope?.history.addToHistory(event.state);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _calculatorEvents?.cancel();
    scope = NotifiersScope.of(context);
    _calculatorEvents = scope?.calculator.events.listen(_onCalculatorEvent);
  }

  @override
  void dispose() {
    super.dispose();
    _calculatorEvents?.cancel();
    _sidePanelController.dispose();
  }

  void toggleHistory() {
    _sidePanelController.isVisible = !_sidePanelController.isVisible;
  }

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    final scope = NotifiersScope.of(context);
    return AppShortcuts(
      onCommand: (command) {
        switch (command) {
          case CalculatorCommand(:final command):
            scope.calculator.execute(command);
          case ToggleHistoryCommand():
            toggleHistory();
          case NextButtonLayoutCommand():
          case PreviousButtonLayoutCommand():
            _appCommands.add(command);
        }
      },
      child: OmarchyScaffold(
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
            final isHistorySidePanel =
                layout.maxWidth >
                layouts.length * CalculatorScreen.gridWidth + 500;
            final calc = CalculatorScreen(
              key: _mainPane,
              appCommands: _appCommands.stream,
              onOpenHistory: toggleHistory,
              layouts: layouts,
            );
            final historyPanel = FadeIn(
              child: HistoryScreen(
                onSelect: (v) {
                  scope.calculator.restore(v);
                },
              ),
            );
            if (isHistorySidePanel) {
              return AnimatedBuilder(
                animation: _sidePanelController,
                builder: (context, _) {
                  if (_sidePanelController.isVisible) {
                    return Row(
                      children: [
                        Expanded(child: historyPanel),
                        OmarchyDivider.horizontal(),
                        SizedBox(width: 1000, child: calc),
                      ],
                    );
                  }
                  return calc;
                },
              );
            }
            return OmarchySidePanel(
              controller: _sidePanelController,
              panel: historyPanel,
              child: calc,
            );
          },
        ),
      ),
    );
  }
}

class NotifiersScope extends InheritedWidget {
  const NotifiersScope({
    super.key,
    required super.child,
    required this.calculator,
    required this.history,
  });
  final CalculatorNotifier calculator;
  final HistoryNotifier history;

  static NotifiersScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<NotifiersScope>();
    if (scope == null) {
      throw Exception('No NotifiersScope found in context');
    }
    return scope;
  }

  @override
  bool updateShouldNotify(covariant NotifiersScope oldWidget) =>
      calculator != oldWidget.calculator || history != oldWidget.history;
}
