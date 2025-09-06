import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_omarchy/flutter_omarchy.dart';

/// All the app in a simulated Omarchy desktop.
///
/// This is for demonstration purpose on web.
class OmarchyPreview extends StatefulWidget {
  const OmarchyPreview({
    super.key,
    required this.children,
    this.desktopBarPadding,
    this.windowConstraints,
  });

  final EdgeInsetsGeometry? desktopBarPadding;
  final List<Widget> children;
  final List<BoxConstraints>? windowConstraints;

  @override
  State<OmarchyPreview> createState() => _OmarchyPreviewState();
}

class _OmarchyPreviewState extends State<OmarchyPreview> {
  String theme = 'tokyo-night';
  final allThemes = OmarchyColorThemes.all.entries.toList();

  int selectedWorkspace = 0;

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
    final insets = MediaQuery.viewInsetsOf(context);
    return OmarchyThemeProvider(
      data: OmarchyThemeData(colors: colors, text: text),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          children: [
            OmarchyDesktopBar(
              onNextTheme: _nextTheme,
              workspaces: widget.children.length,
              selected: selectedWorkspace,
              onSelectedChanged: (i) {
                setState(() {
                  selectedWorkspace = i;
                });
              },

              padding: widget.desktopBarPadding,
            ),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: FadeInImage(
                      placeholder: MemoryImage(kTransparentImage),
                      image: NetworkImage(
                        '/omarchy_calculator/wallpapers/$theme.jpg',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.all(14.0) +
                        EdgeInsets.only(bottom: insets.bottom),
                    child: Center(
                      child: ConstrainedBox(
                        constraints:
                            widget.windowConstraints?[selectedWorkspace] ??
                            BoxConstraints.expand(),
                        child: OmarchyWindow(
                          child: widget.children[selectedWorkspace],
                        ),
                      ),
                    ),
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
  const OmarchyDesktopBar({
    super.key,
    required this.workspaces,
    required this.onNextTheme,
    required this.selected,
    required this.onSelectedChanged,
    this.padding,
  });

  final VoidCallback onNextTheme;
  final int workspaces;
  final int selected;
  final ValueChanged<int> onSelectedChanged;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    final padding =
        this.padding ??
        EdgeInsets.only(
          left: 8.0 + (!kIsWeb && Platform.isMacOS ? 54 : 0),
          right: 8.0,
        );
    return Container(
      height: 24,
      decoration: BoxDecoration(color: theme.colors.background),
      child: ListView(
        padding: padding,
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
          for (var i = 0; i < workspaces; i++)
            PointerArea(
              onTap: () => onSelectedChanged(i),
              child: AspectRatio(
                aspectRatio: 1,
                child: Center(
                  child: selected == i
                      ? Container(
                          width: 6,
                          height: 8,
                          decoration: BoxDecoration(
                            color: theme.colors.bright.white,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        )
                      : Text(
                          '${i + 1}',
                          style: theme.text.normal.copyWith(fontSize: 12),
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
