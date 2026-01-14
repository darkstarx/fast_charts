import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../label_position.dart';
import '../strokes_config.dart';
import 'pie_data.dart';


class PiePainter<D> extends CustomPainter
{
  final Pie<D> data;
  final ValueListenable<double>? animation;
  final double angle;
  final double labelsOffset;
  final StrokesConfig? strokes;
  final double holeSize;
  final EdgeInsets padding;
  final Clip clipBehavior;

  PiePainter({
    required this.data,
    this.animation,
    this.angle = 0.0,
    this.labelsOffset = 0.0,
    this.strokes,
    this.holeSize = 0.0,
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
    final pie = _pie = _getPie(layoutData);
    for (final s in pie.sectors.values) {
      final path = s.path;
      if (path == null) {
        canvas.drawArc(s.rect, s.startAngle, s.sweepAngle, true, s.paint);
      } else {
        canvas.drawPath(path, s.paint);
      }
    }
    final strokePath = pie.strokePath;
    final strokePaint = pie.strokePaint;
    if (strokePath != null && strokePaint != null) {
      canvas.drawPath(strokePath, strokePaint);
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
  bool shouldRepaint(final PiePainter<D> oldDelegate)
  {
    _layoutData = oldDelegate._layoutData;
    _lastSize = oldDelegate._lastSize;
    _pie = oldDelegate._pie;
    _oldPie = oldDelegate._oldPie;
    final needRebuild = data != oldDelegate.data
      || angle != oldDelegate.angle
      || labelsOffset != oldDelegate.labelsOffset
      || padding != oldDelegate.padding
      || strokes != oldDelegate.strokes
      || holeSize != oldDelegate.holeSize
    ;
    if (needRebuild) {
      _layoutData?.dispose();
      _layoutData = null;
      _oldPie = _pie;
    }
    return needRebuild
      || clipBehavior != oldDelegate.clipBehavior
    ;
  }

  @override
  bool shouldRebuildSemantics(final PiePainter<D> oldDelegate)
  {
    return false;
  }

  void dispose()
  {
    _layoutData?.dispose();
    _layoutData = null;
  }

  _LayoutData<D> _buildLayout(final Size size)
  {
    const doublePi = pi * 2;
    final outerRect = Offset.zero & size;
    final innerRect = padding.deflateRect(outerRect);
    final center = innerRect.center;
    final diameter = innerRect.shortestSide;
    final radius = diameter / 2;
    final rect = Rect.fromCenter(center: center,
      width: diameter, height: diameter,
    );
    final holeRadius = (radius * holeSize).clamp(0.0, radius - 1.0);
    final holeDiameter = (diameter * holeSize).clamp(0.0, diameter - 2.0);
    final thickness = radius - holeRadius;
    var startAngle = angle;
    final labels = <({
      Sector<D> sector,
      ({Offset offset, ui.Paragraph paragraph}) label
    })>[];

    Path? strokePath;
    Paint? strokePaint;
    final strokes = this.strokes;
    if (strokes != null && strokes.effective) {
      strokePaint = Paint()
        ..color = strokes.color
        ..strokeWidth = strokes.width
        ..style = PaintingStyle.stroke
      ;
      strokePath = Path();
      if (strokes.outer) {
        strokePath.addOval(rect);
        if (holeDiameter > 0.0) {
          strokePath.addOval(Rect.fromCenter(center: rect.center,
            width: holeDiameter, height: holeDiameter,
          ));
        }
      }
    }
    final layoutData = _LayoutData<D>(
      rect: rect,
      clipRect: outerRect,
      pie: _Pie(
        strokePath: strokePath,
        strokePaint: strokePaint,
        sectors: {},
      ),
      labels: [],
    );

    for (final sector in data.sectors) {
      final paint = Paint()
        ..color = sector.color
        ..style = PaintingStyle.fill
      ;
      final sweepAngle = doublePi * sector.value.abs() / 100;
      layoutData.pie.sectors[sector.domain] = _Sector.withHole(
        rect: rect,
        startAngle: startAngle,
        sweepAngle: sweepAngle,
        paint: paint,
        holeSize: holeSize,
      );
      final label = sector.label;
      if (label != null) {
        final paragraphBuilder = ui.ParagraphBuilder(ui.ParagraphStyle())
          ..pushStyle(label.style.getTextStyle())
          ..addText(label.value)
        ;
        final paragraph = paragraphBuilder.build();
        paragraph.layout(ui.ParagraphConstraints(width: innerRect.width));
        final lblSize = Size(paragraph.longestLine, paragraph.height);
        final tX = 0.5 + label.alignment.x / 2;
        final tY = 0.5 + label.alignment.y / 2;
        final endAngle = startAngle + sweepAngle;
        switch (label.position) {
          case LabelPosition.inside:
            final lblCentering = Offset(lblSize.width / 2, lblSize.height / 2);
            final semiDiagonal = lblCentering.distance;
            var h = ui.lerpDouble(max(holeRadius, semiDiagonal), radius, tY)!;
            final dAngle = atan2(semiDiagonal, h);
            final angle = ui.lerpDouble(
              startAngle + dAngle,
              endAngle - dAngle,
              tX,
            )!;
            final cosAngle = cos(angle);
            final sinAngle = sin(angle);
            var lblCenter = Offset(h * cosAngle, h * sinAngle);
            final lblRect = Rect.fromCenter(
              center: lblCenter,
              width: lblSize.width,
              height: lblSize.height,
            );
            final lblPoints = [
              lblRect.topLeft,
              lblRect.topCenter,
              lblRect.topRight,
              lblRect.centerLeft,
              lblRect.centerRight,
              lblRect.bottomLeft,
              lblRect.bottomCenter,
              lblRect.bottomRight,
            ];
            var adjustment = 0.0;
            final inDistances = lblPoints
              .map((p) => radius - p.distance)
              .where((d) => d > thickness);
            if (inDistances.isNotEmpty) {
              adjustment += max(0.0, inDistances.reduce(max) - thickness);
            }
            final outDistances = lblPoints
              .map((p) => p.distance)
              .where((d) => d > radius);
            if (outDistances.isNotEmpty) {
              adjustment -= max(0.0, outDistances.reduce(max) - radius);
            }
            if (adjustment != 0.0) {
              h += adjustment;
              lblCenter = Offset(h * cosAngle, h * sinAngle);
            }
            final lblOffset = center + lblCenter - lblCentering;
            labels.add((
              sector: sector,
              label: (offset: lblOffset, paragraph: paragraph)
            ));
          case LabelPosition.outside:
            final lblCentering = Offset(lblSize.width / 2, lblSize.height / 2);
            final semiDiagonal = lblCentering.distance;
            var h = radius + labelsOffset;
            final dAngle = atan2(semiDiagonal, h);
            final angle = ui.lerpDouble(
              startAngle + dAngle,
              endAngle - dAngle,
              tX,
            )! % doublePi;
            var lblAnchor = Offset(h * cos(angle), h * sin(angle));
            final lblRect = Rect.fromCenter(
              center: lblAnchor,
              width: lblSize.width,
              height: lblSize.height,
            );
            final lblDistances = [
              lblRect.topLeft.distance,
              lblRect.centerLeft.distance,
              lblRect.bottomLeft.distance,
              lblRect.topCenter.distance,
              lblRect.bottomCenter.distance,
              lblRect.topRight.distance,
              lblRect.centerRight.distance,
              lblRect.bottomRight.distance,
            ];
            final adjustment = h - lblDistances.reduce(min);
            if (adjustment > 0.0) {
              h += adjustment;
              lblAnchor = Offset(h * cos(angle), h * sin(angle));
            }
            final lblOffset = center + lblAnchor - lblCentering;
            labels.add((
              sector: sector,
              label: (offset: lblOffset, paragraph: paragraph)
            ));
        }
      }
      if (strokes != null && strokes.inner) {
        final point = Offset(cos(startAngle), sin(startAngle));
        final p1 = center + point * holeRadius;
        final p2 = center + point * radius;
        strokePath!
          ..moveTo(p1.dx, p1.dy)
          ..lineTo(p2.dx, p2.dy)
        ;
      }
      startAngle += sweepAngle;
    }
    labels.sort((a, b) {
      var c = b.sector.value.compareTo(a.sector.value);
      if (c == 0) {
        final aIndex = data.sectors.indexOf(a.sector);
        final bIndex = data.sectors.indexOf(b.sector);
        c = aIndex.compareTo(bIndex);
      }
      return c;
    });
    for (var i = 0; i < labels.length; ++i) {
      final one = labels[i];
      final oneRect = one.label.offset & Size(
        one.label.paragraph.longestLine,
        one.label.paragraph.height,
      );
      for (var j = i + 1; j < labels.length;) {
        final another = labels[j];
        final anotherRect = another.label.offset & Size(
          another.label.paragraph.longestLine,
          another.label.paragraph.height,
        );
        if (oneRect.overlaps(anotherRect)) {
          labels.removeAt(j);
        } else {
          ++j;
        }
      }
    }
    for (final entry in labels) {
      layoutData.labels.add((entry.label.offset, entry.label.paragraph));
    }
    return layoutData;
  }

  _Pie<D> _getPie(final _LayoutData<D> layoutData)
  {
    final animation = this.animation;
    if (animation == null || _oldPie == null) {
      return layoutData.pie;
    } else {
      final sectors = <D, _Sector>{};
      final newSectors = Map<D, _Sector>.from(layoutData.pie.sectors);
      final oldSectors = Map<D, _Sector>.from(_oldPie!.sectors);
      for (final entry in newSectors.entries.toList()) {
        final domain = entry.key;
        final newSector = entry.value;
        final oldSector = oldSectors.remove(domain);
        if (oldSector == null) continue;
        final rect = Rect.lerp(oldSector.rect, newSector.rect,
          animation.value,
        )!;
        final startAngle = ui.lerpDouble(oldSector.startAngle, newSector.startAngle,
          animation.value,
        )!;
        final sweepAngle = ui.lerpDouble(oldSector.sweepAngle, newSector.sweepAngle,
          animation.value,
        )!;
        final paint = Paint()
          ..color = Color.lerp(oldSector.paint.color, newSector.paint.color,
            animation.value,
          )!
          ..style = PaintingStyle.fill
        ;
        sectors[domain] = _Sector.withHole(
          rect: rect,
          startAngle: startAngle,
          sweepAngle: sweepAngle,
          paint: paint,
          holeSize: holeSize,
        );
        newSectors.remove(domain);
      }
      for (final entry in newSectors.entries.toList()) {
        final domain = entry.key;
        final newSector = entry.value;
        final _Sector oldSector;
        if (oldSectors.isEmpty) {
          oldSector = _Sector.withHole(
            rect: newSector.rect,
            startAngle: angle,
            sweepAngle: 0.0,
            paint: newSector.paint,
            holeSize: holeSize,
          );
        } else {
          oldSector = oldSectors.remove(oldSectors.keys.first)!;
        }
        final rect = Rect.lerp(oldSector.rect, newSector.rect,
          animation.value,
        )!;
        final startAngle = ui.lerpDouble(oldSector.startAngle, newSector.startAngle,
          animation.value,
        )!;
        final sweepAngle = ui.lerpDouble(oldSector.sweepAngle, newSector.sweepAngle,
          animation.value,
        )!;
        final paint = Paint()
          ..color = Color.lerp(oldSector.paint.color, newSector.paint.color,
            animation.value,
          )!
          ..style = PaintingStyle.fill
        ;
        sectors[domain] = _Sector.withHole(
          rect: rect,
          startAngle: startAngle,
          sweepAngle: sweepAngle,
          paint: paint,
          holeSize: holeSize,
        );
        newSectors.remove(domain);
      }
      for (final entry in oldSectors.entries.toList())  {
        final domain = entry.key;
        final oldSector = entry.value;
        if (sectors.containsKey(domain)) continue;
        sectors[domain] = _Sector.withHole(
          rect: Rect.lerp(oldSector.rect, layoutData.rect,
            animation.value,
          )!,
          startAngle: ui.lerpDouble(oldSector.startAngle, angle,
            animation.value,
          )!,
          sweepAngle: ui.lerpDouble(oldSector.sweepAngle, 0.0,
            animation.value,
          )!,
          paint: oldSector.paint,
          holeSize: holeSize,
        );
        oldSectors.remove(domain);
      }
      assert(newSectors.isEmpty);
      assert(oldSectors.isEmpty);
      Paint? strokePaint;
      Path? strokePath;
      final strokes = this.strokes;
      if (strokes != null && strokes.effective && sectors.isNotEmpty) {
        final hl = holeSize.clamp(0.0, 1.0);
        strokePaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokes.width
          ..color = strokes.color
        ;
        strokePath = Path();
        if (strokes.inner) {
          for (final sector in sectors.values) {
            final center = sector.rect.center;
            final radius = sector.rect.width / 2;
            final point = Offset(cos(sector.startAngle), sin(sector.startAngle));
            final p1 = center + point * radius * hl;
            final p2 = center + point * radius;
            strokePath
              ..moveTo(p1.dx, p1.dy)
              ..lineTo(p2.dx, p2.dy)
            ;
          }
        }
        if (strokes.outer) {
          strokePath.addOval(layoutData.rect);
          if (hl > 0.0) {
            strokePath.addOval(Rect.fromCenter(
              center: layoutData.rect.center,
              width: layoutData.rect.width * hl,
              height: layoutData.rect.height * hl,
            ));
          }
        }
      }
      return _Pie(
        sectors: sectors,
        strokePath: strokePath,
        strokePaint: strokePaint,
      );
    }
  }

  /// The latest content to be drawn next [paint] call.
  _LayoutData<D>? _layoutData;

  /// The size of the last drawn content.
  ///
  /// It's used to define if the [_layoutData] must be rebuilt.
  Size? _lastSize;

  /// The last drawn pie.
  ///
  /// It goes to the [_oldPie] every time the data changes. Than it's used to
  /// compare previous sectors with new sectors to animate the change.
  _Pie<D>? _pie;

  /// The pie built of the previous data's sectors.
  ///
  /// Every time the data changes, the last drawn [_pie] goes into this value to
  /// be compared with the new data's sectors. Than the new and old versions of
  /// sectors merge into new [_pie] using the current animation.
  _Pie<D>? _oldPie;
}


class _LayoutData<D>
{
  /// The pie square.
  final Rect rect;

  /// The area of the widget to be clipped.
  final Rect clipRect;

  /// The geometry of the pie.
  final _Pie<D> pie;

  /// Paragraphs with their positions.
  final List<(Offset, ui.Paragraph)> labels;

  const _LayoutData({
    required this.rect,
    required this.clipRect,
    required this.pie,
    required this.labels,
  });

  void dispose()
  {
    for (final label in labels) {
      final (_, paragraph) = label;
      paragraph.dispose();
    }
  }
}


class _Pie<D>
{
  final Path? strokePath;
  final Paint? strokePaint;
  final Map<D, _Sector> sectors;

  const _Pie({
    required this.strokePath,
    required this.strokePaint,
    required this.sectors,
  });
}


class _Sector
{
  final Rect rect;
  final double startAngle;
  final double sweepAngle;
  final Paint paint;
  final Path? path;

  const _Sector({
    required this.rect,
    required this.startAngle,
    required this.sweepAngle,
    required this.paint,
    this.path,
  });

  factory _Sector.withHole({
    required final Rect rect,
    required final double startAngle,
    required final double sweepAngle,
    required final Paint paint,
    required final double holeSize,
  })
  {
    final hs = holeSize.clamp(0.0, 1.0);
    Path? path;
    if (hs > 0.0) {
      final d = rect.shortestSide;
      final r = d / 2;
      final hr = min(r * hs, r - 1.0);
      final hd = hr * 2;
      final center = rect.center;
      final hRect = Rect.fromCenter(center: center, width: hd, height: hd);
      final endAngle = startAngle + sweepAngle;
      path = Path()
        ..arcTo(rect, startAngle, sweepAngle, false)
        ..lineTo(center.dx + cos(endAngle) * hr, center.dy + sin(endAngle) * hr)
        ..arcTo(hRect, endAngle, -sweepAngle, false)
      ;
    }
    return _Sector(
      rect: rect,
      startAngle: startAngle,
      sweepAngle: sweepAngle,
      paint: paint,
      path: path,
    );
  }
}
