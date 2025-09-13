import 'package:calc_engine/calc_engine.dart';
import 'package:flutter_omarchy/flutter_omarchy.dart';

/// A widget that displays a mathematical expression with syntax highlighting.
class ExpressionView extends StatelessWidget {
  const ExpressionView(
    this.context,
    this.expression,
    this.result, {
    super.key,
    required this.fontSize,
    this.textAlign,
    this.withResult = false,
  });

  final double fontSize;
  final CalcContext context;
  final EvalResult result;
  final Expression expression;
  final TextAlign? textAlign;
  final bool withResult;

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    return Text.rich(
      TextSpan(
        children: [
          formatExpression(this.context, fontSize, theme, expression),
          if (withResult)
            switch (result) {
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

TextSpan formatExpression(
  CalcContext context,
  double fontSize,
  OmarchyThemeData theme,
  Expression expr,
) {
  return switch (expr) {
    ParenthesisGroupExpression(:final expression) => TextSpan(
      children: [
        TextSpan(
          text: '(',
          style: theme.text.normal.copyWith(
            fontSize: fontSize,
            color: theme.colors.normal.white,
          ),
        ),
        formatExpression(context, fontSize, theme, expression),
        if (expr.isClosed)
          TextSpan(
            text: ')',
            style: theme.text.normal.copyWith(
              fontSize: fontSize,
              color: theme.colors.normal.white,
            ),
          ),
      ],
    ),
    BinaryExpression(:final operator, :final left, :final right) => TextSpan(
      children: [
        formatExpression(context, fontSize, theme, left),
        TextSpan(
          text: ' ${operator.symbol} ',

          style: theme.text.bold.copyWith(
            fontSize: fontSize,
            color: theme.colors.bright.yellow,
          ),
        ),
        formatExpression(context, fontSize, theme, right),
      ],
    ),
    UnaryExpression(:final operator, :final operand) => TextSpan(
      children: [
        TextSpan(
          text: operator.symbol,
          style: theme.text.bold.copyWith(
            fontSize: fontSize,
            color: theme.colors.bright.yellow,
          ),
        ),
        formatExpression(context, fontSize, theme, operand),
      ],
    ),
    NumberExpression(:final value) => TextSpan(
      text: value.toString(),
      style: theme.text.normal.copyWith(
        fontSize: fontSize,
        color: theme.colors.foreground,
      ),
    ),
    ConstantExpression(:final name) => TextSpan(
      text: name.name,
      style: theme.text.normal.copyWith(
        fontSize: fontSize,
        color: theme.colors.bright.cyan,
      ),
    ),
    UnknownConstantExpression(:final name) => TextSpan(
      text: name,
      style: theme.text.normal.copyWith(
        fontSize: fontSize,
        color: theme.colors.bright.red,
      ),
    ),
    FunctionExpression(:final function, :final argument, :final isClosed) =>
      switch (function) {
        _ when function.name == '²' => TextSpan(
          children: [
            formatExpression(context, fontSize, theme, argument),
            TextSpan(text: '²'),
          ],
        ),
        _ => TextSpan(
          children: [
            TextSpan(
              text: function.name,
              style: theme.text.bold.copyWith(
                fontSize: fontSize,
                color: theme.colors.bright.blue,
              ),
            ),
            TextSpan(
              text: '(',
              style: TextStyle(
                fontSize: fontSize,
                color: isClosed ? null : theme.colors.bright.black,
              ),
            ),
            formatExpression(context, fontSize, theme, argument),
            if (isClosed)
              TextSpan(
                text: ')',
                style: TextStyle(fontSize: fontSize),
              ),
          ],
        ),
      },
    UnknownFunctionExpression(
      :final function,
      :final argument,
      :final isClosed,
    ) =>
      TextSpan(
        children: [
          TextSpan(
            text: function,
            style: theme.text.bold.copyWith(
              fontSize: fontSize,
              color: theme.colors.bright.red,
            ),
          ),

          TextSpan(
            text: '(',
            style: TextStyle(
              fontSize: fontSize,
              color: isClosed ? null : theme.colors.bright.black,
            ),
          ),
          formatExpression(context, fontSize, theme, argument),
          if (isClosed) const TextSpan(text: ')'),
        ],
      ),
    EmptyExpression() => const TextSpan(text: ''),
    PreviousResultExpression(:final expression, :final result) => TextSpan(
      text: result != null
          ? result.toString()
          : switch (eval(context, expression)) {
              SuccessEval(:final result) => result.toString(),
              FailureEval() => '[ERR]',
            },
      style: theme.text.italic.copyWith(
        fontSize: fontSize,
        color: theme.colors.normal.green,
      ),
    ),
  };
}
