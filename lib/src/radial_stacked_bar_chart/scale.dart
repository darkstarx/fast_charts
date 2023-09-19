class RadialScale
{
  /// The minimal measure on the radial scale for negative values.
  ///
  /// If defined, all arcs will adjust to this minimum, otherwise the maximal
  /// positive measure among all domains will fit all available degrees of the
  /// circle, and other positive arcs will adjust to this measure.
  ///
  /// It can't be more than zero, otherwise it'll be clamped to zero and none of
  /// negative arcs will be shown.
  ///
  /// It's null by default.
  final double min;

  /// The maximal measure on the radial scale for positive values.
  ///
  /// If defined, all positive arcs will adjust to this maximum, otherwise the
  /// maximal positive measure among all domains will fit all available degrees
  /// of the circle, and other positive arcs will adjust to this measure.
  ///
  /// It can't be less than zero, otherwise it'll be clamped to zero and none of
  /// positive arcs will be shown.
  ///
  /// It's null by default.
  final double max;

  const RadialScale(this.min, this.max);

  @override
  bool operator ==(final Object other) => other is RadialScale
    && other.min == min
    && other.max == max;

  @override
  int get hashCode => Object.hash(min, max);

  @override
  String toString() => 'RadialScale ($min, $max)';
}
