import 'dart:math' as math;

import 'package:calc_engine/src/commands.dart';
import 'package:calc_engine/src/constants.dart';
import 'package:calc_engine/src/context.dart';
import 'package:calc_engine/src/eval.dart';
import 'package:calc_engine/src/parse.dart';
import 'package:calc_engine/src/tokenize.dart';
import 'package:decimal/decimal.dart';

abstract class MathFunction {
  const MathFunction(this.name, {this.aliases = const []});
  final String name;
  final List<String> aliases;

  EvalResult evaluate(CalcContext context, Decimal x);
}

class LambdaMathFunction extends MathFunction {
  const LambdaMathFunction(super.name, this._function, {super.aliases});

  final EvalResult Function(CalcContext, Decimal) _function;

  @override
  EvalResult evaluate(CalcContext context, Decimal x) {
    return _function(context, x);
  }
}

class CommandsMathFunction extends MathFunction {
  const CommandsMathFunction(super.name, this.commands, {super.aliases});

  final List<Command> commands;

  @override
  EvalResult evaluate(CalcContext context, Decimal x) {
    final childContext = context.withConstant(Constant('x', x));
    final tokens = tokenize(commands);
    final expression = parse(childContext, tokens);
    return eval(childContext, expression);
  }
}

class DefaultMathFunctions {
  static final sin = LambdaMathFunction('sin', (context, x) {
    final radians = x.toDouble();
    final sinValue = math.sin(radians);
    if (sinValue.isNaN || sinValue.isInfinite) {
      return EvalResult.failure(
        NumberExpression(x),
        OtherEvalError('Invalid sine result'),
      );
    }
    return EvalResult.success(
      NumberExpression(x),
      Decimal.parse(sinValue.toString()),
    );
  }, aliases: ['sine']);

  static final cos = LambdaMathFunction('cos', (context, x) {
    final radians = x.toDouble();
    final cosValue = math.cos(radians);
    if (cosValue.isNaN || cosValue.isInfinite) {
      return EvalResult.failure(
        NumberExpression(x),
        OtherEvalError('Invalid cosine result'),
      );
    }
    return EvalResult.success(
      NumberExpression(x),
      Decimal.parse(cosValue.toString()),
    );
  }, aliases: ['cosine']);

  static final tan = LambdaMathFunction('tan', (context, x) {
    final radians = x.toDouble();
    final tanValue = math.tan(radians);
    if (tanValue.isNaN || tanValue.isInfinite) {
      return EvalResult.failure(
        NumberExpression(x),
        OtherEvalError('Invalid tangent result'),
      );
    }
    return EvalResult.success(
      NumberExpression(x),
      Decimal.parse(tanValue.toString()),
    );
  }, aliases: ['tangent']);

  static final square = LambdaMathFunction('x²', (context, x) {
    return EvalResult.success(NumberExpression(x), x * x);
  }, aliases: ['sqr', 'square']);

  static final squareRoot = LambdaMathFunction('√', (context, x) {
    if (x < Decimal.fromInt(0)) {
      return EvalResult.failure(
        NumberExpression(x),
        OtherEvalError('Cannot calculate square root of negative number'),
      );
    }
    return EvalResult.success(
      NumberExpression(x),
      Decimal.parse(math.sqrt(x.toDouble()).toString()),
    );
  }, aliases: ['sqrt', 'squareRoot']);

  static final percent = LambdaMathFunction('%', (context, x) {
    // Convert the rational result back to a decimal
    final result = (x / Decimal.fromInt(100)).toDecimal();
    return EvalResult.success(NumberExpression(x), result);
  }, aliases: ['percent']);

  static final all = [sin, cos, tan, square, squareRoot, percent];
}
