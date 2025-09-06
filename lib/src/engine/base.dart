enum Constant {
  pi,
  euler;

  @override
  String toString() {
    return switch (this) {
      Constant.pi => 'π',
      Constant.euler => 'e',
    };
  }
}

enum MathFunction {
  sin,
  cos,
  tan,
  square,
  squareRoot,
  percent;

  @override
  String toString() {
    switch (this) {
      case MathFunction.sin:
        return 'sin';
      case MathFunction.cos:
        return 'cos';
      case MathFunction.tan:
        return 'tan';
      case MathFunction.square:
        return 'x²';
      case MathFunction.squareRoot:
        return '√';
      case MathFunction.percent:
        return '%';
    }
  }
}
