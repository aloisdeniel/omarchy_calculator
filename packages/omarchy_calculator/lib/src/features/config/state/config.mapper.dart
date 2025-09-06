// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'config.dart';

class ConfigMapper extends ClassMapperBase<Config> {
  ConfigMapper._();

  static ConfigMapper? _instance;
  static ConfigMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ConfigMapper._());
      ButtonLayoutMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'Config';

  static List<Constant> _$constants(Config v) => v.constants;
  static const Field<Config, List<Constant>> _f$constants = Field(
    'constants',
    _$constants,
    opt: true,
    def: const [],
  );
  static List<MathFunction> _$functions(Config v) => v.functions;
  static const Field<Config, List<MathFunction>> _f$functions = Field(
    'functions',
    _$functions,
    opt: true,
    def: const [],
  );
  static List<ButtonLayout> _$layouts(Config v) => v.layouts;
  static const Field<Config, List<ButtonLayout>> _f$layouts = Field(
    'layouts',
    _$layouts,
  );

  @override
  final MappableFields<Config> fields = const {
    #constants: _f$constants,
    #functions: _f$functions,
    #layouts: _f$layouts,
  };

  static Config _instantiate(DecodingData data) {
    return Config(
      constants: data.dec(_f$constants),
      functions: data.dec(_f$functions),
      layouts: data.dec(_f$layouts),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Config fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Config>(map);
  }

  static Config fromJson(String json) {
    return ensureInitialized().decodeJson<Config>(json);
  }
}

mixin ConfigMappable {
  String toJson() {
    return ConfigMapper.ensureInitialized().encodeJson<Config>(this as Config);
  }

  Map<String, dynamic> toMap() {
    return ConfigMapper.ensureInitialized().encodeMap<Config>(this as Config);
  }

  ConfigCopyWith<Config, Config, Config> get copyWith =>
      _ConfigCopyWithImpl<Config, Config>(this as Config, $identity, $identity);
  @override
  String toString() {
    return ConfigMapper.ensureInitialized().stringifyValue(this as Config);
  }

  @override
  bool operator ==(Object other) {
    return ConfigMapper.ensureInitialized().equalsValue(this as Config, other);
  }

  @override
  int get hashCode {
    return ConfigMapper.ensureInitialized().hashValue(this as Config);
  }
}

extension ConfigValueCopy<$R, $Out> on ObjectCopyWith<$R, Config, $Out> {
  ConfigCopyWith<$R, Config, $Out> get $asConfig =>
      $base.as((v, t, t2) => _ConfigCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ConfigCopyWith<$R, $In extends Config, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, Constant, ObjectCopyWith<$R, Constant, Constant>>
  get constants;
  ListCopyWith<$R, MathFunction, ObjectCopyWith<$R, MathFunction, MathFunction>>
  get functions;
  ListCopyWith<
    $R,
    ButtonLayout,
    ButtonLayoutCopyWith<$R, ButtonLayout, ButtonLayout>
  >
  get layouts;
  $R call({
    List<Constant>? constants,
    List<MathFunction>? functions,
    List<ButtonLayout>? layouts,
  });
  ConfigCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ConfigCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Config, $Out>
    implements ConfigCopyWith<$R, Config, $Out> {
  _ConfigCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Config> $mapper = ConfigMapper.ensureInitialized();
  @override
  ListCopyWith<$R, Constant, ObjectCopyWith<$R, Constant, Constant>>
  get constants => ListCopyWith(
    $value.constants,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(constants: v),
  );
  @override
  ListCopyWith<$R, MathFunction, ObjectCopyWith<$R, MathFunction, MathFunction>>
  get functions => ListCopyWith(
    $value.functions,
    (v, t) => ObjectCopyWith(v, $identity, t),
    (v) => call(functions: v),
  );
  @override
  ListCopyWith<
    $R,
    ButtonLayout,
    ButtonLayoutCopyWith<$R, ButtonLayout, ButtonLayout>
  >
  get layouts => ListCopyWith(
    $value.layouts,
    (v, t) => v.copyWith.$chain(t),
    (v) => call(layouts: v),
  );
  @override
  $R call({
    List<Constant>? constants,
    List<MathFunction>? functions,
    List<ButtonLayout>? layouts,
  }) => $apply(
    FieldCopyWithData({
      if (constants != null) #constants: constants,
      if (functions != null) #functions: functions,
      if (layouts != null) #layouts: layouts,
    }),
  );
  @override
  Config $make(CopyWithData data) => Config(
    constants: data.get(#constants, or: $value.constants),
    functions: data.get(#functions, or: $value.functions),
    layouts: data.get(#layouts, or: $value.layouts),
  );

  @override
  ConfigCopyWith<$R2, Config, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _ConfigCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class ButtonLayoutMapper extends ClassMapperBase<ButtonLayout> {
  ButtonLayoutMapper._();

  static ButtonLayoutMapper? _instance;
  static ButtonLayoutMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ButtonLayoutMapper._());
      ButtonMapper.ensureInitialized();
    }
    return _instance!;
  }

  @override
  final String id = 'ButtonLayout';

  static String _$name(ButtonLayout v) => v.name;
  static const Field<ButtonLayout, String> _f$name = Field('name', _$name);
  static List<Button> _$buttons(ButtonLayout v) => v.buttons;
  static const Field<ButtonLayout, List<Button>> _f$buttons = Field(
    'buttons',
    _$buttons,
  );

  @override
  final MappableFields<ButtonLayout> fields = const {
    #name: _f$name,
    #buttons: _f$buttons,
  };

  static ButtonLayout _instantiate(DecodingData data) {
    return ButtonLayout(name: data.dec(_f$name), buttons: data.dec(_f$buttons));
  }

  @override
  final Function instantiate = _instantiate;

  static ButtonLayout fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<ButtonLayout>(map);
  }

  static ButtonLayout fromJson(String json) {
    return ensureInitialized().decodeJson<ButtonLayout>(json);
  }
}

mixin ButtonLayoutMappable {
  String toJson() {
    return ButtonLayoutMapper.ensureInitialized().encodeJson<ButtonLayout>(
      this as ButtonLayout,
    );
  }

  Map<String, dynamic> toMap() {
    return ButtonLayoutMapper.ensureInitialized().encodeMap<ButtonLayout>(
      this as ButtonLayout,
    );
  }

  ButtonLayoutCopyWith<ButtonLayout, ButtonLayout, ButtonLayout> get copyWith =>
      _ButtonLayoutCopyWithImpl<ButtonLayout, ButtonLayout>(
        this as ButtonLayout,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return ButtonLayoutMapper.ensureInitialized().stringifyValue(
      this as ButtonLayout,
    );
  }

  @override
  bool operator ==(Object other) {
    return ButtonLayoutMapper.ensureInitialized().equalsValue(
      this as ButtonLayout,
      other,
    );
  }

  @override
  int get hashCode {
    return ButtonLayoutMapper.ensureInitialized().hashValue(
      this as ButtonLayout,
    );
  }
}

extension ButtonLayoutValueCopy<$R, $Out>
    on ObjectCopyWith<$R, ButtonLayout, $Out> {
  ButtonLayoutCopyWith<$R, ButtonLayout, $Out> get $asButtonLayout =>
      $base.as((v, t, t2) => _ButtonLayoutCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ButtonLayoutCopyWith<$R, $In extends ButtonLayout, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  ListCopyWith<$R, Button, ButtonCopyWith<$R, Button, Button>> get buttons;
  $R call({String? name, List<Button>? buttons});
  ButtonLayoutCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ButtonLayoutCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, ButtonLayout, $Out>
    implements ButtonLayoutCopyWith<$R, ButtonLayout, $Out> {
  _ButtonLayoutCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<ButtonLayout> $mapper =
      ButtonLayoutMapper.ensureInitialized();
  @override
  ListCopyWith<$R, Button, ButtonCopyWith<$R, Button, Button>> get buttons =>
      ListCopyWith(
        $value.buttons,
        (v, t) => v.copyWith.$chain(t),
        (v) => call(buttons: v),
      );
  @override
  $R call({String? name, List<Button>? buttons}) => $apply(
    FieldCopyWithData({
      if (name != null) #name: name,
      if (buttons != null) #buttons: buttons,
    }),
  );
  @override
  ButtonLayout $make(CopyWithData data) => ButtonLayout(
    name: data.get(#name, or: $value.name),
    buttons: data.get(#buttons, or: $value.buttons),
  );

  @override
  ButtonLayoutCopyWith<$R2, ButtonLayout, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _ButtonLayoutCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

class ButtonMapper extends ClassMapperBase<Button> {
  ButtonMapper._();

  static ButtonMapper? _instance;
  static ButtonMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = ButtonMapper._());
      MapperContainer.globals.useAll([AnsiColorMapper(), CommandMapper()]);
    }
    return _instance!;
  }

  @override
  final String id = 'Button';

  static String _$label(Button v) => v.label;
  static const Field<Button, String> _f$label = Field('label', _$label);
  static Command _$command(Button v) => v.command;
  static const Field<Button, Command> _f$command = Field('command', _$command);
  static AnsiColor _$color(Button v) => v.color;
  static const Field<Button, AnsiColor> _f$color = Field(
    'color',
    _$color,
    opt: true,
    def: AnsiColor.white,
  );
  static int _$size(Button v) => v.size;
  static const Field<Button, int> _f$size = Field(
    'size',
    _$size,
    opt: true,
    def: 1,
  );
  static IconData? _$icon(Button v) => v.icon;
  static const Field<Button, IconData> _f$icon = Field(
    'icon',
    _$icon,
    opt: true,
  );

  @override
  final MappableFields<Button> fields = const {
    #label: _f$label,
    #command: _f$command,
    #color: _f$color,
    #size: _f$size,
    #icon: _f$icon,
  };

  static Button _instantiate(DecodingData data) {
    return Button(
      label: data.dec(_f$label),
      command: data.dec(_f$command),
      color: data.dec(_f$color),
      size: data.dec(_f$size),
      icon: data.dec(_f$icon),
    );
  }

  @override
  final Function instantiate = _instantiate;

  static Button fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<Button>(map);
  }

  static Button fromJson(String json) {
    return ensureInitialized().decodeJson<Button>(json);
  }
}

mixin ButtonMappable {
  String toJson() {
    return ButtonMapper.ensureInitialized().encodeJson<Button>(this as Button);
  }

  Map<String, dynamic> toMap() {
    return ButtonMapper.ensureInitialized().encodeMap<Button>(this as Button);
  }

  ButtonCopyWith<Button, Button, Button> get copyWith =>
      _ButtonCopyWithImpl<Button, Button>(this as Button, $identity, $identity);
  @override
  String toString() {
    return ButtonMapper.ensureInitialized().stringifyValue(this as Button);
  }

  @override
  bool operator ==(Object other) {
    return ButtonMapper.ensureInitialized().equalsValue(this as Button, other);
  }

  @override
  int get hashCode {
    return ButtonMapper.ensureInitialized().hashValue(this as Button);
  }
}

extension ButtonValueCopy<$R, $Out> on ObjectCopyWith<$R, Button, $Out> {
  ButtonCopyWith<$R, Button, $Out> get $asButton =>
      $base.as((v, t, t2) => _ButtonCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class ButtonCopyWith<$R, $In extends Button, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({
    String? label,
    Command? command,
    AnsiColor? color,
    int? size,
    IconData? icon,
  });
  ButtonCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _ButtonCopyWithImpl<$R, $Out> extends ClassCopyWithBase<$R, Button, $Out>
    implements ButtonCopyWith<$R, Button, $Out> {
  _ButtonCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<Button> $mapper = ButtonMapper.ensureInitialized();
  @override
  $R call({
    String? label,
    Command? command,
    AnsiColor? color,
    int? size,
    Object? icon = $none,
  }) => $apply(
    FieldCopyWithData({
      if (label != null) #label: label,
      if (command != null) #command: command,
      if (color != null) #color: color,
      if (size != null) #size: size,
      if (icon != $none) #icon: icon,
    }),
  );
  @override
  Button $make(CopyWithData data) => Button(
    label: data.get(#label, or: $value.label),
    command: data.get(#command, or: $value.command),
    color: data.get(#color, or: $value.color),
    size: data.get(#size, or: $value.size),
    icon: data.get(#icon, or: $value.icon),
  );

  @override
  ButtonCopyWith<$R2, Button, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t) =>
      _ButtonCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

