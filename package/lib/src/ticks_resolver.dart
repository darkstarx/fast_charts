abstract interface class TicksResolver
{
  List<double> getTickValues({
    required final double minValue,
    required final double maxValue,
    required final double axisSize,
  });
}


class SimpleTicksResolver implements TicksResolver
{
  @override
  List<double> getTickValues({
    required final double minValue,
    required final double maxValue,
    required final double axisSize,
  })
  {
    final tickValues = [ minValue, maxValue ]..sort();
    if (minValue < 0 && maxValue > 0) {
      tickValues.insert(1, 0.0);
    }
    return tickValues;
  }
}
