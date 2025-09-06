import 'package:calc_engine/calc_engine.dart';
import 'package:flutter_omarchy/flutter_omarchy.dart';
import 'package:omarchy_calculator/src/app.dart';
import 'package:omarchy_calculator/src/features/calculator/widgets/button_grid.dart';
import 'package:omarchy_calculator/src/features/calculator/widgets/display.dart';
import 'package:omarchy_calculator/src/features/config/state/config.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({
    super.key,
    required this.layouts,
    required this.onOpenHistory,
  });

  final VoidCallback? onOpenHistory;
  final List<ButtonLayout> layouts;

  static const gridWidth = 400.0;

  @override
  Widget build(BuildContext context) {
    final notifier = NotifiersScope.of(context).calculator;
    return AnimatedBuilder(
      animation: notifier,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, layout) {
            final visibleGrids = (layout.maxWidth / gridWidth).floor().clamp(
              1,
              layouts.length,
            );
            final grids = <Widget>[];
            for (var i = 0; i < visibleGrids; i += 1) {
              final isLast = i == visibleGrids - 1;
              final layouts = isLast ? this.layouts.skip(i) : [this.layouts[i]];
              grids.insert(
                0,
                Expanded(
                  key: ValueKey((visibleGrids, i)),
                  child: ButtonGrid(
                    selectedLayout: 0,
                    layouts: layouts.toList(),
                    onOpenHistory: isLast ? onOpenHistory : null,
                    onPressed: (action) {
                      if (action case FunctionCommand(
                        :final function,
                      ) when function.startsWith('::')) {
                        //TODO: Internal function
                        return;
                      }
                      notifier.execute(action);
                    },
                  ),
                ),
              );
            }

            return Column(
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
                      padding: const EdgeInsets.all(14.0),
                      child: Row(spacing: 14, children: grids),
                    ),
                  ),
                ],
              ],
            );
          },
        );
      },
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
