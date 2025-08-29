import 'package:omarchy_calculator/src/engine/tokenize.dart';

/// Extract numerical input from commands
String input(List<Token> tokens) {
  if (tokens.isEmpty) {
    return '';
  }
  final lastNumber = tokens.whereType<NumberToken>().lastOrNull;
  if (lastNumber == null) {
    return '';
  }

  return lastNumber.value;
}
