import 'package:flutter/painting.dart';

import 'chart_label.dart';


/// Represents series of [data] with specified [color].
///
/// The [data] is the map where the key is domain value of type [D] (e.g. names,
/// dates, ranges, etc.), and value is measure of type [T].
///
/// The series must provide the [measureAccessor] which is used to convert data
/// measure to [double] value which is used to build the measure scale and show
/// values on the measure axis.
///
/// Also the Series can provide [labelAccessor] if labels are needed to be shown
/// on the diagram. It can return null value which is indicates that the label
/// for a specified value should not be displayed.
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

/// Converts the measure value of type [T] to [double] value.
typedef MeasureAccessor<T> = double Function(T value);
