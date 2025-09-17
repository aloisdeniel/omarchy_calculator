import 'package:calc_engine/calc_engine.dart';

sealed class AppCommand {
  const AppCommand();
}

class CalculatorCommand extends AppCommand {
  const CalculatorCommand(this.command);
  final Command command;
}

class ToggleHistoryCommand extends AppCommand {
  const ToggleHistoryCommand();
}

class NextButtonLayoutCommand extends AppCommand {
  const NextButtonLayoutCommand();
}

class PreviousButtonLayoutCommand extends AppCommand {
  const PreviousButtonLayoutCommand();
}
