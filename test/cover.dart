import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_omarchy/flutter_omarchy.dart';
import 'package:omarchy_calculator/preview.dart';
import 'package:omarchy_calculator/src/app.dart';

import 'app_golden_test.dart';

class OmarchyCalculatorCover extends StatelessWidget {
  const OmarchyCalculatorCover({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyThemeData(
      colors: OmarchyColorThemes.tokyoNight,
      text: OmarchyTextStyleData.fallback(),
    );
    final app = CalculatorApp(
      notifier: CalculatorGoldenNotifier(input: '1+2', id: 0, history: []),
      theme: theme,
    );
    return LayoutBuilder(
      builder: (context, layout) {
        return OmarchyThemeProvider(
          data: theme,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.file(
                    File('test/assets/tokyonight-wallpaper.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 64,
                  left: (layout.maxWidth - 300) / 2,
                  width: 300,
                  child: Column(
                    spacing: 12,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      OmarchyLogo(color: theme.colors.foreground),
                      Text(
                        'Calculator',
                        style: theme.text.normal.copyWith(
                          fontSize: 24,
                          color: theme.colors.foreground,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: (layout.maxWidth - 700) / 2,
                  width: 700,
                  top: 200,
                  height: 600,
                  child: ShaderMask(
                    shaderCallback: (rect) {
                      return LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.9, 1.0],
                        colors: [
                          Colors.black,
                          Colors.black,
                          Colors.transparent,
                        ],
                      ).createShader(
                        Rect.fromLTRB(0, 0, rect.width, rect.height),
                      );
                    },
                    blendMode: BlendMode.dstIn,
                    child: OmarchyWindow(child: app),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
