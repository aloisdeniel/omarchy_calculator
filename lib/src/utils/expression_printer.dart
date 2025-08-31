import 'package:omarchy_calculator/src/engine/eval.dart';
import 'package:omarchy_calculator/src/engine/parse.dart';
import 'package:omarchy_calculator/src/engine/tokenize.dart';

String printExpression(Expression expr) {
  // TODO add terminal colors
  return switch (expr) {
    ParenthesisGroupExpression(:final expression) =>
      '(' + printExpression(expression) + ')',
    BinaryExpression(:final operator, :final left, :final right) =>
      printExpression(left) +
          ' ${switch (operator) {
            BinaryOperator.add => '+',
            BinaryOperator.subtract => '-',
            BinaryOperator.multiply => '×',
            BinaryOperator.divide => '÷',
            BinaryOperator.power => '^',
          }} ' +
          printExpression(right),
    UnaryExpression(:final operator, :final operand) => switch (operator) {
      UnaryOperator.negate => '-' + printExpression(operand),
    },
    NumberExpression(:final value) => value.toString(),
    ConstantExpression(:final name) => switch (name) {
      Constant.pi => 'π',
      Constant.euler => 'e',
    },
    FunctionExpression(:final function, :final argument) =>
      switch (function) {
            MathFunction.square => 'sqr',
            MathFunction.sin => 'sin',
            MathFunction.cos => 'cos',
            MathFunction.tan => 'tan',
            MathFunction.squareRoot => 'sqrt',
            MathFunction.percent => '%',
          } +
          '(' +
          printExpression(argument) +
          ')',
    EmptyExpression() => '',
    PreviousResultExpression(:final expression, :final result) =>
      result != null
          ? result.toString()
          : switch (eval(expression)) {
              SuccessEval(:final result) => result.toString(),
              FailureEval() => '[ERR]',
            },
  };
}
