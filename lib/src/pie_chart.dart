import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'pie_chart/painter.dart';
import 'pie_chart/pie_data.dart';
import 'series.dart';
import 'strokes_config.dart';
import 'utils.dart';


/// Shows a single series of data in the form of pie chart sectors.
class PieChart<D, T> extends StatefulWidget
{
  /// The series of data to be shown.
  final Series<D, T> data;

  /// The angle of pie rotation.
  final double angle;

  /// The offset of outside labels from the edge of the pie.
  final double labelsOffset;

  /// Whether to show zero sectors.
  ///
  /// When the measure value is zero, the diagram doesn't show corresponding
  /// sector. If the sector isn't shown, it's label is hidden as well.
  ///
  /// It can be useful to show zero sectors when it's necessary to show
  /// corresponding labels, e.g. when labels show something essential besides
  /// zeroes.
  ///
  /// It's `false` by default.
  final bool showZeroValues;

  /// Pie offsets from the edges.
  final EdgeInsets padding;

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// Defaults to [Clip.hardEdge].
  final Clip clipBehavior;

  /// The strokes config.
  final StrokesConfig? strokes;

  /// The duration of the change animation.
  ///
  /// If zero, the change occurs without animation.
  final Duration animationDuration;

  /// The curve of the change animation.
  final Curve animationCurve;

  const PieChart({
    super.key,
    required this.data,
    this.angle = 0.0,
    this.labelsOffset = 4.0,
    this.showZeroValues = false,
    this.padding = const EdgeInsets.all(24),
    this.clipBehavior = Clip.hardEdge,
    this.strokes,
    this.animationDuration = Duration.zero,
    this.animationCurve = Curves.easeOut,
  });

  @override
  State<PieChart<D, T>> createState() => _PieChartState<D, T>();
}

class _PieChartState<D, T> extends State<PieChart<D, T>>
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
    _pie = _pieFromSeries(widget.data,
      showZeroValues: widget.showZeroValues,
    );
  }

  @override
  void dispose()
  {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(final PieChart<D, T> oldWidget)
  {
    if (widget.animationDuration != oldWidget.animationDuration) {
      _controller.duration = widget.animationDuration;
    }
    if (widget.data != oldWidget.data
      || widget.angle != oldWidget.angle
      || widget.showZeroValues != oldWidget.showZeroValues
    ) {
      _pie = _pieFromSeries(widget.data,
        showZeroValues: widget.showZeroValues,
      );
      if (widget.animationDuration > Duration.zero
        && !mapEquals(widget.data.data, oldWidget.data.data)
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
      painter: PiePainter(
        data: _pie,
        animation: _currentAnimation,
        angle: widget.angle,
        labelsOffset: widget.labelsOffset,
        padding: widget.padding,
        clipBehavior: widget.clipBehavior,
        strokes: widget.strokes,
      ),
    ));
  }

  static Pie<D> _pieFromSeries<D, T>(final Series<D, T> series, {
    required final bool showZeroValues,
  })
  {
    final sectors = <Sector<D>>[];
    final percents = calcPercents(series.data.values
      .map((e) => series.measureAccessor(e))
      .toList()
    );
    var index = 0;
    for (final entry in series.data.entries) {
      final domain = entry.key;
      final value = entry.value;
      final percent = percents[index];
      if (percent != 0.0 || showZeroValues) {
        final label = series.labelAccessor == null
          ? null
          : series.labelAccessor!(domain, value, percent);
        sectors.add(Sector(
          domain: domain,
          value: percent,
          color: series.colorAccessor(domain, value),
          label: label,
        ));
      }
      ++index;
    }
    return Pie(sectors: sectors);
  }

  void _onAnimationDone()
  {
    setState(() => _currentAnimation = null);
  }

  late Pie<D> _pie;
  late AnimationController _controller;

  Animation<double>? _currentAnimation;
}
