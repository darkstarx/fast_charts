import 'package:flutter/painting.dart';


class StrokesConfig
{
  /// The color of strokes.
  final Color color;

  /// The thickness of strokes.
  final double width;

  /// Whether to draw strokes between segments.
  final bool inner;

  /// Whether to draw the stroke around the group.
  final bool outer;

  bool get effective => inner || outer;

  const StrokesConfig({
    this.color = const Color(0x00000000),
    this.width = 1.0,
    this.inner = false,
    this.outer = false,
  });

  StrokesConfig copyWith({
    final Color? color,
    final double? width,
    final bool? inner,
    final bool? outer,
  }) => StrokesConfig(
    color: color ?? this.color,
    width: width ?? this.width,
    inner: inner ?? this.inner,
    outer: outer ?? this.outer,
  );
}
