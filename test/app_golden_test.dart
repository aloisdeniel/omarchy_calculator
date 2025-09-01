import 'package:flutter/services.dart';
import 'package:flutter_omarchy/flutter_omarchy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omarchy_calculator/src/app.dart';

Future<void> testApp(
  String description,
  Size size,
  MapEntry<String, OmarchyColorThemeData> colors,
) async {
  setUpAll(() async {
    await loadFonts();
  });

  testWidgets(description, (tester) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      CalculatorApp(
        theme: OmarchyThemeData(
          colors: colors.value,
          text: OmarchyTextStyleData.fallback(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(CalculatorApp),
      matchesGoldenFile(
        'goldens/calculator_app_${size.width.toInt()}x${size.height.toInt()}_${colors.key}.png',
      ),
    );
  });
}

Future<void> loadFonts() async {
  final fontLoader = FontLoader('CaskaydiaMono Nerd Font Mono')
    ..addFont(
      rootBundle.load(
        'packages/flutter_omarchy/lib/fonts/CaskaydiaMonoNerdFontMono-Regular.ttf',
      ),
    )
    ..addFont(
      rootBundle.load(
        'packages/flutter_omarchy/lib/fonts/CaskaydiaMonoNerdFontMono-Bold.ttf',
      ),
    )
    ..addFont(
      rootBundle.load(
        'packages/flutter_omarchy/lib/fonts/CaskaydiaMonoNerdFontMono-Italic.ttf',
      ),
    );
  await fontLoader.load();
}

void main() {
  for (final colors in OmarchyColorThemes.all.entries)
    group(colors.key, () {
      testApp(
        'Calculator app renders correctly at 300x400',
        const Size(300, 400),
        colors,
      );
      testApp(
        'Calculator app renders correctly at 700x900',
        const Size(700, 900),
        colors,
      );
      testApp(
        'Calculator app renders correctly at 1400x1000',
        const Size(1400, 1000),
        colors,
      );
    });
}

