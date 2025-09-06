import 'package:flutter_omarchy/flutter_omarchy.dart';
import 'package:omarchy_calculator/src/engine/base.dart';
import 'package:omarchy_calculator/src/engine/eval.dart';
import 'package:omarchy_calculator/src/engine/parse.dart';
import 'package:omarchy_calculator/src/notifier.dart';

class ExpressionView extends StatelessWidget {
  const ExpressionView(
    this.state, {
    super.key,
    required this.fontSize,
    this.textAlign,
    this.withResult = false,
  });

  final double fontSize;
  final CalculatorState state;
  final TextAlign? textAlign;
  final bool withResult;

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    return Text.rich(
      TextSpan(
        children: [
          formatExpression(theme, state.expression),
          if (withResult)
            switch (state.result) {
              SuccessEval(:final result) => TextSpan(
                text: ' = $result',
                style: theme.text.bold.copyWith(
                  fontSize: fontSize,
                  color: theme.colors.bright.green,
                ),
              ),
              FailureEval() => TextSpan(
                text: ' [ERR]',
                style: theme.text.bold.copyWith(
                  fontSize: fontSize,
                  color: theme.colors.bright.red,
                ),
              ),
            },
        ],
      ),
      style: theme.text.italic.copyWith(
        fontSize: fontSize,
        color: theme.colors.normal.white,
        height: 1.5,
      ),
      textAlign: textAlign ?? TextAlign.right,
    );
  }
}

TextSpan formatExpression(OmarchyThemeData theme, Expression expr) {
  return switch (expr) {
    ParenthesisGroupExpression(:final expression) => TextSpan(
      children: [
        TextSpan(
          text: '(',
          style: theme.text.normal.copyWith(color: theme.colors.normal.white),
        ),
        formatExpression(theme, expression),
        if (expr.isClosed)
          TextSpan(
            text: ')',
            style: theme.text.normal.copyWith(color: theme.colors.normal.white),
          ),
      ],
    ),
    BinaryExpression(:final operator, :final left, :final right) => TextSpan(
      children: [
        formatExpression(theme, left),
        TextSpan(
          text: ' ${operator.symbol} ',

          style: theme.text.bold.copyWith(color: theme.colors.bright.yellow),
        ),
        formatExpression(theme, right),
      ],
    ),
    UnaryExpression(:final operator, :final operand) => TextSpan(
      children: [
        TextSpan(
          text: operator.symbol,
          style: theme.text.bold.copyWith(color: theme.colors.bright.yellow),
        ),
        formatExpression(theme, operand),
      ],
    ),
    NumberExpression(:final value) => TextSpan(
      text: value.toString(),
      style: theme.text.normal.copyWith(color: theme.colors.foreground),
    ),
    ConstantExpression(:final name) => TextSpan(
      text: name.toString(),
      style: theme.text.normal.copyWith(color: theme.colors.bright.cyan),
    ),
    FunctionExpression(:final function, :final argument) => switch (function) {
      MathFunction.square => TextSpan(
        children: [
          formatExpression(theme, argument),
          TextSpan(text: '²'),
        ],
      ),
      _ => TextSpan(
        children: [
          TextSpan(
            text: function.toString(),
            style: theme.text.bold.copyWith(color: theme.colors.bright.blue),
          ),
          const TextSpan(text: '('),
          formatExpression(theme, argument),
          const TextSpan(text: ')'),
        ],
      ),
    },
    EmptyExpression() => const TextSpan(text: ''),
    PreviousResultExpression(:final expression, :final result) => TextSpan(
      text: result != null
          ? result.toString()
          : switch (eval(expression)) {
              SuccessEval(:final result) => result.toString(),
              FailureEval() => '[ERR]',
            },
      style: theme.text.italic.copyWith(color: theme.colors.normal.green),
    ),
  };
}
