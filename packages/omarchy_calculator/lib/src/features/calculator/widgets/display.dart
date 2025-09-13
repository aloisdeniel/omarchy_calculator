import 'package:calc_engine/calc_engine.dart';
import 'package:flutter/material.dart' show SelectableText;
import 'package:flutter_omarchy/flutter_omarchy.dart';
import 'package:omarchy_calculator/src/features/calculator/state/notifier.dart';
import 'package:omarchy_calculator/src/widgets/expression.dart';

class Display extends StatelessWidget {
  const Display({super.key, required this.state, required this.isCondensed});
  final CalculatorState state;
  final bool isCondensed;

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    return SizedBox(
      height: isCondensed ? 72 : 134,
      child: LayoutBuilder(
        builder: (context, layout) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Stack(
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: layout.maxWidth,
                      maxWidth: double.infinity,
                    ),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: state.isResult ? 0.5 : 1,
                      child: SingleChildScrollView(
                        reverse: true,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 14.0),
                        child: ExpressionView(
                          key: Key('details'),
                          state.context,
                          state.expression,
                          state.result,
                          fontSize: isCondensed ? 16 : 24,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 28,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colors.background,
                            theme.colors.background.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    width: 14,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colors.background.withValues(alpha: 0),
                            theme.colors.background,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                key: Key('result'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: _ResultDisplay(state, isCondensed: isCondensed),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ResultDisplay extends StatelessWidget {
  const _ResultDisplay(this.state, {required this.isCondensed});

  final CalculatorState state;
  final bool isCondensed;

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    final text = switch (state.result) {
      FailureEval(:final error) => error.toString(),
      SuccessEval() when state.input.isNotEmpty => state.input,
      SuccessEval(:final result) => result.toString(),
    };
    final color = switch (state.result) {
      FailureEval() => theme.colors.bright.red,
      SuccessEval() when state.isResult => theme.colors.bright.green,
      SuccessEval() => null,
    };
    return FittedBox(
      key: ValueKey(color),
      child: SelectableText(
        text,
        style: TextStyle(
          fontSize: isCondensed ? 48 : 88,
        ).copyWith(color: color),
        maxLines: 1,
        cursorColor: theme.colors.normal.white,
        selectionColor: theme.colors.normal.white,
        textAlign: TextAlign.right,
      ),
    );
  }
}
