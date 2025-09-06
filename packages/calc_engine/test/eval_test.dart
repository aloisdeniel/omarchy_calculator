import 'dart:convert';
import 'dart:io';

import 'package:calc_engine/calc_engine.dart';
import 'package:decimal/decimal.dart';
import 'package:test/test.dart';

void testEval({
  required Expression expr,
  required EvalResult Function(Expression expr) expected,
  String? description,
}) {
  var effectiveDescription = expr.toString();

  if (description != null) {
    effectiveDescription = '$description: $effectiveDescription';
  }
}

void main() {
  final data = Directory(
    'test/data',
  ).listSync().whereType<File>().where((x) => x.path.endsWith('.json'));
  for (final file in data) {
    group(file.uri.pathSegments.last, () {
      final content = file.readAsStringSync();
      final tests = jsonDecode(content) as Map<String, dynamic>;
      final contextVal = tests['context'];
      final context = contextVal is Map<String, dynamic>
          ? CalcContext.fromConfig(contextVal)
          : CalcContext();
      final cases = tests['cases'] as List<dynamic>;
      for (final testCase in cases) {
        final values = testCase as List<dynamic>;
        test(values.first, () {
          final commandsArg = values[0] as String;
          final expressionArg = values[1] as String;
          final resultArg = values[2] as String;
          final commands = Command.parse(commandsArg);
          final tokens = tokenize(commands);
          final expression = parse(context, tokens);

          expect(
            expression.toString(),
            equals(expressionArg),
            reason: 'Expression must be the expected value',
          );

          final result = eval(context, expression);
          if (resultArg.startsWith('[ERR]:')) {
            expect(
              result,
              isA<FailureEval>(),
              reason: 'Result must be a failure',
            );
            final errorMessage = resultArg.substring(6);
            expect(
              (result as FailureEval).error.toString(),
              contains(errorMessage),
              reason: 'Error message must contain expected text',
            );
            return;
          } else {
            expect(
              result,
              isA<SuccessEval>(),
              reason: 'Result must be a success',
            );
            expect(
              (result as SuccessEval).result.round(scale: 4),
              equals(Decimal.parse(resultArg)),
              reason: 'Result must be the expected value',
            );
          }
        });
      }
    });
  }
}
