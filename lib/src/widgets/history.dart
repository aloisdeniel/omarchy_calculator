import 'package:flutter_omarchy/flutter_omarchy.dart';
import 'package:flutter_omarchy/src/widgets/utils/default_foreground.dart';
import 'package:intl/intl.dart';
import 'package:omarchy_calculator/src/notifier.dart';
import 'package:omarchy_calculator/src/widgets/expression.dart';

class HistoryPane extends StatelessWidget {
  const HistoryPane({
    super.key,
    required this.onClear,
    required this.history,
    required this.onSelect,
  });

  final ValueChanged<CalculatorState> onSelect;
  final List<CalculatorState> history;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    return Stack(
      children: [
        switch (history) {
          [] => const _Empty(),
          _ => _Items(history: history, onSelect: onSelect),
        },
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 64,
          child: IgnorePointer(
            child: Container(
              padding: const EdgeInsets.all(14.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    theme.colors.background,
                    theme.colors.background,
                    theme.colors.background.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(),
            child: Row(
              children: [
                OmarchyButton(
                  style: OmarchyButtonStyle.filled(AnsiColor.red),
                  onPressed: onClear,
                  child: Text('Clear'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Items extends StatelessWidget {
  const _Items({required this.history, required this.onSelect});

  final ValueChanged<CalculatorState> onSelect;
  final List<CalculatorState> history;

  @override
  Widget build(BuildContext context) {
    final groupedByDay = <(DateTime, List<CalculatorState>)>[];

    for (final item in history) {
      final day = DateTime(
        item.dateTime.year,
        item.dateTime.month,
        item.dateTime.day,
      );

      final index = groupedByDay.indexWhere((e) => e.$1 == day);
      if (index == -1) {
        groupedByDay.add((day, [item]));
      } else {
        groupedByDay[index].$2.add(item);
      }
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 64),
      children: [
        for (final (date, items) in groupedByDay) ...[
          _HeaderTile(date),
          for (final item in items)
            FadeIn(
              key: ValueKey(item.id),
              child: _HistoryTile(item, onTap: () => onSelect(item)),
            ),
        ],
      ],
    );
  }
}

class _HeaderTile extends StatelessWidget {
  const _HeaderTile(this.date);

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(14),
      child: Text(
        DateFormat.yMMMMd().format(date).toUpperCase(),
        style: OmarchyTheme.of(context).text.bold.copyWith(
          fontSize: 14,
          color: OmarchyTheme.of(context).colors.normal.white,
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile(this.item, {required this.onTap});

  final CalculatorState item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    var child = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 2,
      children: [
        Text(
          DateFormat.Hm().format(item.dateTime),
          style: theme.text.normal.copyWith(
            color: theme.colors.bright.black,
            fontSize: 11,
          ),
        ),
        ExpressionView(
          item,
          withResult: true,
          fontSize: 12,
          textAlign: TextAlign.start,
        ),
      ],
    );
    final isSelected = Selected.of(context);
    return PointerArea(
      onTap: onTap,
      child: child,
      builder: (context, state, child) {
        final background = theme.colors.normal.black;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            color: switch (state) {
              PointerState(isPressed: true) => background,
              PointerState(isHovering: true) => background.withValues(
                alpha: 0.5,
              ),
              _ => background.withValues(alpha: 0),
            },
          ),
          padding: EdgeInsets.all(14),
          child: DefaultForeground(
            textStyle: switch (isSelected) {
              true => theme.text.italic,
              false => theme.text.normal,
            },
            foreground: switch (state) {
              _ when isSelected => theme.colors.selectedText,
              PointerState(isPressed: true) => theme.colors.selectedText,
              PointerState(isHovering: true) => theme.colors.selectedText,
              _ => theme.colors.foreground,
            },
            child: child!,
          ),
        );
      },
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Center(
        child: Text(
          'No history yet',
          style: theme.text.bold.copyWith(
            fontSize: 18,
            color: theme.colors.bright.black,
          ),
        ),
      ),
    );
  }
}
