import 'dart:async';
import 'dart:math' as math;

import 'package:calc_engine/calc_engine.dart';
import 'package:flutter_omarchy/flutter_omarchy.dart';
import 'package:omarchy_calculator/src/app.dart';
import 'package:omarchy_calculator/src/features/calculator/state/event.dart';
import 'package:omarchy_calculator/src/features/calculator/state/notifier.dart';
import 'package:omarchy_calculator/src/features/config/state/config.dart';

class ButtonGrid extends StatefulWidget {
  const ButtonGrid({
    super.key,

    required this.layouts,
    required this.selectedLayout,
    required this.onPressed,
    this.spacing = 4.0,
    this.onOpenHistory,
  });

  final VoidCallback? onOpenHistory;
  final List<ButtonLayout> layouts;
  final int selectedLayout;
  final ValueChanged<Command> onPressed;
  final double spacing;

  @override
  State<ButtonGrid> createState() => _ButtonGridState();
}

class _ButtonGridState extends State<ButtonGrid> {
  late var selectedLayout = widget.selectedLayout;

  Iterable<List<Widget>> get rows sync* {
    final layout = widget.layouts[selectedLayout];
    final buttons = layout.buttons;
    var rowWidth = 0;
    var row = <Widget>[];
    for (var i = 0; i < buttons.length; i += 1) {
      final button = layout.buttons[i];
      final size = math.min(button.size, 4 - rowWidth);
      if (rowWidth + size > 4) {
        // yield current row
        yield row;
        // start new row
        row = [];
        rowWidth = 0;
      }
      row.add(
        Expanded(
          flex: size,
          child: CalculatorButton(
            button,
            key: ValueKey(button.command),
            onPressed: () => widget.onPressed(button.command),
          ),
        ),
      );
      rowWidth += size;
      if (rowWidth >= 4) {
        yield row;
        row = [];
        rowWidth = 0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, layout) {
        return Column(
          spacing: widget.spacing,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _LayoutPicker(
              onOpenHistory: widget.onOpenHistory,
              layouts: widget.layouts,
              selectedLayout: selectedLayout,
              onChanged: (i) {
                setState(() {
                  selectedLayout = i;
                });
              },
            ),
            for (final row in rows)
              Expanded(
                child: Row(spacing: widget.spacing, children: [...row]),
              ),
          ],
        );
      },
    );
  }
}

class CalculatorButton extends StatefulWidget {
  const CalculatorButton(this.button, {super.key, required this.onPressed});

  final Button button;
  final VoidCallback onPressed;

  @override
  State<CalculatorButton> createState() => _CalculatorButtonState();
}

class _CalculatorButtonState extends State<CalculatorButton> {
  final _simulatedPress = SimulatedPressController();
  StreamSubscription<CalculatorEvent>? _subscription;

  Button button(CalculatorNotifier notifier) {
    var button = widget.button;
    if (button.command == Command.clearAll() && notifier.state.canDelete) {
      return Button(
        label: 'C',
        icon: OmarchyIcons.mdBackspaceOutline,
        command: Command.backspace(),
        color: button.color,
        size: button.size,
      );
    }
    return button;
  }

  Widget symbol(Button button, bool isSmall) {
    return switch (button.icon) {
      IconData data => Icon(data, size: isSmall ? 30 : 48),
      null => Text(button.label, style: TextStyle(fontSize: isSmall ? 20 : 32)),
    };
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final notifier = NotifiersScope.of(context).calculator;
    _subscription?.cancel();
    _subscription = notifier.events.listen((e) {
      if (e case CalculatorCommandEvent(
        :final command,
      ) when command == widget.button.command) {
        _simulatedPress.press();
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _simulatedPress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = NotifiersScope.of(context).calculator;

    return FadeIn(
      child: LayoutBuilder(
        builder: (context, layout) {
          final isSmall = layout.maxHeight < 75 || layout.maxWidth < 80;
          return AnimatedBuilder(
            animation: notifier,
            builder: (context, _) {
              final button = this.button(notifier);
              return SimulatedPress(
                controller: _simulatedPress,
                child: OmarchyButton(
                  style: OmarchyButtonStyle.filled(
                    widget.button.color,
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: widget.onPressed,
                  child: Center(child: symbol(button, isSmall)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _LayoutPicker extends StatelessWidget {
  const _LayoutPicker({
    required this.layouts,
    required this.onChanged,
    required this.selectedLayout,
    required this.onOpenHistory,
  });

  final VoidCallback? onOpenHistory;
  final ValueChanged<int> onChanged;
  final List<ButtonLayout> layouts;
  final int selectedLayout;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 4,
        children: [
          if (onOpenHistory != null)
            OmarchyButton(
              style: OmarchyButtonStyle.filled(AnsiColor.black),
              onPressed: onOpenHistory,
              child: Icon(OmarchyIcons.codMenu),
            ),
          for (var i = 0; i < layouts.length; i += 1)
            OmarchyButton(
              style: OmarchyButtonStyle.bar(
                i == selectedLayout && layouts.length > 1
                    ? AnsiColor.white
                    : AnsiColor.black,
              ),
              onPressed: () {
                if (i != selectedLayout) {
                  onChanged(i);
                }
              },
              child: Text(layouts[i].name),
            ),
        ],
      ),
    );
  }
}
