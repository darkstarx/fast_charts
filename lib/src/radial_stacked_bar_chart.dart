import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'radial_stacked_bar_chart/painter.dart';
import 'radial_stacked_bar_chart/scale.dart';
import 'radial_stacked_bar_chart/stacked_data.dart';
import 'series.dart';
import 'utils.dart';

export 'radial_stacked_bar_chart/scale.dart';


/// Shows several series of data in the form of arcs with a single center.
///
/// Domains of series are placed on different distances from the center of the
/// diagram, from smaller to bigger.
///
/// All series must contain data of the same type. It is not necessary for each
/// series to contain the same set of domains, if there is no value for some of
/// domains in some series, the series may not contain the value of this domain.
class RadialStackedBarChart<D, T> extends StatefulWidget
{
  /// The list of series to be shown.
  final List<Series<D, T>> data;

  /// The optional scale of the diagram.
  ///
  /// If defined, all positive and negative arcs will adjust to these maximums,
  /// otherwise the maximums of negative and positive arcs will be calculated
  /// based on the [data].
  ///
  /// It can be useful to set the same scale for several diagrams to compare
  /// values between these diagrams.
  ///
  /// It's null by default.
  final RadialScale? scale;

  /// The start angle of arcs.
  ///
  /// It's zero by default.
  final double angle;

  /// The color of the background circle under the arcs.
  final Color? backgroundColor;

  /// Offsets of the circle from the edges.
  final EdgeInsets padding;

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// Defaults to [Clip.hardEdge].
  final Clip clipBehavior;

  /// The size of the hole inside the circle in pixels.
  ///
  /// It's zero by default.
  final double holeSize;

  /// The spacing between arcs in a group.
  ///
  /// It's zero by default.
  final double arcSpacing;

  /// Should the start edges of the arcs be rounded off.
  final bool roundStart;

  /// Should the end edges of the arcs be rounded off.
  final bool roundEnd;

  /// The duration of the change animation.
  ///
  /// If zero, the change occurs without animation.
  final Duration animationDuration;

  /// The curve of the change animation.
  final Curve animationCurve;

  const RadialStackedBarChart({
    super.key,
    required this.data,
    this.scale,
    this.angle = 0.0,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(24),
    this.clipBehavior = Clip.hardEdge,
    this.holeSize = 0.0,
    this.arcSpacing = 0.0,
    this.roundStart = false,
    this.roundEnd = false,
    this.animationDuration = Duration.zero,
    this.animationCurve = Curves.easeOut,
  });

  @override
  State<RadialStackedBarChart<D, T>> createState()
    => _RadialStackedBarChartState<D, T>();
}


class _RadialStackedBarChartState<D, T>
  extends State<RadialStackedBarChart<D, T>>
  with SingleTickerProviderStateMixin
{
  @override
  void initState()
  {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onAnimationDone();
      }
    });
    _stacks = _stacksFromSeries(widget.data,
      roundStart: widget.roundStart,
      roundEnd: widget.roundEnd,
    );
  }

  @override
  void dispose()
  {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(final RadialStackedBarChart<D, T> oldWidget)
  {
    if (widget.animationDuration != oldWidget.animationDuration) {
      _controller.duration = widget.animationDuration;
    }
    if (widget.data != oldWidget.data
      || widget.scale != oldWidget.scale
      || widget.angle != oldWidget.angle
      || widget.roundStart != oldWidget.roundStart
      || widget.roundEnd != oldWidget.roundEnd
    ) {
      _stacks = _stacksFromSeries(widget.data,
        roundStart: widget.roundStart,
        roundEnd: widget.roundEnd,
      );
      if (widget.animationDuration > Duration.zero
        && _dataIsCompatible(widget.data, oldWidget.data)
        && (widget.scale != oldWidget.scale
          || _dataIsDifferent(widget.data, oldWidget.data)
        )
      ) {
        _controller.forward(from: 0.0);
        _currentAnimation = _controller.drive(
          CurveTween(curve: widget.animationCurve),
        );
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(final BuildContext context)
  {
    return LayoutBuilder(builder: (context, constraints) => CustomPaint(
      size: constraints.biggest,
      painter: RadialBarPainter(
        data: _stacks,
        animation: _currentAnimation,
        scale: widget.scale,
        angle: widget.angle,
        backgroundColor: widget.backgroundColor,
        arcSpacing: widget.arcSpacing,
        holeSize: widget.holeSize,
        roundStart: widget.roundStart,
        roundEnd: widget.roundEnd,
        padding: widget.padding,
        clipBehavior: widget.clipBehavior,
      ),
    ));
  }

  static BarChartStacks _stacksFromSeries<D, T>(
    final List<Series<D, T>> data, {
      final bool inverted = false,
      final bool roundStart = false,
      final bool roundEnd = false,
    }
  )
  {
    final stacks = <D, BarChartStack>{};
    for (final series in data) {
      final percents = calcPercents(series.data.values
        .map((value) => series.measureAccessor(value))
        .toList()
      );
      var index = 0;
      for (final entry in series.data.entries) {
        final domain = entry.key;
        final value = entry.value;
        final measure = series.measureAccessor(value);
        final stack = stacks.putIfAbsent(domain, () => BarChartStack(
          segments: [],
          roundStart: roundStart,
          roundEnd: roundEnd,
        ));
        final label = series.labelAccessor == null
          ? null
          : series.labelAccessor!(domain, value, percents[index]);
        stack.segments.add(BarChartSegment(
          value: measure,
          color: series.colorAccessor(domain, value),
          label: label,
        ));
        ++index;
      }
    }
    return BarChartStacks(
      stacks: stacks.values.toList(),
      maxMeasure: stacks.values
        .map((s) => s.upper)
        .reduce((value, element) => max(value, element)),
      minMeasure: stacks.values
        .map((s) => s.lower)
        .reduce((value, element) => min(value, element)),
      inverted: inverted,
    );
  }

  bool _dataIsDifferent(
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

  bool _dataIsCompatible(
    final List<Series<D, T>> data1,
    final List<Series<D, T>> data2,
  )
  {
    final d1 = data1.map((e) => e.data.keys.toList()).expand((e) => e).toSet();
    final d2 = data2.map((e) => e.data.keys.toList()).expand((e) => e).toSet();
    return setEquals(d1, d2);
  }

  void _onAnimationDone()
  {
    setState(() => _currentAnimation = null);
  }

  late BarChartStacks _stacks;
  late AnimationController _controller;

  Animation<double>? _currentAnimation;
}
