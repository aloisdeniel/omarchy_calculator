import 'package:omarchy_calculator/src/engine/tokenize.dart';

/// Extract numerical input from commands
String input(List<Token> tokens) {
  if (tokens.isEmpty) {
    return '';
  }

  final lastEqual = tokens.lastIndexOf(
    const OperatorToken(OperatorTokenType.equals),
  );

  if (lastEqual >= 0) {
    tokens = tokens.skip(lastEqual).toList();
  }

  final lastNumber = tokens.whereType<NumberToken>().lastOrNull;
  if (lastNumber == null) {
    return '';
  }

  return lastNumber.value;
}
