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

  static final cube = LambdaMathFunction('x³', (context, x) {
    return EvalResult.success(NumberExpression(x), x * x * x);
  }, aliases: ['cube']);

  static final ePower = LambdaMathFunction(
    //symbol
    'eˣ',
    (context, x) {
      return EvalResult.success(
        NumberExpression(x),
        Decimal.parse(math.exp(x.toDouble()).toString()),
      );
    },
    aliases: ['expPower', 'e_power'],
  );

  static final reciprocal = LambdaMathFunction('¹⁄ₓ', (context, x) {
    if (x == Decimal.zero) {
      return EvalResult.failure(
        NumberExpression(x),
        OtherEvalError('Cannot calculate reciprocal of zero'),
      );
    }
    return EvalResult.success(
      NumberExpression(x),
      (Decimal.fromInt(1) / x).toDecimal(scaleOnInfinitePrecision: 20),
    );
  }, aliases: ['reciprocal']);

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
  }, aliases: ['sqrt', 'square_root']);

  static final nthRoot = LambdaMathFunction('ⁿ√', (context, x) {
    if (x == Decimal.zero) {
      return EvalResult.failure(
        NumberExpression(x),
        OtherEvalError('Cannot calculate root with degree zero'),
      );
    }
    if (x < Decimal.fromInt(0) && x % Decimal.fromInt(2) == Decimal.zero) {
      return EvalResult.failure(
        NumberExpression(x),
        OtherEvalError('Cannot calculate even root of negative number'),
      );
    }
    final rootValue = math.pow(x.toDouble(), 1 / x.toDouble());
    if (rootValue.isNaN || rootValue.isInfinite) {
      return EvalResult.failure(
        NumberExpression(x),
        OtherEvalError('Invalid root result'),
      );
    }
    return EvalResult.success(
      NumberExpression(x),
      Decimal.parse(rootValue.toString()),
    );
  }, aliases: ['nthRoot', 'n_root']);

  static final log = LambdaMathFunction('log', (context, x) {
    if (x <= Decimal.fromInt(0)) {
      return EvalResult.failure(
        NumberExpression(x),
        OtherEvalError('Cannot calculate logarithm of non-positive number'),
      );
    }
    return EvalResult.success(
      NumberExpression(x),
      Decimal.parse(math.log(x.toDouble()).toString()),
    );
  }, aliases: ['logarithm']);

  static final ln = LambdaMathFunction('ln', (context, x) {
    if (x <= Decimal.fromInt(0)) {
      return EvalResult.failure(
        NumberExpression(x),
        OtherEvalError(
          'Cannot calculate natural logarithm of non-positive number',
        ),
      );
    }
    return EvalResult.success(
      NumberExpression(x),
      Decimal.parse(math.log(x.toDouble()).toString()),
    );
  }, aliases: ['natural_log', 'natural_logarithm']);

  static final exp = LambdaMathFunction('exp', (context, x) {
    return EvalResult.success(
      NumberExpression(x),
      Decimal.parse(math.exp(x.toDouble()).toString()),
    );
  }, aliases: ['exponential']);

  static final abs = LambdaMathFunction('abs', (context, x) {
    return EvalResult.success(NumberExpression(x), x.abs());
  }, aliases: ['absolute']);

  static final modulo = LambdaMathFunction('mod', (context, x) {
    if (x == Decimal.zero) {
      return EvalResult.failure(
        NumberExpression(x),
        OtherEvalError('Cannot calculate modulo of zero'),
      );
    }
    return EvalResult.success(NumberExpression(x), x);
  }, aliases: ['modulus', 'modulo', 'remainder']);

  static final factorial = LambdaMathFunction('x!', (context, x) {
    if (x < Decimal.fromInt(0) || x != x.toBigInt().toDecimal()) {
      return EvalResult.failure(
        NumberExpression(x),
        OtherEvalError('Cannot calculate factorial of negative or non-integer'),
      );
    }
    BigInt result = BigInt.from(1);
    for (var i = BigInt.from(1); i <= x.toBigInt(); i += BigInt.from(1)) {
      result *= i;
    }
    return EvalResult.success(
      NumberExpression(x),
      Decimal.parse(result.toString()),
    );
  }, aliases: ['factorial']);

  static final percent = LambdaMathFunction('%', (context, x) {
    // Convert the rational result back to a decimal
    final result = (x / Decimal.fromInt(100)).toDecimal();
    return EvalResult.success(NumberExpression(x), result);
  }, aliases: ['percent']);

  static final toggleSign = LambdaMathFunction('±', (context, x) {
    return EvalResult.success(NumberExpression(x), -x);
  }, aliases: ['negate', 'toggle_sign']);

  static final all = [
    sin,
    cos,
    tan,
    squareRoot,
    nthRoot,
    square,
    cube,
    reciprocal,
    percent,
    toggleSign,
    log,
    ln,
    exp,
    ePower,
    abs,
    modulo,
    factorial,
  ];
}
