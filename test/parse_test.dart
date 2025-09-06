import 'package:flutter_test/flutter_test.dart';
import 'package:omarchy_calculator/src/engine/parse.dart';
import 'package:omarchy_calculator/src/engine/tokenize.dart';

import 'datasets/parse.dart';

void testParse({required List<Token> tokens, required Expression expected}) {
  var effectiveDescription = tokens.isNotEmpty
      ? tokens.map((e) => e.toString()).join(' ')
      : 'empty';

  test(effectiveDescription, () {
    expect(parse(tokens), equals(expected));
  });
}

void main() {
  for (final (desc, tests) in parseDataSet) {
    group(desc, () {
      for (final (tokens, expected) in tests) {
        testParse(tokens: tokens, expected: expected);
      }
    });
  }
}
