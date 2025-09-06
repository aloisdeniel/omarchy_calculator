import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:omarchy_calculator/preview.dart';
import 'package:omarchy_calculator/src/app.dart';

void main() {
  final isPreview = kIsWeb || !Platform.isLinux;
  final app = const CalculatorApp();
  runApp(isPreview ? OmarchyPreview(children: [app]) : app);
}
