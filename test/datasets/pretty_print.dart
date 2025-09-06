import 'dart:io';

import 'parse.dart';

void main() {
  final result = StringBuffer();
  for (final (desc, tests) in parseDataSet) {
    result.writeln(desc);
    for (final (tokens, expected) in tests) {
      result.writeln(
        '  ${tokens.map((e) => e.toString()).join(' ')}  : $expected',
      );
    }
  }
  File('parse.txt').writeAsStringSync(result.toString());
}
