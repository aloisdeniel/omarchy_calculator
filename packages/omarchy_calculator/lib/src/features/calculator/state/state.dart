import 'package:calc_engine/calc_engine.dart' as ce;
import 'package:calc_engine/calc_engine.dart';

class CalculatorState {
  CalculatorState({
    required this.id,
    required this.input,
    required this.commands,
    required this.tokens,
    required this.expression,
    required this.result,
    required this.dateTime,
    required this.isResult,
    required this.context,
  });

  factory CalculatorState.empty(
    CalcContext context, {
    int id = 0,
    Decimal? result,
  }) => CalculatorState(
    context: context,
    id: id,
    commands: [],
    tokens: [],
    input: '',
    isResult: false,
    expression: const EmptyExpression(),
    result: SuccessEval(EmptyExpression(), result ?? Decimal.zero),
    dateTime: DateTime.now(),
  );

  static CalculatorState eval(
    CalcContext context,
    int id,
    List<Command> commands,
  ) {
    final effectiveTokens = tokenize(commands);
    final isResult =
        effectiveTokens.isNotEmpty && effectiveTokens.last is EqualsToken;
    final rawExpression = parse(context, effectiveTokens);
    final expression = evalPreviousExpressions(context, rawExpression);
    final result = ce.eval(context, expression);
    final input = ce.input(effectiveTokens);
    return CalculatorState(
      context: context,
      id: id,
      commands: commands,
      input: input,
      tokens: effectiveTokens,
      isResult: isResult,
      expression: expression,
      result: result,
      dateTime: DateTime.now(),
    );
  }

  final int id;
  final List<Command> commands;
  final List<Token> tokens;
  final Expression expression;
  final EvalResult result;
  final DateTime dateTime;
  final String input;
  final bool isResult;
  final CalcContext context;

  CalculatorState copyWith({int? id, String? input}) {
    return CalculatorState(
      context: context,
      id: id ?? this.id,
      input: input ?? this.input,
      tokens: tokens,
      expression: expression,
      result: result,
      dateTime: dateTime,
      isResult: isResult,
      commands: commands,
    );
  }
}
