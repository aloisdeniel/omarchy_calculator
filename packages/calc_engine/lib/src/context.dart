import 'dart:math' as math;

import 'package:calc_engine/src/commands.dart';
import 'package:calc_engine/src/constants.dart';
import 'package:calc_engine/src/functions.dart';
import 'package:decimal/decimal.dart';

final _decimalPi = Decimal.parse(math.pi.toString());

enum AngleUnit {
  degrees,
  radians;

  Decimal toRadians(Decimal x) {
    switch (this) {
      case AngleUnit.degrees:
        return x *
            (_decimalPi / Decimal.fromInt(180)).toDecimal(
              scaleOnInfinitePrecision: 20,
            );
      case AngleUnit.radians:
        return x;
    }
  }

  Decimal fromRadians(Decimal x) {
    switch (this) {
      case AngleUnit.degrees:
        return x *
            (Decimal.fromInt(180) / _decimalPi).toDecimal(
              scaleOnInfinitePrecision: 20,
            );
      case AngleUnit.radians:
        return x;
    }
  }
}

class CalcContext {
  CalcContext._(this.constants, this.functions, this.angleUnit);

  CalcContext({
    this.angleUnit = AngleUnit.radians,
    List<Constant> constants = const [],
    List<MathFunction> functions = const [],
  }) : constants = {
         for (final c in DefaultConstants.all) ...{
           c.name: c,
           for (final alias in c.aliases) alias: c,
         },

         for (final c in constants) ...{
           c.name: c,
           for (final alias in c.aliases) alias: c,
         },
       },
       functions = {
         for (final c in DefaultMathFunctions.all) ...{
           c.name: c,
           for (final alias in c.aliases) alias: c,
         },

         for (final c in functions) ...{
           c.name: c,
           for (final alias in c.aliases) alias: c,
         },
       };

  factory CalcContext.fromConfig(Map<String, dynamic> config) {
    final constants = <Constant>[];

    final constConfig = config['constants'];
    if (constConfig is Map<String, dynamic>) {
      for (final entry in constConfig.entries) {
        final value = entry.value;
        if (value is num) {
          constants.add(Constant(entry.key, Decimal.parse(value.toString())));
        } else if (value is String) {
          final decimal = Decimal.tryParse(value);
          if (decimal != null) {
            constants.add(Constant(entry.key, decimal));
          }
        }
      }
    }
    final functions = <MathFunction>[];

    final funcConfig = config['functions'];

    if (funcConfig is Map<String, dynamic>) {
      for (final entry in funcConfig.entries) {
        final value = entry.value;
        if (value is String) {
          final commands = Command.parse(value);
          functions.add(CommandsMathFunction(entry.key, commands));
        }
      }
    }
    final angleUnitConfig = config['angle_unit'];
    final angleUnit = angleUnitConfig == 'degrees'
        ? AngleUnit.degrees
        : AngleUnit.radians;

    return CalcContext(
      constants: constants,
      functions: functions,
      angleUnit: angleUnit,
    );
  }

  final Map<String, Constant> constants;
  final Map<String, MathFunction> functions;
  final AngleUnit angleUnit;

  CalcContext withConstant(Constant x) {
    return CalcContext._(
      {...constants, x.name: x, for (final alias in x.aliases) alias: x},
      functions,
      angleUnit,
    );
  }

  Constant? findContant(String name) {
    return constants[name];
  }

  MathFunction? findFunction(String name) {
    return functions[name];
  }
}
