import 'package:flutter_omarchy/flutter_omarchy.dart';

class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const OmarchyScaffold(child: OmarchyTextInput(maxLines: null));
  }
}
