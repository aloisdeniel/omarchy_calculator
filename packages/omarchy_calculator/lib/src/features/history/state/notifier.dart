import 'package:calc_engine/calc_engine.dart';
import 'package:flutter/widgets.dart';
import 'package:omarchy_calculator/src/features/calculator/state/notifier.dart';
import 'package:omarchy_calculator/src/features/history/state/state.dart';
import 'package:omarchy_calculator/src/services/database/database.dart';

class HistoryNotifier extends ChangeNotifier {
  HistoryNotifier({required this.context});

  final CalcContext context;
  final List<HistoryItemState> _history = <HistoryItemState>[];

  List<HistoryItemState> get history => _history;

  void restore() async {
    final result = await AppDatabase.instance.history.getAll();
    _history.clear();
    _history.addAll(
      result.items.map((x) {
        Expression? expression;
        try {
          final tokens = tokenize(x.commands);
          expression = parse(context, tokens);
        } catch (_) {
          // If parsing fails, we leave the expression as null
        }
        return HistoryItemState(item: x, expression: expression);
      }),
    );
    notifyListeners();
  }

  void addToHistory(CalculatorState newState) async {
    if (newState.result is FailureEval) {
      return;
    }
    final newItem = await AppDatabase.instance.history.insert(
      newState.expression
          .toTokens()
          .expand((tokens) => tokens.toCommands())
          .toList(),
      (newState.result as SuccessEval).result,
    );
    _history.insert(
      0,
      HistoryItemState(item: newItem, expression: newState.expression),
    );
    notifyListeners();
  }

  void clear() async {
    await AppDatabase.instance.history.clear();
    _history.clear();
    notifyListeners();
  }
}
