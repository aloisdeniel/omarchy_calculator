import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:omarchy_calculator/src/engine/command.dart';
import 'package:omarchy_calculator/src/engine/eval.dart';
import 'package:omarchy_calculator/src/engine/parse.dart';
import 'package:omarchy_calculator/src/engine/tokenize.dart';
import 'package:omarchy_calculator/src/notifier.dart';

void main() {
  group('CalculatorNotifier', () {
    late CalculatorNotifier notifier;

    setUp(() {
      notifier = CalculatorNotifier();
    });

    test('initial state is empty', () {
      expect(notifier.state.id, equals(0));
      expect(notifier.state.commands, isEmpty);
      expect(notifier.state.tokens, isEmpty);
      expect(notifier.state.input, equals(''));
      expect(notifier.state.isResult, isFalse);
      expect(notifier.state.expression, isA<EmptyExpression>());
      expect(notifier.state.result, isA<SuccessEval>());
      expect(
        (notifier.state.result as SuccessEval).result,
        equals(Decimal.zero),
      );
      expect(notifier.history, isEmpty);
    });

    test('execute digit updates state correctly', () {
      notifier.execute(const Digit(5));

      expect(notifier.state.id, equals(1));
      expect(notifier.state.commands, equals([const Digit(5)]));
      expect(notifier.state.input, equals('5'));
      expect(notifier.state.isResult, isFalse);
      expect(notifier.state.expression, isA<NumberExpression>());
      expect(
        (notifier.state.expression as NumberExpression).value,
        equals(Decimal.fromInt(5)),
      );
    });

    test('execute multiple digits builds number', () {
      notifier.execute(const Digit(1));
      notifier.execute(const Digit(2));
      notifier.execute(const Digit(3));

      expect(notifier.state.id, equals(3));
      expect(
        notifier.state.commands,
        equals([const Digit(1), const Digit(2), const Digit(3)]),
      );
      expect(notifier.state.input, equals('123'));
      expect(notifier.state.expression, isA<NumberExpression>());
      expect(
        (notifier.state.expression as NumberExpression).value,
        equals(Decimal.fromInt(123)),
      );
    });

    test('execute decimal point works correctly', () {
      notifier.execute(const Digit(3));
      notifier.execute(const DecimalPoint());
      notifier.execute(const Digit(1));
      notifier.execute(const Digit(4));

      expect(notifier.state.input, equals('3.14'));
      expect(notifier.state.expression, isA<NumberExpression>());
      expect(
        (notifier.state.expression as NumberExpression).value,
        equals(Decimal.parse('3.14')),
      );
    });

    test('execute basic arithmetic operations', () {
      notifier.execute(const Digit(5));
      notifier.execute(const Operator(OperatorType.plus));
      notifier.execute(const Digit(3));

      expect(notifier.state.input, equals('3'));
      expect(notifier.state.expression, isA<BinaryExpression>());

      final expr = notifier.state.expression as BinaryExpression;
      expect(expr.operator, equals(BinaryOperator.add));
      expect((expr.left as NumberExpression).value, equals(Decimal.fromInt(5)));
      expect(
        (expr.right as NumberExpression).value,
        equals(Decimal.fromInt(3)),
      );
    });

    test('execute equals creates result and moves to history', () {
      notifier.execute(const Digit(5));
      notifier.execute(const Operator(OperatorType.plus));
      notifier.execute(const Digit(3));
      notifier.execute(const Equals());

      expect(notifier.state.isResult, isTrue);
      expect(notifier.state.result, isA<SuccessEval>());
      expect(
        (notifier.state.result as SuccessEval).result,
        equals(Decimal.fromInt(8)),
      );
      expect(notifier.history, hasLength(1));
      expect(notifier.history.first.input, equals(''));
    });

    test('execute equals with division by zero creates error', () {
      notifier.execute(const Digit(5));
      notifier.execute(const Operator(OperatorType.divide));
      notifier.execute(const Digit(0));
      notifier.execute(const Equals());

      expect(notifier.state.result, isA<FailureEval>());
      expect(
        (notifier.state.result as FailureEval).error,
        isA<DivisionByZeroError>(),
      );
      expect(notifier.history, hasLength(1));
    });

    test('execute ClearAll resets calculator', () {
      notifier.execute(const Digit(5));
      notifier.execute(const Operator(OperatorType.plus));
      notifier.execute(const Digit(3));

      final oldId = notifier.state.id;
      notifier.execute(const ClearAll());

      expect(notifier.state.id, equals(oldId + 1));
      expect(notifier.state.commands, isEmpty);
      expect(notifier.state.input, equals(''));
      expect(notifier.state.isResult, isFalse);
      expect(notifier.state.expression, isA<EmptyExpression>());
    });

    test('execute complex calculation with parentheses', () {
      // (2 + 3) * 4 = 20
      notifier.execute(const OpenParenthesis());
      notifier.execute(const Digit(2));
      notifier.execute(const Operator(OperatorType.plus));
      notifier.execute(const Digit(3));
      notifier.execute(const CloseParenthesis());
      notifier.execute(const Operator(OperatorType.multiply));
      notifier.execute(const Digit(4));
      notifier.execute(const Equals());

      expect(notifier.state.result, isA<SuccessEval>());
      expect(
        (notifier.state.result as SuccessEval).result,
        equals(Decimal.fromInt(20)),
      );
    });

    test('execute function operations', () {
      // 16 sqrt = 4
      notifier.execute(const Digit(1));
      notifier.execute(const Digit(6));
      notifier.execute(const SquareRoot());
      notifier.execute(const Equals());

      expect(notifier.state.result, isA<SuccessEval>());
      expect(
        (notifier.state.result as SuccessEval).result,
        equals(Decimal.fromInt(4)),
      );
    });

    test('clearHistory removes all history items', () {
      // Add some history first
      notifier.execute(const Digit(5));
      notifier.execute(const Operator(OperatorType.plus));
      notifier.execute(const Digit(3));
      notifier.execute(const Equals());

      notifier.execute(const Digit(2));
      notifier.execute(const Operator(OperatorType.multiply));
      notifier.execute(const Digit(4));
      notifier.execute(const Equals());

      expect(notifier.history, hasLength(2));

      notifier.clearHistory();
      expect(notifier.history, isEmpty);
    });

    test('restore state from history', () {
      // Create a calculation and save it
      notifier.execute(const Digit(7));
      notifier.execute(const Operator(OperatorType.multiply));
      notifier.execute(const Digit(6));
      notifier.execute(const Equals());

      final historicalState = notifier.history.first;
      final oldId = notifier.state.id;

      // Make a new calculation
      notifier.execute(const Digit(1));
      notifier.execute(const Digit(0));

      // Restore the historical state
      notifier.restore(historicalState);

      expect(
        notifier.state.id,
        equals(oldId + 3),
      ); // +1 for digit, +1 for digit, +1 for restore
      expect(notifier.state.input, equals(''));
      expect(notifier.state.commands, equals(historicalState.commands));
      expect(notifier.state.expression, equals(historicalState.expression));
      expect(notifier.state.result, equals(historicalState.result));
    });

    test('notifier notifies listeners on execute', () {
      var notifyCount = 0;
      notifier.addListener(() => notifyCount++);

      notifier.execute(const Digit(5));
      expect(notifyCount, equals(1));

      notifier.execute(const Operator(OperatorType.plus));
      expect(notifyCount, equals(2));

      notifier.execute(const Digit(3));
      expect(notifyCount, equals(3));

      notifier.execute(const Equals());
      expect(notifyCount, equals(4));
    });

    test('notifier notifies listeners on clearHistory', () {
      var notifyCount = 0;
      notifier.addListener(() => notifyCount++);

      // Add some history
      notifier.execute(const Digit(5));
      notifier.execute(const Equals());
      expect(notifyCount, equals(2));

      notifier.clearHistory();
      expect(notifyCount, equals(3));
    });

    test('notifier notifies listeners on restore', () {
      var notifyCount = 0;

      // Create some history first
      notifier.execute(const Digit(5));
      notifier.execute(const Equals());
      final historicalState = notifier.history.first;

      // Add listener after creating history
      notifier.addListener(() => notifyCount++);

      notifier.restore(historicalState);
      expect(notifyCount, equals(1));
    });

    test('state copyWith preserves unchanged values', () {
      notifier.execute(const Digit(5));
      notifier.execute(const Operator(OperatorType.plus));
      notifier.execute(const Digit(3));

      final originalState = notifier.state;
      final copiedState = originalState.copyWith(id: 999);

      expect(copiedState.id, equals(999));
      expect(copiedState.input, equals(originalState.input));
      expect(copiedState.commands, equals(originalState.commands));
      expect(copiedState.tokens, equals(originalState.tokens));
      expect(copiedState.expression, equals(originalState.expression));
      expect(copiedState.result, equals(originalState.result));
      expect(copiedState.isResult, equals(originalState.isResult));
    });

    test('state copyWith updates specified values', () {
      notifier.execute(const Digit(5));
      final originalState = notifier.state;
      final copiedState = originalState.copyWith(id: 999, input: 'test input');

      expect(copiedState.id, equals(999));
      expect(copiedState.input, equals('test input'));
    });

    test('percentage calculation works correctly', () {
      notifier.execute(const Digit(5));
      notifier.execute(const Digit(0));
      notifier.execute(const Percent());
      notifier.execute(const Equals());

      expect(notifier.state.result, isA<SuccessEval>());
      expect(
        (notifier.state.result as SuccessEval).result,
        equals(Decimal.parse('0.5')),
      );
    });

    test('toggle sign operation works correctly', () {
      notifier.execute(const Digit(5));
      notifier.execute(const ToggleSign());
      notifier.execute(const Equals());

      expect(notifier.state.result, isA<SuccessEval>());
      expect(
        (notifier.state.result as SuccessEval).result,
        equals(Decimal.fromInt(-5)),
      );
    });

    test('square operation works correctly', () {
      notifier.execute(const Digit(5));
      notifier.execute(const Square());
      notifier.execute(const Equals());

      expect(notifier.state.result, isA<SuccessEval>());
      expect(
        (notifier.state.result as SuccessEval).result,
        equals(Decimal.fromInt(25)),
      );
    });

    test('power operation works correctly', () {
      notifier.execute(const Digit(2));
      notifier.execute(const Power());
      notifier.execute(const Digit(3));
      notifier.execute(const Equals());

      expect(notifier.state.result, isA<SuccessEval>());
      expect(
        (notifier.state.result as SuccessEval).result,
        equals(Decimal.fromInt(8)),
      );
    });

    test('trigonometric functions work correctly', () {
      // Test 30 sin ≈ 0.5
      notifier.execute(const Digit(3));
      notifier.execute(const Digit(0));
      notifier.execute(const Sine());
      notifier.execute(const Equals());

      expect(notifier.state.result, isA<SuccessEval>());
      final result = (notifier.state.result as SuccessEval).result;
      expect(result.toDouble(), closeTo(0.5, 0.0001));
    });

    test('constants work correctly', () {
      notifier.execute(ConstantCommand(Constant.pi));
      notifier.execute(const Equals());

      expect(notifier.state.result, isA<SuccessEval>());
      final result = (notifier.state.result as SuccessEval).result;
      expect(result.toDouble(), closeTo(3.14159, 0.0001));
    });

    test('chaining calculations after equals', () {
      // 5 + 3 = 8
      notifier.execute(const Digit(5));
      notifier.execute(const Operator(OperatorType.plus));
      notifier.execute(const Digit(3));
      notifier.execute(const Equals());

      expect(
        (notifier.state.result as SuccessEval).result,
        equals(Decimal.fromInt(8)),
      );

      // Continue with * 2
      notifier.execute(const Operator(OperatorType.multiply));
      notifier.execute(const Digit(2));
      notifier.execute(const Equals());

      expect(
        (notifier.state.result as SuccessEval).result,
        equals(Decimal.fromInt(16)),
      );
      expect(notifier.history, hasLength(2));
    });

    test('complex nested expression evaluation', () {
      // Test (2 + 3) * 4 = 20
      notifier.execute(const OpenParenthesis());
      notifier.execute(const Digit(2));
      notifier.execute(const Operator(OperatorType.plus));
      notifier.execute(const Digit(3));
      notifier.execute(const CloseParenthesis());
      notifier.execute(const Operator(OperatorType.multiply));
      notifier.execute(const Digit(4));
      notifier.execute(const Equals());

      expect(notifier.state.result, isA<SuccessEval>());
      final result = (notifier.state.result as SuccessEval).result;
      expect(result, equals(Decimal.fromInt(20)));
    });

    test('error recovery after failed calculation', () {
      // Division by zero
      notifier.execute(const Digit(5));
      notifier.execute(const Operator(OperatorType.divide));
      notifier.execute(const Digit(0));
      notifier.execute(const Equals());

      expect(notifier.state.result, isA<FailureEval>());

      // New calculation should work
      notifier.execute(const Digit(3));
      notifier.execute(const Operator(OperatorType.plus));
      notifier.execute(const Digit(2));
      notifier.execute(const Equals());

      expect(notifier.state.result, isA<SuccessEval>());
      expect(
        (notifier.state.result as SuccessEval).result,
        equals(Decimal.fromInt(5)),
      );
    });
  });
}

