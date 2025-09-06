import 'dart:async';

import 'package:calc_engine/calc_engine.dart';
import 'package:flutter/widgets.dart';
import 'package:omarchy_calculator/src/features/calculator/state/event.dart';

import 'state.dart';

export 'state.dart';

class CalculatorNotifier extends ChangeNotifier {
  late final List<CalculatorState> _current = <CalculatorState>[
    CalculatorState.empty(context),
  ];

  final context = CalcContext();
  Decimal _memory = Decimal.zero;

  CalculatorState get state => _current.last;

  final _events = StreamController<CalculatorEvent>.broadcast();

  Stream<CalculatorEvent> get events => _events.stream;

  void execute(Command action) {
    if (action is Memory) {
      switch (action) {
        case MemoryAdd():
          _memory += switch (state.result) {
            SuccessEval(:final result) => result,
            FailureEval() => Decimal.zero,
          };
        case MemorySubtract():
          _memory -= switch (state.result) {
            SuccessEval(:final result) => result,
            FailureEval() => Decimal.zero,
          };
        case MemoryRecall():
          var commands = [...state.commands];
          if (state.tokens.isNotEmpty && state.tokens.last is NumberToken) {
            commands.add(Command.operator(OperatorType.multiply));
          }
          commands.addAll(Command.parse(_memory.toString()));
          final newState = CalculatorState.eval(
            context,
            state.id + 1,
            commands,
          );
          _current.add(newState);
          notifyListeners();
          return;
        case MemoryClear():
          _memory = Decimal.zero;
          return;
      }
    }
    if (action is ClearAll) {
      final newId = state.id + 1;
      _current.clear();
      _current.add(CalculatorState.empty(context, id: newId));
      notifyListeners();
      return;
    }
    final commands = [...state.commands, action];
    final newState = CalculatorState.eval(context, state.id + 1, commands);

    if (newState.isResult) {
      _current.clear();
      _events.add(CalculatorCalculateResultEvent(newState));
    }

    _current.add(newState);

    notifyListeners();
  }

  void restore(CalculatorState state) {
    final newId = this.state.id + 1;
    _current.clear();
    _current.add(state.copyWith(id: newId, input: ''));
    notifyListeners();
  }

  @override
  void dispose() {
    _events.close();
    super.dispose();
  }
}
