# calc_engine

This package provides a calculation engine for performing various mathematical operations. It supports basic arithmetic, advanced mathematical functions, and custom calculations.

## Quick Start

```dart
import 'package:calc_engine/calc_engine.dart';

void main() {
  final context = CalcContext();
  final commands = Command.parse('3 + 5 * (2 - 8)');
  final tokens = tokenize(commands);
  final expression = parse(context, tokens);
  final result = eval(context, expression);
  switch (result) {
    case SuccessEval(:final result):
      print('Success: $result'); // Output: Success: -27
    case FailureEval(:final error):
      print('Failed: $error');
  }
}
```

