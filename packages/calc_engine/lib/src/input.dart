import 'tokenize.dart';

/// Extract numerical input from commands
String input(List<Token> tokens) {
  if (tokens.isEmpty) {
    return '';
  }

  final lastEqual = tokens.lastIndexOf(const EqualsToken());

  if (lastEqual >= 0) {
    tokens = tokens.skip(lastEqual).toList();
  }

  final lastNumberIndex = tokens.lastIndexWhere((t) => t is NumberToken);
  if (lastNumberIndex < 0) {
    return '';
  }

  final lastNumber = tokens[lastNumberIndex] as NumberToken;
  var result = lastNumber.value.toString();

  if (lastNumberIndex == 0) {
    return result;
  }

  final precedingToken = tokens[lastNumberIndex - 1];
  if (precedingToken is OperatorToken &&
      precedingToken.operator == OperatorTokenType.minus) {
    result = '-$result';
  }

  return result;
}
