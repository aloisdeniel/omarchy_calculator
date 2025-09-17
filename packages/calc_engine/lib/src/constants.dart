import 'dart:math' as math;

import 'package:decimal/decimal.dart';

class Constant {
  const Constant(this.name, this.value, {this.aliases = const []});
  final String name;
  final List<String> aliases;
  final Decimal value;
}

class DefaultConstants {
  static final pi = Constant(
    'π',
    Decimal.parse(math.pi.toString()),
    aliases: ['pi'],
  );
  static final e = Constant(
    'e',
    Decimal.parse(math.e.toString()),
    aliases: ['Euler'],
  );

  static final all = [pi, e];
}
