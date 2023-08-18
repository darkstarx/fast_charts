import 'dart:math';

import 'package:flutter/painting.dart';

import '../chart_label.dart';


class ChartBars
{
  final List<BarsGroup> groups;
  final Axis valueAxis;
  final bool inverted;

  const ChartBars({
    required this.groups,
    this.valueAxis = Axis.vertical,
    this.inverted = false,
  });

  ChartBars operator *(final double ratio) => ChartBars(
    groups: groups.map((e) => e * ratio).toList(),
    valueAxis: valueAxis,
    inverted: inverted,
  );
}


class BarsGroup
{
  final String domain;
  final List<Bar> bars;

  Iterable<Bar> get lowerBars
    => bars.where((e) => e.value < 0);

  Iterable<Bar> get upperBars
    => bars.where((e) => e.value > 0);

  double get lower => lowerBars.fold(0.0, (s, e) => min(s, e.value));

  double get upper => upperBars.fold(0.0, (s, e) => max(s, e.value));

  ({
    List<(int, Bar)> lower,
    List<(int, Bar)> zero,
    List<(int, Bar)> upper,
  }) get dividedBars
  {
    final lower = <(int, Bar)>[];
    final zero = <(int, Bar)>[];
    final upper = <(int, Bar)>[];
    for (var i = 0; i < bars.length; ++i) {
      final bar = bars[i];
      if (bar.value < 0) {
        lower.add((i, bar));
      } else if (bar.value > 0) {
        upper.add((i, bar));
      } else {
        zero.add((i, bar));
      }
    }
    return (lower: lower, zero: zero, upper: upper);
  }

  ({ double lower, double upper }) get extremes
  {
    var lower = 0.0, upper = 0.0;
    for (final bar in bars) {
      if (bar.value < 0) {
        lower = min(lower, bar.value);
      } else {
        upper = max(upper, bar.value);
      }
    }
    return (lower: lower, upper: upper);
  }

  const BarsGroup({
    required this.domain,
    required this.bars,
  });

  BarsGroup operator *(final double ratio) => BarsGroup(
    domain: domain,
    bars: bars.map((e) => e * ratio).toList(),
  );
}


class Bar
{
  final double value;
  final Color color;
  final Radius radius;
  final ChartLabel? label;

  const Bar({
    required this.value,
    required this.color,
    this.radius = Radius.zero,
    this.label,
  });

  Bar copyWith({
    final double? value,
    final Color? color,
    final Radius? radius,
    final ChartLabel? label,
  }) => Bar(
    value: value ?? this.value,
    color: color ?? this.color,
    radius: radius ?? this.radius,
    label: label ?? this.label,
  );

  Bar operator *(final double ratio) => Bar(
    value: value * ratio,
    color: color,
    radius: radius,
    label: label,
  );

  @override
  String toString() => 'Bar $value [${label?.value}]';
}
