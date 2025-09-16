import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:omarchy_calculator/src/features/config/state/config.dart';
import 'package:omarchy_calculator/src/features/config/state/default_config.dart';
import 'package:path_provider/path_provider.dart';

class ConfigNotifier extends ChangeNotifier {
  ConfigNotifier({File? file}) : _file = file;

  late Config _config;
  Config get config => _config;

  final File? _file;
  StreamSubscription<Config?>? _subscription;

  Future<void> init() async {
    if (kIsWeb) {
      _config = Config.defaults();
      notifyListeners();
      return;
    }
    final file = _file ?? await _defaultFile();
    Config? loaded;
    try {
      await _create(file);
      loaded = await _load(file);
      _config = loaded ?? Config.defaults();
      notifyListeners();

      _subscription = _watch(file).listen((c) {
        _config = c ?? Config.defaults();
        notifyListeners();
      });
    } catch (e) {
      loaded = Config.defaults();
    }
  }

  Future<void> save(String yaml) async {
    if (kIsWeb) {
      _config = Config.fromYaml(yaml);
      notifyListeners();
      return;
    }
    final file = await _defaultFile();
    await file.writeAsString(yaml);
    _config = Config.fromYaml(yaml);
    notifyListeners();
  }

  /// Loads the configuration from the specified file.
  static Future<Config?> _load(File? file) async {
    final effectiveFile = file ?? await _defaultFile();
    if (effectiveFile.existsSync()) {
      final content = await effectiveFile.readAsString();
      return Config.fromYaml(content);
    }
    return null;
  }

  /// Returns the default configuration file path.
  static Future<File> _defaultFile() async {
    if (Platform.isLinux) {
      final home =
          Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
      return File('$home/.config/$packageId/calculator.yaml');
    }
    final doc = await getApplicationDocumentsDirectory();
    return File('${doc.path}/config.yaml');
  }

  /// Creates the configuration file with default settings if it does not exist.
  static Future<void> _create(File file) async {
    if (!file.existsSync()) {
      await file.create(recursive: true);
      await file.writeAsString(defaultConfig.trim());
    }
  }

  /// Observes changes to the configuration file and yields updated Config objects.
  static Stream<Config?> _watch(File file) async* {
    await for (final event in file.watch()) {
      switch (event) {
        case FileSystemModifyEvent(contentChanged: true):
          yield await _load(file);
          break;
        default:
      }
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
