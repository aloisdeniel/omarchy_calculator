import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_omarchy/preview.dart';
import 'package:omarchy_calculator/src/app.dart';
import 'package:omarchy_calculator/src/services/database/database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDatabase.init();

  final isPreview = kIsWeb;
  final app = const CalculatorApp();
  runApp(isPreview ? OmarchyPreview(children: [app]) : app);
}
