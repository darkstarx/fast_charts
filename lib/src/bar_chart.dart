import 'package:flutter/material.dart';

import 'bar_chart/stacked_data.dart';
import 'bar_chart/painter.dart';
import 'bar_chart/ticks_resolver.dart';
import 'types.dart';
import 'series.dart';


class BarChart<D, T> extends StatefulWidget
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

  /// The minimal distance between next ticks in pixels.
  final double minTickSpacing;

  final double barSpacing;
  final double barPadding;
  final EdgeInsets padding;
  final Radius radius;

  const BarChart({
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
    this.minTickSpacing = 64.0,

    this.barSpacing = 0.0,
    this.barPadding = 0.0,

    this.padding = EdgeInsets.zero,
    this.radius = Radius.zero,
  });

  @override
  State<BarChart> createState() => _BarChartState<D, T>();
}


class _BarChartState<D, T> extends State<BarChart<D, T>>
{
  @override
  void initState()
  {
    super.initState();
    ticksResolver = BarTicksResolver(minSpacing: widget.minTickSpacing);
  }

  @override
  void didUpdateWidget(covariant BarChart<D, T> oldWidget)
  {
    if (widget.minTickSpacing != oldWidget.minTickSpacing) {
      ticksResolver = BarTicksResolver(minSpacing: widget.minTickSpacing);
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
        data: _stacksFromSeries(widget.data,
          domainFormatter: widget.domainFormatter,
          valueAxis: widget.valueAxis,
          inverted: widget.inverted,
          radius: widget.radius,
        ),
        ticksResolver: ticksResolver,
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
        barPadding: widget.barPadding,
        barSpacing: widget.barSpacing,
        padding: widget.padding,
      ),
    ));
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
    if (radius != Radius.zero) {
      for (final stack in stacks.values) {
        final divided = stack.dividedSegments;
        for (var i = 0; i < divided.lower.length; ++i) {
          final (index, segment) = divided.lower[i];
          final isFirst = inverted ? i == divided.lower.length - 1 : i == 0;
          final isLast = inverted ? i == 0 : i == divided.lower.length - 1;
          final BorderRadius borderRadius;
          switch (valueAxis) {
            case Axis.horizontal:
              borderRadius = BorderRadius.only(
                topLeft: isLast && !inverted ? radius : Radius.zero,
                bottomLeft: isLast && !inverted ? radius : Radius.zero,
                topRight: isFirst && inverted ? radius : Radius.zero,
                bottomRight: isFirst && inverted ? radius : Radius.zero,
              );
              break;
            case Axis.vertical:
              borderRadius = BorderRadius.only(
                topLeft: isFirst && inverted ? radius : Radius.zero,
                topRight: isFirst && inverted ? radius : Radius.zero,
                bottomLeft: isLast && !inverted ? radius : Radius.zero,
                bottomRight: isLast && !inverted ? radius : Radius.zero,
              );
              break;
          }
          stack.segments[index] = segment.copyWith(borderRadius: borderRadius);
        }
        for (var i = 0; i < divided.upper.length; ++i) {
          final (index, segment) = divided.upper[i];
          final isFirst = inverted ? i == divided.upper.length - 1 : i == 0;
          final isLast = inverted ? i == 0 : i == divided.upper.length - 1;
          final BorderRadius borderRadius;
          switch (valueAxis) {
            case Axis.horizontal:
              borderRadius = BorderRadius.only(
                topLeft: isFirst && inverted ? radius : Radius.zero,
                bottomLeft: isFirst && inverted ? radius : Radius.zero,
                topRight: isLast && !inverted ? radius : Radius.zero,
                bottomRight: isLast && !inverted ? radius : Radius.zero,
              );
              break;
            case Axis.vertical:
              borderRadius = BorderRadius.only(
                topLeft: isLast && !inverted ? radius : Radius.zero,
                topRight: isLast && !inverted ? radius : Radius.zero,
                bottomLeft: isFirst && inverted ? radius : Radius.zero,
                bottomRight: isFirst && inverted ? radius : Radius.zero,
              );
              break;
          }
          stack.segments[index] = segment.copyWith(borderRadius: borderRadius);
        }
      }
    }
    return BarChartStacks(
      stacks: stacks.values.toList(),
      valueAxis: valueAxis,
      inverted: inverted,
    );
  }

  late BarTicksResolver ticksResolver;
}
