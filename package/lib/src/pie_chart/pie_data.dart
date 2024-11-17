import 'package:flutter/painting.dart';

import '../chart_label.dart';


class Pie<D>
{
  final List<Sector<D>> sectors;

  const Pie({
    required this.sectors,
  });
}


class Sector<D>
{
  final D domain;
  final double value;
  final Color color;
  final ChartLabel? label;

  const Sector({
    required this.domain,
    required this.value,
    required this.color,
    this.label,
  });

  @override
  String toString() => '$runtimeType $domain: $value[${label?.value}]';
}
