import 'package:calc_engine/calc_engine.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter_omarchy/flutter_omarchy.dart';

class AnsiColorMapper extends SimpleMapper<AnsiColor> {
  const AnsiColorMapper();

  @override
  AnsiColor decode(dynamic value) {
    return AnsiColor.values.where((x) => x.name == value).firstOrNull ??
        AnsiColor.white;
  }

  @override
  dynamic encode(AnsiColor self) {
    return self.name;
  }
}

class OmarchyIconMapper extends SimpleMapper<IconData> {
  const OmarchyIconMapper({this.fallback = OmarchyIcons.faClose});

  final IconData fallback;

  @override
  IconData decode(dynamic value) {
    return OmarchyIcons.values.where((x) => x.$1 == value).firstOrNull?.$2 ??
        fallback;
  }

  @override
  dynamic encode(IconData self) {
    return OmarchyIcons.values.where((x) => x.$2 == self).firstOrNull?.$1 ??
        encode(fallback);
  }
}

class ConstantMapper extends SimpleMapper<Constant> {
  const ConstantMapper();

  @override
  Constant decode(dynamic value) {
    if (value is Map<String, dynamic>) {
      final name = value['name'];
      final val = value['value'];
      return Constant(
        switch (name) {
          String v => v.trim(),
          _ => throw ArgumentError.value(
            value,
            'value',
            'Constant name must be a string',
          ),
        },
        switch (val) {
          num v => Decimal.parse(v.toString()),
          String v => Decimal.parse(v),
          _ => throw ArgumentError.value(
            value,
            'value',
            'Constant value must be a string or number',
          ),
        },
      );
    }
    throw ArgumentError.value(value, 'value', 'Invalid Constant format');
  }

  @override
  dynamic encode(Constant self) {
    throw UnsupportedError('');
  }
}

class MathFunctionMapper extends SimpleMapper<MathFunction> {
  const MathFunctionMapper();

  @override
  MathFunction decode(dynamic value) {
    if (value is Map<String, dynamic>) {
      final name = value['name'];
      final val = value['function'];
      return CommandsMathFunction(
        switch (name) {
          String v => v.trim(),
          _ => throw ArgumentError.value(
            value,
            'value',
            'Constant name must be a string',
          ),
        },
        switch (val) {
          String v => Command.parse(v),
          _ => throw ArgumentError.value(
            value,
            'value',
            'Function must be a string',
          ),
        },
      );
    }
    throw ArgumentError.value(value, 'value', 'Invalid Constant format');
  }

  @override
  dynamic encode(MathFunction self) {
    throw UnsupportedError('');
  }
}

class CommandMapper extends SimpleMapper<Command> {
  const CommandMapper();

  @override
  Command decode(dynamic value) {
    if (value is String) {
      return Command.parse(value).first;
    }

    throw ArgumentError.value(value, 'value', 'Invalid Command format');
  }

  @override
  dynamic encode(Command self) {
    throw UnsupportedError('');
  }
}
