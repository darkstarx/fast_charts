import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'bar_chart/bar_data.dart';
import 'bar_chart/painter.dart';
import 'bar_chart/ticks_resolver.dart';
import 'types.dart';
import 'series.dart';


/// Shows several series of data as groups of bars.
///
/// All series must contain data of the same type. It is not necessary for each
/// series to contain the same set of domains, if there is no value for some of
/// domains in some series, the series may not contain the value of this domain.
class BarChart<D, T> extends StatefulWidget
{
  /// The list of series to be shown.
  final List<Series<D, T>> data;

  /// Converts domain value to [String] type to be shown on the domains axis.
  final DomainFormatter<D>? domainFormatter;

  /// Converts measure value of type [double] to [String] type to be shown on
  /// the measure axis.
  final MeasureFormatter? measureFormatter;

  /// The orientation of the diagram.
  ///
  /// When [valueAxis] is [Axis.vertical] (by default), the diagram shows bars
  /// vertically, otherwise - horizontally.
  final Axis valueAxis;

  /// Whether to show zero bars.
  ///
  /// When the measure value is zero, the diagram doesn't show corresponding
  /// bar. If the bar isn't shown, it's label is hidden as well.
  ///
  /// It can be useful to show zero bars when it's necessary to show
  /// corresponding labels, e.g. when labels show something essential besides
  /// zeroes.
  ///
  /// It's `false` by default.
  final bool showZeroValues;

  /// Whether the diagram is shown inverted.
  ///
  /// The vertical diagram is shown upside down if it's inverted. The horisontal
  /// diagram is shown right to left if it's inverted.
  ///
  /// It's 'false' by default.
  final bool inverted;

  /// The text style of labels on the domains axis.
  final TextStyle? mainAxisTextStyle;

  /// The text style of labels on the measure axis.
  final TextStyle? crossAxisTextStyle;

  /// The color of lines of axes (main and cross).
  final Color? axisColor;

  /// The thickness of lines of axes (main and cross).
  ///
  /// It's `1.0` by default.
  final double axisThickness;

  /// The color of guide lines (minor lines on the diagram).
  final Color? guideLinesColor;

  /// The thickness of guide lines (minor lines on the diagram).
  ///
  /// It's `1.0` by default.
  final double guideLinesThickness;

  /// The offset of labels on the main axis from the line.
  ///
  /// It's `2.0` by default.
  final double mainAxisLabelsOffset;

  /// The offset of labels on the cross axis from the line.
  ///
  /// It's `2.0` by default.
  final double crossAxisLabelsOffset;

  /// The width of the field of measure scale, including labels on it and the
  /// [mainAxisLabelsOffset].
  final double? mainAxisWidth;

  /// The width of the field of domains scale, including labels on it and the
  /// [crossAxisLabelsOffset].
  final double? crossAxisWidth;

  /// Whether to show the line of the main axis (on the measure scale).
  ///
  /// It's `false` by default.
  final bool showMainAxisLine;

  /// Whether to show the line of the cross axis (on domains scale).
  ///
  /// It's `true` by default.
  final bool showCrossAxisLine;

  /// The minimal distance between next ticks in pixels.
  ///
  /// It's `64.0` by default.
  final double minTickSpacing;

  /// The spacing between groups of bars.
  ///
  /// It's zero by default.
  final double groupSpacing;

  /// The spacing between bars in a group.
  ///
  /// It's zero by default.
  final double barSpacing;

  /// The padding of bars.
  ///
  /// It is the space between the starting edge and the first bar, or between
  /// the ending edge and the last bar.
  ///
  /// It's zero by default.
  final double barPadding;

  /// The padding of the diagram.
  ///
  /// It's zero by default.
  final EdgeInsets padding;

  /// The radius of each bar.
  ///
  /// If zero, the corners of the bars are rectangular and the performance is
  /// much better.
  final Radius radius;

  /// The duration of the change animation.
  ///
  /// If zero, the change occurs without animation.
  final Duration animationDuration;

  const BarChart({
    super.key,
    required this.data,
    this.domainFormatter,
    this.measureFormatter,
    this.valueAxis = Axis.vertical,
    this.showZeroValues = false,
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

    this.groupSpacing = 0.0,
    this.barSpacing = 0.0,
    this.barPadding = 0.0,

    this.padding = EdgeInsets.zero,
    this.radius = Radius.zero,
    this.animationDuration = Duration.zero,
  });

  @override
  State<BarChart> createState() => _BarChartState<D, T>();
}


class _BarChartState<D, T> extends State<BarChart<D, T>>
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
    _groups = _barsFromSeries(widget.data,
      domainFormatter: widget.domainFormatter,
      valueAxis: widget.valueAxis,
      showZeroValues: widget.showZeroValues,
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
  void didUpdateWidget(covariant BarChart<D, T> oldWidget)
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
      || widget.showZeroValues != oldWidget.showZeroValues
      || widget.inverted != oldWidget.inverted
      || widget.radius != oldWidget.radius
    ) {
      _groups = _barsFromSeries(widget.data,
        domainFormatter: widget.domainFormatter,
        valueAxis: widget.valueAxis,
        showZeroValues: widget.showZeroValues,
        inverted: widget.inverted,
        radius: widget.radius,
      );
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
        data: _groups,
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
        groupSpacing: widget.groupSpacing,
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

  static ChartBars _barsFromSeries<D, T>(
    final List<Series<D, T>> data, {
      final DomainFormatter<D>? domainFormatter,
      required final Axis valueAxis,
      required final bool showZeroValues,
      required final bool inverted,
      required final Radius radius,
    }
  )
  {
    final groups = <D, BarsGroup>{};
    for (final series in data) {
      for (final entry in series.data.entries) {
        final measure = series.measureAccessor(entry.value);
        final domain = entry.key;
        final domainLabel = domainFormatter == null
          ? domain.toString()
          : domainFormatter(domain);
        final group = groups.putIfAbsent(domain, () => BarsGroup(
          domain: domainLabel,
          bars: [],
        ));
        if (!showZeroValues && measure == 0.0) continue;
        final label = series.labelAccessor == null
          ? null
          : series.labelAccessor!(entry.value);
        group.bars.add(Bar(
          value: measure,
          color: series.color,
          radius: radius,
          label: label,
        ));
      }
    }
    groups.removeWhere((key, value) => value.bars.isEmpty);
    return ChartBars(
      groups: groups.values.toList(),
      valueAxis: valueAxis,
      inverted: inverted,
    );
  }

  late BarTicksResolver _ticksResolver;
  late ChartBars _groups;
  late AnimationController _controller;
}
