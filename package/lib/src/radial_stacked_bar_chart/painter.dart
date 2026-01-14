import 'dart:collection';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'scale.dart';
import 'stacked_data.dart';


class RadialBarPainter extends CustomPainter
{
  final BarChartStacks data;
  final ValueListenable<double>? animation;
  final RadialScale? scale;
  final double angle;
  final Color? backgroundColor;
  final double arcSpacing;
  final double holeSize;
  final bool roundStart;
  final bool roundEnd;
  final EdgeInsets padding;
  final Clip clipBehavior;

  RadialBarPainter({
    required this.data,
    this.scale,
    this.animation,
    this.angle = 0.0,
    this.backgroundColor,
    this.arcSpacing = 0.0,
    this.holeSize = 0.0,
    this.roundStart = false,
    this.roundEnd = false,
    this.padding = EdgeInsets.zero,
    this.clipBehavior = Clip.hardEdge,
  })
  : super(repaint: animation);

  @override
  void paint(final Canvas canvas, final Size size)
  {
    if (_lastSize != size) {
      _lastSize = size;
      _layoutData?.dispose();
      _layoutData = null;
    }
    final layoutData = _layoutData ??= _buildLayout(size);

    switch (clipBehavior) {
      case Clip.none:
        break;
      case Clip.hardEdge:
        canvas.clipRect(layoutData.clipRect, doAntiAlias: false);
      case Clip.antiAlias:
        canvas.clipRect(layoutData.clipRect, doAntiAlias: true);
      case Clip.antiAliasWithSaveLayer:
        canvas.clipRect(layoutData.clipRect, doAntiAlias: true);
        canvas.saveLayer(layoutData.clipRect, Paint());
    }

    if (backgroundColor != null) {
      canvas.drawPath(layoutData.backgroundPath, Paint()
        ..style = PaintingStyle.fill
        ..color = backgroundColor!
      );
    }
    final stacks = _stacks = _getStacks(layoutData);
    for (final stack in stacks.values) {
      final clip = stack.clip;
      if (clip != null) {
        canvas.save();
        canvas.clipPath(clip.path);
      }
      for (final segment in stack.segments.values) {
        final path = segment.path;
        if (path == null) continue;
        canvas.drawPath(path, segment.paint);
      }
      if (clip != null) {
        canvas.restore();
      }
    }

    if (animation == null) {
      for (final label in layoutData.labels) {
        final (offset, paragraph) = label;
        canvas.drawParagraph(paragraph, offset);
      }
    }
    switch (clipBehavior) {
      case Clip.none:
      case Clip.hardEdge:
      case Clip.antiAlias:
        break;
      case Clip.antiAliasWithSaveLayer:
        canvas.restore();
    }
  }

  @override
  bool shouldRepaint(final RadialBarPainter oldDelegate)
  {
    _layoutData = oldDelegate._layoutData;
    _lastSize = oldDelegate._lastSize;
    _stacks = oldDelegate._stacks;
    _oldStacks = oldDelegate._oldStacks;
    final needRebuild = data != oldDelegate.data
      || scale != oldDelegate.scale
      || arcSpacing != oldDelegate.arcSpacing
      || holeSize != oldDelegate.holeSize
      || roundStart != oldDelegate.roundStart
      || roundEnd != oldDelegate.roundEnd
      || padding != oldDelegate.padding
    ;
    if (needRebuild) {
      _oldStacks = oldDelegate._stacks;
      _layoutData?.dispose();
      _layoutData = null;
    }
    return needRebuild
      || backgroundColor != oldDelegate.backgroundColor
      || clipBehavior != oldDelegate.clipBehavior;
  }

  @override
  bool shouldRebuildSemantics(final RadialBarPainter oldDelegate)
  {
    return false;
  }

  void dispose()
  {
    _layoutData?.dispose();
    _layoutData = null;
  }

  Map<int, _LayoutStack> _getStacks(final _LayoutData layoutData)
  {
    if (animation == null) {
      return layoutData.stacks;
    } else {
      final result = <int, _LayoutStack>{};
      for (final entry in layoutData.stacks.entries) {
        final stackId = entry.key;
        final newStack = entry.value;
        final newSegments = newStack.segments;
        final oldStack = _oldStacks?[stackId];
        final oldSegments = oldStack?.segments ?? {};
        final layoutStack = result.putIfAbsent(stackId,
          () => _LayoutStack.empty(newStack.rect),
        );
        for (final entry in newSegments.entries) {
          final segmentId = entry.key;
          final segment = entry.value;
          var oldSegment = oldSegments[segmentId];
          final double oldStartAngle;
          final double oldSweepAngle;
          final Color oldColor;
          if (oldSegment == null) {
            final lastSegment = layoutStack.segments.isEmpty
              ? null
              : layoutStack.segments.values.last;
            oldStartAngle = lastSegment == null
              ? angle
              : lastSegment.startAngle + lastSegment.sweepAngle;
            oldSweepAngle = 0.0;
            oldColor = segment.paint.color;
          } else {
            oldStartAngle = oldSegment.startAngle;
            oldSweepAngle = oldSegment.sweepAngle;
            oldColor = oldSegment.paint.color;
          }
          final newStartAngle = segment.startAngle;
          final newSweepAngle = segment.sweepAngle;
          final newColor = segment.paint.color;
          layoutStack.segments[segmentId] = _Segment.build(
            outerRect: newStack.rect,
            startAngle: ui.lerpDouble(oldStartAngle, newStartAngle,
              animation!.value
            )!,
            sweepAngle: ui.lerpDouble(oldSweepAngle, newSweepAngle,
              animation!.value
            )!,
            thickness: layoutData.stackThickness,
            color: Color.lerp(oldColor, newColor, animation!.value)!,
          );
        }
        for (final entry in oldSegments.entries.where(
          (e) => !newSegments.containsKey(e.key)
        )) {
          final segmentId = entry.key;
          final oldSegment = entry.value;
          final oldStartAngle = oldSegment.startAngle;
          final oldSweepAngle = oldSegment.sweepAngle;
          final oldColor = oldSegment.paint.color;
          layoutStack.segments[segmentId] = _Segment.build(
            outerRect: newStack.rect,
            startAngle: ui.lerpDouble(oldStartAngle, angle, animation!.value)!,
            sweepAngle: ui.lerpDouble(oldSweepAngle, 0.0, animation!.value)!,
            thickness: layoutData.stackThickness,
            color: oldColor,
          );
        }
        _LayoutStackClip? clip;
        if (roundStart || roundEnd) {
          final newClip = newStack.clip;
          final oldClip = oldStack?.clip;
          if (oldClip == null) {
            clip = newClip;
          } else if (newClip != null) {
            Path? clipPath;
            final startAngle = ui.lerpDouble(
              oldClip.startAngle,
              newClip.startAngle,
              animation!.value,
            )!;
            final oldLowerSweepAngle = oldClip.lowerSweepAngle;
            final oldUpperSweepAngle = oldClip.upperSweepAngle;
            final newLowerSweepAngle = newClip.lowerSweepAngle;
            final newUpperSweepAngle = newClip.upperSweepAngle;
            double? lowerSweepAngle;
            if (newLowerSweepAngle != null) {
              lowerSweepAngle = ui.lerpDouble(
                oldLowerSweepAngle ?? newLowerSweepAngle,
                newLowerSweepAngle,
                animation!.value,
              )!;
              final segment = _Segment.build(
                outerRect: newStack.rect,
                startAngle: startAngle,
                sweepAngle: lowerSweepAngle,
                thickness: layoutData.stackThickness,
                forceContour: true,
                roundStart: roundStart,
                roundEnd: roundEnd,
              );
              final path = segment.path;
              if (path != null) {
                clipPath = path;
              }
            }
            double? upperSweepAngle;
            if (newUpperSweepAngle != null) {
              upperSweepAngle = ui.lerpDouble(
                oldUpperSweepAngle ?? newUpperSweepAngle,
                newUpperSweepAngle,
                animation!.value,
              )!;
              final segment = _Segment.build(
                outerRect: newStack.rect,
                startAngle: startAngle,
                sweepAngle: upperSweepAngle,
                thickness: layoutData.stackThickness,
                forceContour: true,
                roundStart: roundStart,
                roundEnd: roundEnd,
              );
              final path = segment.path;
              if (path != null) {
                if (clipPath == null) {
                  clipPath = path;
                } else {
                  clipPath.addPath(path, Offset.zero);
                }
              }
            }
            if (clipPath != null) {
              clip = _LayoutStackClip(
                startAngle: startAngle,
                lowerSweepAngle: lowerSweepAngle,
                upperSweepAngle: upperSweepAngle,
                path: clipPath,
              );
            }
          }
        }
        result[stackId] = _LayoutStack(
          rect: newStack.rect,
          segments: layoutStack.segments,
          clip: clip,
        );
      }
      return result;
    }
  }

  _LayoutData _buildLayout(final Size size)
  {
    assert(data.stacks.isNotEmpty);
    final outerRect = Offset.zero & size;
    final innerRect = padding.deflateRect(outerRect);
    final diameter = innerRect.shortestSide;
    final backgroundRect = Rect.fromCenter(
      center: innerRect.center,
      width: diameter,
      height: diameter,
    );
    final Path backgroundPath;
    if (holeSize > 0.0) {
      final holeRect = Rect.fromCenter(
        center: innerRect.center,
        width: holeSize,
        height: holeSize,
      );
      backgroundPath = Path.combine(
        PathOperation.difference,
        Path()..addOval(backgroundRect),
        Path()..addOval(holeRect),
      );
    } else {
      backgroundPath = Path()..addOval(backgroundRect);
    }
    final space = max(0.0,
      (diameter - holeSize) / 2 - arcSpacing * (data.stacks.length - 1),
    );
    final thickness = space / data.stacks.length;
    final layoutData = _LayoutData.empty(outerRect,
      stackThickness: thickness,
      backgroundPath: backgroundPath,
    );

    ({ double lower, double upper}) maximum;
    if (scale == null) {
      maximum = data.stacks
        .map((stack) => stack.summs)
        .reduce((value, summs) => (
          lower: min(value.lower, summs.lower),
          upper: max(value.upper, summs.upper),
        ));
    } else {
      maximum = (lower: min(scale!.min, 0.0), upper: max(scale!.max, 0.0));
    }
    final summ = maximum.upper - maximum.lower;
    if (summ == 0.0) {
      return layoutData;
    }
    var rect = Rect.fromCenter(
      center: innerRect.center,
      width: diameter,
      height: diameter,
    );
    final stackSectors = <
      int,
      ({ Rect rect, double lower, double upper })
    >{};
    for (var i = 0; i < data.stacks.length; ++i) {
      final layoutStack = layoutData.stacks.putIfAbsent(i,
        () => _LayoutStack.empty(rect)
      );
      final stack = data.stacks[i];
      final divided = stack.dividedSegments;
      // Lower segments.
      var stackValue = 0.0;
      var startAngle = angle;
      for (final entry in divided.lower) {
        final (index, segment) = entry;
        stackValue += segment.value;
        final remaind = maximum.lower - stackValue;
        final value = min(segment.value + max(remaind, 0.0), 0.0);
        final sweepAngle = value * 2 * pi / summ;
        layoutStack.segments[index] = _Segment.build(
          outerRect: rect,
          startAngle: startAngle,
          sweepAngle: sweepAngle,
          color: segment.color,
          thickness: thickness,
        );
        startAngle += sweepAngle;
      }
      var stackSector = stackSectors[i];
      if (stackSector == null) {
        stackSector = (rect: rect, lower: startAngle, upper: angle);
      } else {
        stackSector = (
          rect: stackSector.rect,
          lower: min(stackSector.lower, startAngle),
          upper: stackSector.upper,
        );
      }
      stackSectors[i] = stackSector;
      // Upper segments.
      stackValue = 0.0;
      startAngle = angle;
      for (final entry in divided.upper) {
        final (index, segment) = entry;
        stackValue += segment.value;
        final remaind = maximum.upper - stackValue;
        final value = max(segment.value + min(remaind, 0.0), 0.0);
        final sweepAngle = value * 2 * pi / summ;
        layoutStack.segments[index] = _Segment.build(
          outerRect: rect,
          startAngle: startAngle,
          sweepAngle: sweepAngle,
          color: segment.color,
          thickness: thickness,
        );
        startAngle += sweepAngle;
      }
      stackSectors[i] = (
        rect: stackSector.rect,
        lower: stackSector.lower,
        upper: max(stackSector.upper, startAngle),
      );
      rect = rect.deflate(thickness + arcSpacing);
    }
    if (roundStart || roundEnd) {
      for (final entry in layoutData.stacks.entries.toList()) {
        final stackIndex = entry.key;
        final stack = entry.value;
        if (stack.segments.isEmpty) continue;
        final stackSector = stackSectors[stackIndex];
        if (stackSector == null) continue;
        double? lowerSweepAngle;
        double? upperSweepAngle;
        Path? path;
        if (stackSector.lower < angle) {
          lowerSweepAngle = stackSector.lower - angle;
          final lowerSegment = _Segment.build(
            outerRect: stackSector.rect,
            startAngle: angle,
            sweepAngle: lowerSweepAngle,
            thickness: thickness,
            forceContour: true,
            roundStart: roundStart,
            roundEnd: roundEnd,
          );
          final lowerPath = lowerSegment.path;
          if (lowerPath != null) {
            path = lowerPath;
          }
        }
        if (stackSector.upper > angle) {
          upperSweepAngle = stackSector.upper - angle;
          final upperSegment = _Segment.build(
            outerRect: stackSector.rect,
            startAngle: angle,
            sweepAngle: upperSweepAngle,
            thickness: thickness,
            forceContour: true,
            roundStart: roundStart,
            roundEnd: roundEnd,
          );
          final upperPath = upperSegment.path;
          if (upperPath != null) {
            if (path == null) {
              path = upperPath;
            } else {
              path.addPath(upperPath, Offset.zero);
            }
          }
        }
        if (path != null) {
          layoutData.stacks[stackIndex] = _LayoutStack(
            rect: stackSector.rect,
            segments: stack.segments,
            clip: _LayoutStackClip(
              startAngle: angle,
              lowerSweepAngle: lowerSweepAngle,
              upperSweepAngle: upperSweepAngle,
              path: path,
            ),
          );
        }
      }
    }
    return layoutData;
  }

  _LayoutData? _layoutData;
  Size? _lastSize;
  Map<int, _LayoutStack>? _stacks;
  Map<int, _LayoutStack>? _oldStacks;
}


class _LayoutData
{
  final Rect clipRect;
  final Path backgroundPath;
  final double stackThickness;
  final Map<int, _LayoutStack> stacks;
  final List<(Offset, ui.Paragraph)> labels;

  const _LayoutData({
    required this.clipRect,
    required this.backgroundPath,
    required this.stackThickness,
    required this.stacks,
    required this.labels,
  });

  factory _LayoutData.empty(final Rect clipRect, {
    required final double stackThickness,
    required final Path backgroundPath,
  }) => _LayoutData(
    clipRect: clipRect,
    backgroundPath: backgroundPath,
    stackThickness: stackThickness,
    stacks: {},
    labels: [],
  );

  void dispose()
  {
    for (final label in labels) {
      final (_, paragraph) = label;
      paragraph.dispose();
    }
  }
}


class _LayoutStack
{
  final Rect rect;
  final Map<int, _Segment> segments;
  final _LayoutStackClip? clip;

  const _LayoutStack({
    required this.rect,
    required this.segments,
    this.clip,
  });

  factory _LayoutStack.empty(final Rect rect) => _LayoutStack(
    rect: rect,
    segments: SplayTreeMap(),
  );
}


class _LayoutStackClip
{
  final double startAngle;
  final double? lowerSweepAngle;
  final double? upperSweepAngle;
  final Path path;

  const _LayoutStackClip({
    required this.startAngle,
    required this.lowerSweepAngle,
    required this.upperSweepAngle,
    required this.path,
  });
}


class _Segment
{
  final double startAngle;
  final double sweepAngle;
  final Path? path;
  final Paint paint;

  const _Segment({
    required this.startAngle,
    required this.sweepAngle,
    required this.path,
    required this.paint,
  });

  factory _Segment.build({
    required final Rect outerRect,
    required double startAngle,
    required double sweepAngle,
    required final double thickness,
    final Color color = const Color(0x00000000),
    final bool forceContour = false,
    bool roundStart = false,
    bool roundEnd = false,
  })
  {
    final paint = Paint()..color = color;
    _Segment makeSegment(final Path? path, final Paint paint) => _Segment(
        startAngle: startAngle,
        sweepAngle: sweepAngle,
        path: path,
        paint: paint,
    );
    if (sweepAngle == 0.0) {
      return makeSegment(null, paint);
    }
    if (sweepAngle < 0.0) {
      startAngle = startAngle + sweepAngle;
      sweepAngle = -sweepAngle;
      (roundStart, roundEnd) = (roundEnd, roundStart);
    }
    final capRadius = thickness / 2;
    final centralRect = outerRect.deflate(capRadius);
    final centralRadius = centralRect.width / 2;
    final angularSize = asin(thickness / 4 / centralRadius) * 2;
    final realStartAngle = roundStart ? startAngle + angularSize : startAngle;
    final realSweepAngle = sweepAngle
      - (roundStart ? angularSize : 0.0)
      - (roundEnd ? angularSize : 0.0);
    if (!roundStart && !roundEnd && !forceContour) {
      return makeSegment(
        Path()..addArc(centralRect, realStartAngle, realSweepAngle),
        paint
          ..style = PaintingStyle.stroke
          ..strokeWidth = thickness
          ..strokeCap = StrokeCap.butt
      );
    }
    if (realSweepAngle > 0.0) {
      if (roundStart && roundEnd && !forceContour) {
        return makeSegment(
          Path()..addArc(centralRect, realStartAngle, realSweepAngle),
          paint
            ..style = PaintingStyle.stroke
            ..strokeWidth = thickness
            ..strokeCap = StrokeCap.round
        );
      }
      final center = outerRect.center;
      final realEndAngle = realStartAngle + realSweepAngle;
      final innerRect = outerRect.deflate(thickness);
      final outerRadius = outerRect.width / 2;
      final innerRadius = innerRect.width / 2;
      final path = Path();
      path.addArc(outerRect, realStartAngle, realSweepAngle);
      if (roundEnd) {
        final capRect = Rect.fromCenter(
          center: center + Offset(
            centralRadius * cos(realEndAngle),
            centralRadius * sin(realEndAngle),
          ),
          width: thickness,
          height: thickness,
        );
        path.arcTo(capRect, realEndAngle, pi, false);
      } else {
        path.lineTo(
          center.dx + innerRadius * cos(realEndAngle),
          center.dy + innerRadius * sin(realEndAngle),
        );
      }
      path.arcTo(innerRect, realEndAngle, -realSweepAngle, false);
      if (roundStart) {
        final capRect = Rect.fromCenter(
          center: center + Offset(
            centralRadius * cos(realStartAngle),
            centralRadius * sin(realStartAngle),
          ),
          width: thickness,
          height: thickness,
        );
        path.arcTo(capRect, realStartAngle, -pi, false);
      } else {
        path.lineTo(
          center.dx + outerRadius * cos(realStartAngle),
          center.dy + outerRadius * sin(realStartAngle),
        );
      }
      return makeSegment(path, paint..style = PaintingStyle.fill);
    }
    paint.style = PaintingStyle.fill;
    if (roundStart && roundEnd) {
      final center = outerRect.center;
      final realEndAngle = realStartAngle + realSweepAngle;
      final startCapCenter = center + Offset(
        centralRadius * cos(realStartAngle),
        centralRadius * sin(realStartAngle),
      );
      final endCapCenter = center + Offset(
        centralRadius * cos(realEndAngle),
        centralRadius * sin(realEndAngle),
      );
      final capDistance = (startCapCenter - endCapCenter).distance;
      final bigAngle = realStartAngle - realEndAngle;
      final bigHeight = centralRadius * cos(bigAngle / 2);
      final smallHeight = sqrt(
        capRadius * capRadius - capDistance * capDistance / 4
      );
      final nearRadius = bigHeight - smallHeight;
      final farRadius = bigHeight + smallHeight;
      final median = startAngle + sweepAngle / 2;
      final nearPoint = center + Offset(
        nearRadius * cos(median),
        nearRadius * sin(median),
      );
      final farPoint = center + Offset(
        farRadius * cos(median),
        farRadius * sin(median),
      );
      final path = Path();
      path.moveTo(farPoint.dx, farPoint.dy);
      path.arcToPoint(nearPoint, radius: Radius.circular(capRadius));
      path.arcToPoint(farPoint, radius: Radius.circular(capRadius));
      return makeSegment(path, paint);
    }
    final center = outerRect.center;
    final realEndAngle = realStartAngle + realSweepAngle;
    final b = 2 * centralRadius * cos(roundStart
      ? realEndAngle - realStartAngle
      : realStartAngle - realEndAngle
    );
    final c = centralRadius * centralRadius - capRadius * capRadius;
    final d = sqrt(b * b - 4 * c);
    final dist1 = (b + d) / 2;
    final dist2 = (b - d) / 2;
    final farDist = max(dist1, dist2);
    final nearDist = min(dist1, dist2);
    if (roundStart) {
      final cosEnd = cos(realEndAngle);
      final sinEnd = sin(realEndAngle);
      final farPoint = center + Offset(farDist * cosEnd, farDist * sinEnd);
      final nearPoint = center + Offset(nearDist * cosEnd, nearDist * sinEnd);
      final path = Path()
        ..moveTo(nearPoint.dx, nearPoint.dy)
        ..arcToPoint(farPoint, radius: Radius.circular(capRadius))
        ..close()
      ;
      return makeSegment(path, paint);
    } else if (roundEnd) {
      final cosStart = cos(realStartAngle);
      final sinStart = sin(realStartAngle);
      final farPoint = center + Offset(farDist * cosStart, farDist * sinStart);
      final nearPoint = center + Offset(nearDist * cosStart, nearDist * sinStart);
      final path = Path()
        ..moveTo(farPoint.dx, farPoint.dy)
        ..arcToPoint(nearPoint, radius: Radius.circular(capRadius))
        ..close()
      ;
      return makeSegment(path, paint);
    }
    return makeSegment(null, paint);
  }
}
