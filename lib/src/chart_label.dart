import 'package:flutter/painting.dart';

import 'label_position.dart';


class ChartLabel
{
  final String value;
  final TextStyle style;
  final LabelPosition position;
  final Alignment alignment;

  const ChartLabel(this.value, {
    this.style = const TextStyle(),
    this.position = LabelPosition.inside,
    this.alignment = Alignment.center,
  });
}

typedef LabelAccessor<T> = ChartLabel? Function(T value);
