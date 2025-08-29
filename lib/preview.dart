import 'dart:typed_data';

import 'package:flutter_omarchy/flutter_omarchy.dart';
import 'package:omarchy_calculator/src/app.dart';

/// All the app in a simulated Omarchy desktop.
///
/// This is for demonstration purpose on web.
class OmarchyPreview extends StatefulWidget {
  const OmarchyPreview({super.key});

  @override
  State<OmarchyPreview> createState() => _OmarchyPreviewState();
}

class _OmarchyPreviewState extends State<OmarchyPreview> {
  String theme = 'tokyo-night';
  final allThemes = OmarchyColorThemes.all.entries.toList();

  void _nextTheme() {
    final currentIndex = allThemes.indexWhere(
      (element) => element.key == theme,
    );
    final nextIndex = (currentIndex + 1) % allThemes.length;
    setState(() {
      theme = allThemes[nextIndex].key;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = OmarchyColorThemes.all[theme]!;
    const text = OmarchyTextStyleData.fallback();
    final wallpaper = switch (theme) {
      _ =>
        'https://github.com/basecamp/omarchy/blob/master/themes/tokyo-night/backgrounds/1-scenery-pink-lakeside-sunset-lake-landscape-scenic-panorama-7680x3215-144.png?raw=true',
    };
    final insets = MediaQuery.viewInsetsOf(context);
    return OmarchyThemeProvider(
      data: OmarchyThemeData(colors: colors, text: text),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          children: [
            OmarchyDesktopBar(onNextTheme: _nextTheme),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: FadeInImage(
                      placeholder: MemoryImage(kTransparentImage),
                      image: NetworkImage(wallpaper),
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.all(14.0) +
                        EdgeInsets.only(bottom: insets.bottom),
                    child: OmarchyWindow(child: CalculatorApp()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OmarchyDesktopBar extends StatelessWidget {
  const OmarchyDesktopBar({super.key, required this.onNextTheme});

  final VoidCallback onNextTheme;

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    return Container(
      height: 24,
      decoration: BoxDecoration(color: theme.colors.background),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        scrollDirection: Axis.horizontal,
        children: [
          PointerArea(
            onTap: onNextTheme,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Center(
                child: Icon(
                  OmarchyIcons.faePaletteColor,
                  color: theme.colors.normal.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OmarchyWindow extends StatelessWidget {
  const OmarchyWindow({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Color(0x88000000), width: 0.5),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: theme.colors.border, width: 2),
        ),
        child: Opacity(opacity: 0.98, child: child),
      ),
    );
  }
}

final kTransparentImage = Uint8List.fromList(<int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
]);
