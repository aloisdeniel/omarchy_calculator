import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class AppKeyboardListener extends StatefulWidget {
  const AppKeyboardListener({
    super.key,
    required this.child,
    required this.onKey,
  });

  final ValueChanged<KeyEvent> onKey;
  final Widget child;

  @override
  State<AppKeyboardListener> createState() => _AppKeyboardListenerState();
}

class _AppKeyboardListenerState extends State<AppKeyboardListener> {
  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handler);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handler);
    super.dispose();
  }

  bool _handler(KeyEvent event) {
    widget.onKey(event);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
