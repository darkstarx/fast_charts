import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:optional/optional.dart';

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
  /// The data to present on the diagram.
  final Map<D, T> data;

  /// The functor defines the color of the piece of series.
  ///
  /// It receives the domain and value, and must return the color of this pair.
  final ColorAccessor<D, T> colorAccessor;

  /// The functor defines numeric representation of the piece of series.
  ///
  /// It receives the value of type [T] which should be numerically presented on
  /// the diagram. The purpose of this functor is to extract the numeric value
  /// from thr value of type [T].
  final MeasureAccessor<T> measureAccessor;

  /// The functor defines the label on the piece of series.
  ///
  /// It receives the domain, value and percentage of total summ of values in
  /// the series, and can return a label or null if there is nothing to present.
  final LabelAccessor<D, T>? labelAccessor;

  const Series({
    required this.data,
    required this.colorAccessor,
    required this.measureAccessor,
    this.labelAccessor,
  });

  Series<D, T> copyWith({
    final Map<D, T>? data,
    final ColorAccessor<D, T>? colorAccessor,
    final MeasureAccessor<T>? measureAccessor,
    final Optional<LabelAccessor<D, T>>? labelAccessor,
  }) => Series<D, T>(
    data: data ?? this.data,
    colorAccessor: colorAccessor ?? this.colorAccessor,
    measureAccessor: measureAccessor ?? this.measureAccessor,
    labelAccessor: labelAccessor == null
      ? this.labelAccessor
      : labelAccessor.value,
  );
}


bool seriesAreDifferent<D, T>(
  final List<Series<D, T>> data1,
  final List<Series<D, T>> data2,
)
{
  if (data1.length != data2.length) return true;
  for (var i = 0; i < data1.length; ++i) {
    if (!mapEquals(data1[i].data, data2[i].data)) return true;
  }
  return false;
}


bool seriesAreCompatible<D, T>(
  final List<Series<D, T>> data1,
  final List<Series<D, T>> data2,
)
{
  final s1 = data1.map((e) => e.data.keys.toList()).expand((e) => e).toSet();
  final s2 = data2.map((e) => e.data.keys.toList()).expand((e) => e).toSet();
  return setEquals(s1, s2);
}


/// A SeriesComparator is used to compare chart data to decide whether to apply
/// animation between the current and the new datasets.
typedef SeriesComparator<D, T> = bool Function(
  List<Series<D, T>> data1,
  List<Series<D, T>> data2,
);

/// Defines a [double] representation of a value of type [T].
typedef MeasureAccessor<T> = double Function(T value);

/// Defines the color of a value of type [T] which is located in the domain [D].
typedef ColorAccessor<D, T> = Color Function(D domain, T value);
