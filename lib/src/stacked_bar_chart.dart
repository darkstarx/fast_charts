import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'stacked_bar_chart/stacked_data.dart';
import 'stacked_bar_chart/painter.dart';
import 'stacked_bar_chart/ticks_resolver.dart';
import 'types.dart';
import 'series.dart';


class StackedBarChart<D, T> extends StatefulWidget
{
  final List<Series<D, T>> data;
  final DomainFormatter<D>? domainFormatter;
  final MeasureFormatter? measureFormatter;
  final Axis valueAxis;
  final bool inverted;

  final TextStyle? mainAxisTextStyle;
  final TextStyle? crossAxisTextStyle;
  final Color? axisColor;
  final double axisThickness;
  final Color? guideLinesColor;
  final double guideLinesThickness;
  final double mainAxisLabelsOffset;
  final double crossAxisLabelsOffset;
  final double? mainAxisWidth;
  final double? crossAxisWidth;
  final bool showMainAxisLine;
  final bool showCrossAxisLine;

  /// The minimal distance between next ticks in pixels.
  final double minTickSpacing;

  final double barSpacing;
  final double barPadding;
  final EdgeInsets padding;
  final Radius radius;
  final Duration animationDuration;

  const StackedBarChart({
    super.key,
    required this.data,
    this.domainFormatter,
    this.measureFormatter,
    this.valueAxis = Axis.vertical,
    this.inverted = false,

    this.mainAxisTextStyle,
    this.crossAxisTextStyle,
    this.axisColor,
    this.axisThickness = 1.0,
    this.guideLinesColor,
    this.guideLinesThickness = 1.0,
    this.mainAxisLabelsOffset = 2.0,
    this.crossAxisLabelsOffset = 2.0,
    this.mainAxisWidth,
    this.crossAxisWidth,
    this.showMainAxisLine = false,
    this.showCrossAxisLine = true,
    this.minTickSpacing = 64.0,

    this.barSpacing = 0.0,
    this.barPadding = 0.0,

    this.padding = EdgeInsets.zero,
    this.radius = Radius.zero,
    this.animationDuration = Duration.zero,
  });

  @override
  State<StackedBarChart> createState() => _StackedBarChartState<D, T>();
}


class _StackedBarChartState<D, T> extends State<StackedBarChart<D, T>>
  with SingleTickerProviderStateMixin
{
  @override
  void initState()
  {
    super.initState();
    _ticksResolver = BarTicksResolver(minSpacing: widget.minTickSpacing);
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
      domainFormatter: widget.domainFormatter,
      valueAxis: widget.valueAxis,
      inverted: widget.inverted,
      radius: widget.radius,
    );
  }

  @override
  void dispose()
  {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant StackedBarChart<D, T> oldWidget)
  {
    if (widget.minTickSpacing != oldWidget.minTickSpacing) {
      _ticksResolver = BarTicksResolver(minSpacing: widget.minTickSpacing);
    }
    if (widget.animationDuration != oldWidget.animationDuration) {
      _controller.duration = widget.animationDuration;
    }
    if (widget.data != oldWidget.data
      || widget.domainFormatter != oldWidget.domainFormatter
      || widget.valueAxis != oldWidget.valueAxis
      || widget.inverted != oldWidget.inverted
      || widget.radius != oldWidget.radius
    ) {
      final newStacks = _stacksFromSeries(widget.data,
        domainFormatter: widget.domainFormatter,
        valueAxis: widget.valueAxis,
        inverted: widget.inverted,
        radius: widget.radius,
      );
      _stacks = newStacks;
      if (widget.data != oldWidget.data
        && widget.animationDuration > Duration.zero
      ) {
        final compatible = _checkSeriesCompatibility(oldWidget.data, widget.data);
        if (compatible) {
          _controller.forward(from: 0.0);
        }
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(final BuildContext context)
  {
    final theme = Theme.of(context);
    return LayoutBuilder(builder: (context, constraints) => CustomPaint(
      size: constraints.biggest,
      painter: BarPainter(
        data: _stacks,
        animation: _controller.isAnimating ? _controller : null,
        ticksResolver: _ticksResolver,
        measureFormatter: widget.measureFormatter,
        mainAxisTextStyle: widget.mainAxisTextStyle ?? TextStyle(
          fontSize: 12.0,
          color: theme.colorScheme.onSurface,
        ),
        crossAxisTextStyle: widget.crossAxisTextStyle ?? TextStyle(
          fontSize: 12.0,
          color: theme.colorScheme.onSurface,
        ),
        axisColor: widget.axisColor ?? theme.colorScheme.onSurface,
        axisThickness: widget.axisThickness,
        guideLinesColor: widget.guideLinesColor
          ?? theme.colorScheme.onSurface.withOpacity(0.1),
        guideLinesThickness: widget.guideLinesThickness,
        mainAxisLabelsOffset: widget.mainAxisLabelsOffset,
        crossAxisLabelsOffset: widget.crossAxisLabelsOffset,
        mainAxisWidth: widget.mainAxisWidth,
        crossAxisWidth: widget.crossAxisWidth,
        showMainAxisLine: widget.showMainAxisLine,
        showCrossAxisLine: widget.showCrossAxisLine,
        barPadding: widget.barPadding,
        barSpacing: widget.barSpacing,
        padding: widget.padding,
      ),
    ));
  }

  bool _checkSeriesCompatibility(
    final List<Series<D, T>> set1,
    final List<Series<D, T>> set2,
  )
  {
    final d1 = set1.map((e) => e.data.keys.toList()).expand((e) => e).toSet();
    final d2 = set2.map((e) => e.data.keys.toList()).expand((e) => e).toSet();
    if (!setEquals(d1, d2)) return false;
    return true;
  }

  void _onAnimationDone()
  {
    setState(() {});
  }

  static BarChartStacks _stacksFromSeries<D, T>(
    final List<Series<D, T>> data, {
      final DomainFormatter<D>? domainFormatter,
      required final Axis valueAxis,
      required final bool inverted,
      required final Radius radius,
    }
  )
  {
    final stacks = <D, BarChartStack>{};
    for (final series in data) {
      for (final entry in series.data.entries) {
        final measure = series.measureAccessor(entry.value);
        final domain = entry.key;
        final domainLabel = domainFormatter == null
          ? domain.toString()
          : domainFormatter(domain);
        final stack = stacks.putIfAbsent(domain, () => BarChartStack(
          domain: domainLabel,
          segments: [],
          radius: radius,
        ));
        final label = series.labelAccessor == null
          ? null
          : series.labelAccessor!(entry.value);
        stack.segments.add(BarChartSegment(
          value: measure,
          color: series.color,
          label: label,
        ));
      }
    }
    return BarChartStacks(
      stacks: stacks.values.toList(),
      valueAxis: valueAxis,
      inverted: inverted,
    );
  }

  late BarTicksResolver _ticksResolver;
  late BarChartStacks _stacks;
  late AnimationController _controller;
}
