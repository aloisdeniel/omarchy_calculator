import 'package:flutter_omarchy/flutter_omarchy.dart';
import 'package:omarchy_calculator/src/engine/eval.dart';
import 'package:omarchy_calculator/src/engine/parse.dart';
import 'package:omarchy_calculator/src/engine/tokenize.dart';
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
            TextSpan(
              text: switch (state.result) {
                SuccessEval(:final result) => ' = $result',
                FailureEval() => '[ERR]',
              },
              style: theme.text.bold.copyWith(
                fontSize: fontSize,
                color: theme.colors.bright.green,
              ),
            ),
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
    BinaryExpression(:final operator, :final left, :final right) => TextSpan(
      children: [
        formatExpression(theme, left),
        TextSpan(
          text:
              ' ${switch (operator) {
                BinaryOperator.add => '+',
                BinaryOperator.subtract => '-',
                BinaryOperator.multiply => '×',
                BinaryOperator.divide => '÷',
                BinaryOperator.power => '^',
              }} ',
          style: theme.text.bold.copyWith(color: theme.colors.bright.yellow),
        ),
        formatExpression(theme, right),
      ],
    ),
    UnaryExpression(:final operator, :final operand) => TextSpan(
      children: [
        TextSpan(
          text: switch (operator) {
            UnaryOperator.negate => '-',
          },
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
      text: switch (name) {
        Constant.pi => 'π',
        Constant.euler => 'e',
      },
      style: theme.text.normal.copyWith(color: theme.colors.bright.cyan),
    ),
    FunctionExpression(:final function, :final argument) => TextSpan(
      children: [
        TextSpan(
          text: switch (function) {
            MathFunction.square => 'sqr',
            MathFunction.sin => 'sin',
            MathFunction.cos => 'cos',
            MathFunction.tan => 'tan',
            MathFunction.squareRoot => 'sqrt',
            MathFunction.percent => '%',
          },
          style: theme.text.bold.copyWith(color: theme.colors.bright.blue),
        ),
        const TextSpan(text: '('),
        formatExpression(theme, argument),
        const TextSpan(text: ')'),
      ],
    ),
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
