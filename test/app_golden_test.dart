import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_omarchy/flutter_omarchy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omarchy_calculator/src/app.dart';
import 'package:flutter/foundation.dart';
import 'package:omarchy_calculator/src/engine/command.dart';
import 'package:omarchy_calculator/src/notifier.dart';

import 'cover.dart';

Future<void> testApp({
  required int id,
  required String description,
  required Size size,
  required String input,
  List<CalculatorState> history = const [],
}) async {
  testWidgets(description, (tester) async {
    const columns = 4;
    final rows = (OmarchyColorThemes.all.length / columns.toDouble()).ceil();
    tester.view.physicalSize = Size(size.width * columns, size.height * rows);
    tester.view.devicePixelRatio = 1.0;

    final key = UniqueKey();
    await tester.pumpWidget(
      Directionality(
        key: key,
        textDirection: TextDirection.ltr,
        child: Wrap(
          children: [
            for (final colors in OmarchyColorThemes.all.entries)
              SizedBox.fromSize(
                size: size,
                child: CalculatorApp(
                  notifier: CalculatorGoldenNotifier(
                    id: id,
                    input: input,
                    history: history,
                  ),
                  theme: OmarchyThemeData(
                    colors: colors.value,
                    text: const OmarchyTextStyleData.fallback(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(key),
      matchesGoldenFile(
        'goldens/${size.width.toInt()}x${size.height.toInt()}/$id.png',
      ),
    );
  });
}

Future<void> buildCover() async {
  testWidgets('cover', (tester) async {
    await tester.runAsync(() async {
      await precacheImage(
        FileImage(File("test/assets/tokyonight-wallpaper.png")),
        tester.binding.rootElement!,
      );
    });
    final size = Size(1000, 800);
    tester.view.physicalSize = size * 2;
    tester.view.devicePixelRatio = 2.0;

    final key = UniqueKey();
    await tester.pumpWidget(OmarchyCalculatorCover(key: key));
    await tester.pumpAndSettle();

    await expectLater(find.byKey(key), matchesGoldenFile('goldens/cover.png'));
  });
}

Future<void> loadFonts() async {
  if (kIsWeb) return; // Skip on web platform

  // Load the custom font for golden tests
  final fontLoader = FontLoader(
    'packages/flutter_omarchy/CaskaydiaMono Nerd Font Mono',
  );

  // Load regular font
  final regularFont = File('test/fonts/CaskaydiaMonoNerdFontMono-Regular.ttf');
  if (await regularFont.exists()) {
    final bytes = await regularFont.readAsBytes();
    fontLoader.addFont(Future.value(ByteData.sublistView(bytes)));
  }

  // Load bold font
  final boldFont = File('test/fonts/CaskaydiaMonoNerdFontMono-Bold.ttf');
  if (await boldFont.exists()) {
    final bytes = await boldFont.readAsBytes();
    fontLoader.addFont(Future.value(ByteData.sublistView(bytes)));
  }

  // Load italic font
  final italicFont = File('test/fonts/CaskaydiaMonoNerdFontMono-Italic.ttf');
  if (await italicFont.exists()) {
    final bytes = await italicFont.readAsBytes();
    fontLoader.addFont(Future.value(ByteData.sublistView(bytes)));
  }

  await fontLoader.load();
}

void main() {
  if (TrivialGoldenFileComparator.ignoreGoldens) {
    goldenFileComparator = const TrivialGoldenFileComparator();
  }

  setUpAll(() async {
    await loadFonts();
  });

  const sizes = [Size(300, 400), Size(700, 900), Size(1400, 1000)];
  final states = [(0, ''), (1, '1+2='), (2, '2 * pi * (44 - 12 + 64) =')];

  for (final size in sizes) {
    group(size, () {
      for (final (id, input) in states) {
        group('state $id', () {
          testApp(id: id, description: input, size: size, input: input);
        });
      }
    });
  }

  buildCover();
}

class CalculatorGoldenNotifier extends ChangeNotifier
    implements CalculatorNotifier {
  CalculatorGoldenNotifier({
    required this.id,
    required this.input,
    this.history = const [],
  });

  final int id;
  final String input;

  @override
  CalculatorState get state => CalculatorState.eval(id, Command.parse(input));

  @override
  final List<CalculatorState> history;

  @override
  void clearHistory() {}

  @override
  void execute(Command action) {}

  @override
  void restore(CalculatorState state) {}
}

class TrivialGoldenFileComparator implements GoldenFileComparator {
  const TrivialGoldenFileComparator();

  static const ignoreGoldens = bool.fromEnvironment('ignore-goldens');

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) {
    return Future<bool>.value(true);
  }

  @override
  Future<void> update(Uri golden, Uint8List imageBytes) {
    throw StateError('Golden files should not be updated while ignored.');
  }

  @override
  Uri getTestUri(Uri key, int? version) {
    return key;
  }
}
