import 'package:flutter/painting.dart';

import 'chart_label.dart';


class Series<D, T>
{
  final Map<D, T> data;
  final Color color;
  final MeasureAccessor<T> measureAccessor;
  final LabelAccessor<T>? labelAccessor;

  const Series({
    required this.data,
    required this.color,
    required this.measureAccessor,
    this.labelAccessor,
  });
}

typedef MeasureAccessor<T> = double Function(T value);
