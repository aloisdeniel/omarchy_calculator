import 'dart:math' as math;

import 'package:calc_engine/src/commands.dart';
import 'package:calc_engine/src/constants.dart';
import 'package:calc_engine/src/context.dart';
import 'package:calc_engine/src/eval.dart';
import 'package:calc_engine/src/parse.dart';
import 'package:calc_engine/src/tokenize.dart';
import 'package:decimal/decimal.dart';

abstract class MathFunction {
  const MathFunction(this.name, {this.argCount = 1, this.aliases = const []});
  final String name;
  final List<String> aliases;
  final int argCount;
  Decimal evaluate(CalcContext context, List<Decimal> args);
}

class LambdaMathFunction extends MathFunction {
  const LambdaMathFunction(
    super.name,
    this._function, {
    super.aliases,
    super.argCount,
  });

  factory LambdaMathFunction.single(
    String name,
    Decimal Function(CalcContext, Decimal) function, {
    List<String> aliases = const [],
  }) {
    return LambdaMathFunction(name, (context, args) {
      if (args.length != 1) {
        throw OtherEvalError('Expected 1 argument, got ${args.length}');
      }
      return function(context, args[0]);
    }, aliases: aliases);
  }

  final Decimal Function(CalcContext, List<Decimal>) _function;

  @override
  Decimal evaluate(CalcContext context, List<Decimal> args) {
    return _function(context, args);
  }
}

class CommandsMathFunction extends MathFunction {
  const CommandsMathFunction(
    super.name,
    this.commands, {
    super.aliases,
    super.argCount,
  });

  final List<Command> commands;

  @override
  Decimal evaluate(CalcContext context, List<Decimal> x) {
    final childContext = context;
    for (var i = 0; i < commands.length; i++) {
      context = context.withConstant(
        Constant('x${i > 0 ? i.toString() : ''}', x[i]),
      );
    }
    final tokens = tokenize(commands);
    final expression = parse(childContext, tokens);
    final result = eval(childContext, expression);
    switch (result) {
      case SuccessEval(:final result):
        return result;
      case FailureEval(:final error):
        throw error;
    }
  }
}

class DefaultMathFunctions {
  static final sin = LambdaMathFunction.single('sin', (context, x) {
    final radians = context.angleUnit.toRadians(x);
    final sinValue = math.sin(radians.toDouble());
    if (sinValue.isNaN || sinValue.isInfinite) {
      throw OtherEvalError('Invalid sine result');
    }
    return Decimal.parse(sinValue.toString());
  }, aliases: ['sine']);

  static final cos = LambdaMathFunction.single('cos', (context, x) {
    final radians = context.angleUnit.toRadians(x);
    final cosValue = math.cos(radians.toDouble());
    if (cosValue.isNaN || cosValue.isInfinite) {
      throw OtherEvalError('Invalid cosine result');
    }
    return Decimal.parse(cosValue.toString());
  }, aliases: ['cosine']);

  static final tan = LambdaMathFunction.single('tan', (context, x) {
    final radians = context.angleUnit.toRadians(x);
    final tanValue = math.tan(radians.toDouble());
    if (tanValue.isNaN || tanValue.isInfinite) {
      throw OtherEvalError('Invalid tangent result');
    }
    return Decimal.parse(tanValue.toString());
  }, aliases: ['tangent']);

  static final square = LambdaMathFunction.single('x²', (context, x) {
    return x * x;
  }, aliases: ['sqr', 'square']);

  static final cube = LambdaMathFunction.single('x³', (context, x) {
    return x * x * x;
  }, aliases: ['cube']);

  static final ePower = LambdaMathFunction.single(
    //symbol
    'eˣ',
    (context, x) {
      return Decimal.parse(math.exp(x.toDouble()).toString());
    },
    aliases: ['expPower', 'e_power'],
  );

  static final reciprocal = LambdaMathFunction.single('¹⁄ₓ', (context, x) {
    if (x == Decimal.zero) {
      throw OtherEvalError('Cannot calculate reciprocal of zero');
    }
    return (Decimal.fromInt(1) / x).toDecimal(scaleOnInfinitePrecision: 20);
  }, aliases: ['reciprocal']);

  static final squareRoot = LambdaMathFunction.single('√', (context, x) {
    if (x < Decimal.fromInt(0)) {
      throw OtherEvalError('Cannot calculate square root of negative number');
    }
    return Decimal.parse(math.sqrt(x.toDouble()).toString());
  }, aliases: ['sqrt', 'square_root']);

  static final nthRoot = LambdaMathFunction(
    'ⁿ√',
    (context, args) {
      final n = args[0];
      final x = args[1];
      if (n == Decimal.zero) {
        throw OtherEvalError('Cannot calculate root with degree zero');
      }

      if (x < Decimal.fromInt(0) && n % Decimal.fromInt(2) == Decimal.zero) {
        throw OtherEvalError('Cannot calculate even root of negative number');
      }

      final rootValue = math.pow(x.toDouble(), 1 / n.toDouble());

      if (rootValue.isNaN || rootValue.isInfinite) {
        throw OtherEvalError('Invalid root result');
      }

      return Decimal.parse(rootValue.toString());
    },

    aliases: ['nthRoot', 'n_root'],
    argCount: 2,
  );

  static final log = LambdaMathFunction.single('log', (context, x) {
    if (x <= Decimal.fromInt(0)) {
      throw OtherEvalError('Cannot calculate logarithm of non-positive number');
    }
    return Decimal.parse(math.log(x.toDouble()).toString());
  }, aliases: ['logarithm']);

  static final ln = LambdaMathFunction.single('ln', (context, x) {
    if (x <= Decimal.fromInt(0)) {
      throw OtherEvalError(
        'Cannot calculate natural logarithm of non-positive number',
      );
    }
    return Decimal.parse(math.log(x.toDouble()).toString());
  }, aliases: ['natural_log', 'natural_logarithm']);

  static final exp = LambdaMathFunction.single('exp', (context, x) {
    return Decimal.parse(math.exp(x.toDouble()).toString());
  }, aliases: ['exponential']);

  static final abs = LambdaMathFunction.single('abs', (context, x) {
    return x.abs();
  }, aliases: ['absolute']);

  static final modulo = LambdaMathFunction(
    'mod',
    (context, args) {
      final x = args[0];
      final y = args[1];
      if (y == Decimal.zero) {
        throw OtherEvalError('Cannot calculate modulo of zero');
      }
      return x % y;
    },
    aliases: ['modulus', 'modulo', 'remainder'],
    argCount: 2,
  );

  static final factorial = LambdaMathFunction.single('x!', (context, x) {
    if (x < Decimal.fromInt(0) || x != x.toBigInt().toDecimal()) {
      throw OtherEvalError(
        'Cannot calculate factorial of negative or non-integer',
      );
    }
    BigInt result = BigInt.from(1);
    for (var i = BigInt.from(1); i <= x.toBigInt(); i += BigInt.from(1)) {
      result *= i;
    }
    return Decimal.parse(result.toString());
  }, aliases: ['factorial']);

  static final percent = LambdaMathFunction.single('%', (context, x) {
    // Convert the rational result back to a decimal
    final result = (x / Decimal.fromInt(100)).toDecimal();
    return result;
  }, aliases: ['percent']);

  static final toggleSign = LambdaMathFunction.single('±', (context, x) {
    return -x;
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
