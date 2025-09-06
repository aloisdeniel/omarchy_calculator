import 'package:omarchy_calculator/src/features/calculator/state/state.dart';

sealed class CalculatorEvent {
  const CalculatorEvent();
}

class CalculatorCalculateResultEvent extends CalculatorEvent {
  const CalculatorCalculateResultEvent(this.state);

  final CalculatorState state;
}
