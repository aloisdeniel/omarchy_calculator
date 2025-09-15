import 'package:calc_engine/calc_engine.dart';
import 'package:omarchy_calculator/src/features/calculator/state/state.dart';

sealed class CalculatorEvent {
  const CalculatorEvent();
}

class CalculatorCommandEvent extends CalculatorEvent {
  const CalculatorCommandEvent(this.command);

  final Command command;
}

class CalculatorCalculateResultEvent extends CalculatorEvent {
  const CalculatorCalculateResultEvent(this.state);

  final CalculatorState state;
}
