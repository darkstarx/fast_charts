typedef DomainFormatter<D> = String Function(D domain);
typedef MeasureFormatter = String Function(double measure);

extension RoundingErrorRemover on double
{
  /// A less precise value to eliminate rounding errors from the number.
  ///
  /// Attempts to slice off very small floating point rounding effects for the
  /// given number.
  double get smooth
  {
    const multiplier = 1.0e9;
    return this > 100.0
      ? roundToDouble()
      : (this * multiplier).roundToDouble() / multiplier;
  }
}
