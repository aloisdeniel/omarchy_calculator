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
  });

  factory CalculatorState.empty({int id = 0, Decimal? result}) =>
      CalculatorState(
        id: id,
        commands: [],
        tokens: [],
        input: '',
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
      _current.add(CalculatorState.empty(id: state.id + 1));
      notifyListeners();
      return;
    }
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
      expression: expression,
      result: result,
      dateTime: DateTime.now(),
    );
    _current.add(newState);
    if (action is Equals) {
      _history.insert(0, newState);
    }

    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }
}
