import 'package:calc_engine/calc_engine.dart';
import 'package:omarchy_calculator/src/services/database/history.dart';

class HistoryItemState {
  const HistoryItemState({required this.item, required this.expression});
  final HistoryItem item;
  final Expression? expression;
}
