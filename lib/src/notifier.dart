import 'package:decimal/decimal.dart';
import 'package:omarchy_calculator/src/engine/command.dart';
import 'package:flutter/widgets.dart';
import 'package:omarchy_calculator/src/engine/eval.dart';
import 'package:omarchy_calculator/src/engine/parse.dart';
import 'package:omarchy_calculator/src/engine/tokenize.dart';
import 'package:omarchy_calculator/src/engine/input.dart' as ei;

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
  });

  factory CalculatorState.empty({int id = 0, Decimal? result}) =>
      CalculatorState(
        id: id,
        commands: [],
        tokens: [],
        input: '',
        isResult: false,
        expression: const EmptyExpression(),
        result: SuccessEval(EmptyExpression(), result ?? Decimal.zero),
        dateTime: DateTime.now(),
      );

  final int id;
  final List<Command> commands;
  final List<Token> tokens;
  final Expression expression;
  final EvalResult result;
  final DateTime dateTime;
  final String input;
  final bool isResult;

  CalculatorState copyWith({int? id, String? input}) {
    return CalculatorState(
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

class CalculatorNotifier extends ChangeNotifier {
  final List<CalculatorState> _current = <CalculatorState>[
    CalculatorState.empty(),
  ];

  final List<CalculatorState> _history = <CalculatorState>[];

  CalculatorState get state => _current.last;

  List<CalculatorState> get history => _history;

  void execute(Command action) {
    if (action is ClearAll) {
      final newId = state.id + 1;
      _current.clear();
      _current.add(CalculatorState.empty(id: newId));
      notifyListeners();
      return;
    }
    final isResult = action is Equals;
    final commands = [...state.commands, action];
    var tokens = tokenize(commands);
    final rawExpression = parse(tokens);
    final expression = evalPreviousExpressions(rawExpression);
    final result = eval(expression);
    final input = ei.input(tokens);

    final newState = CalculatorState(
      id: state.id + 1,
      commands: commands,
      input: input,
      tokens: tokens,
      isResult: isResult,
      expression: expression,
      result: result,
      dateTime: DateTime.now(),
    );

    if (isResult) {
      _current.clear();
      _history.insert(0, newState);
    }

    _current.add(newState);

    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }

  void restore(CalculatorState state) {
    final newId = this.state.id + 1;
    _current.clear();
    _current.add(state.copyWith(id: newId, input: ''));
    notifyListeners();
  }
}
