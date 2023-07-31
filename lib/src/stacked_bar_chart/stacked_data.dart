import 'package:flutter/painting.dart';

import '../chart_label.dart';


class BarChartStacks
{
  final List<BarChartStack> stacks;
  final Axis valueAxis;
  final bool inverted;

  const BarChartStacks({
    required this.stacks,
    this.valueAxis = Axis.vertical,
    this.inverted = false,
  });

  BarChartStacks operator *(final double ratio) => BarChartStacks(
    stacks: stacks.map((e) => e * ratio).toList(),
    valueAxis: valueAxis,
    inverted: inverted,
  );
}


class BarChartStack
{
  final String domain;
  final List<BarChartSegment> segments;
  final Radius radius;

  Iterable<BarChartSegment> get lowerSegments
    => segments.where((e) => e.value < 0);

  Iterable<BarChartSegment> get upperSegments
    => segments.where((e) => e.value > 0);

  double get lower => lowerSegments.fold(0.0, (s, e) => s + e.value);

  double get upper => upperSegments.fold(0.0, (s, e) => s + e.value);

  ({
    List<(int, BarChartSegment)> lower,
    List<(int, BarChartSegment)> upper,
  }) get dividedSegments
  {
    final lower = <(int, BarChartSegment)>[], upper = <(int, BarChartSegment)>[];
    for (var i = 0; i < segments.length; ++i) {
      final segment = segments[i];
      if (segment.value < 0) {
        lower.add((i, segment));
      } else if (segment.value > 0) {
        upper.add((i, segment));
      }
    }
    return (lower: lower, upper: upper);
  }

  ({ double lower, double upper }) get summs
  {
    var lower = 0.0, upper = 0.0;
    for (final segment in segments) {
      if (segment.value < 0) {
        lower += segment.value;
      } else {
        upper += segment.value;
      }
    }
    return (lower: lower, upper: upper);
  }

  double get absSumm => segments.fold(0.0, (s, e) => s + e.value.abs());

  const BarChartStack({
    required this.domain,
    required this.segments,
    this.radius = Radius.zero,
  });

  BarChartStack operator *(final double ratio) => BarChartStack(
    domain: domain,
    segments: segments.map((e) => e * ratio).toList(),
  );
}


class BarChartSegment
{
  final double value;
  final Color color;
  final ChartLabel? label;

  const BarChartSegment({
    required this.value,
    required this.color,
    this.label,
  });

  BarChartSegment copyWith({
    final double? value,
    final Color? color,
    final ChartLabel? label,
  }) => BarChartSegment(
    value: value ?? this.value,
    color: color ?? this.color,
    label: label ?? this.label,
  );

  BarChartSegment operator *(final double ratio) => BarChartSegment(
    value: value * ratio,
    color: color,
    label: label,
  );
}
