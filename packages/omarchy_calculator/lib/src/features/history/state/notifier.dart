import 'package:flutter/widgets.dart';
import 'package:omarchy_calculator/src/features/calculator/state/notifier.dart';

class HistoryNotifier extends ChangeNotifier {
  final List<CalculatorState> _history = <CalculatorState>[];

  List<CalculatorState> get history => _history;

  void addToHistory(CalculatorState newState) {
    _history.insert(0, newState);
    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }

  void clear() {
    _history.clear();
    notifyListeners();
  }
}
