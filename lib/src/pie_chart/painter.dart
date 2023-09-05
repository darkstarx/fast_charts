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
  final EdgeInsets padding;
  final Clip clipBehavior;
  final StrokesConfig? strokes;

  PiePainter({
    required this.data,
    this.animation,
    this.angle = 0.0,
    this.labelsOffset = 0.0,
    this.padding = EdgeInsets.zero,
    this.clipBehavior = Clip.hardEdge,
    this.strokes,
  })
  : super(repaint: animation);

  @override
  void paint(final Canvas canvas, final Size size)
  {
    if (_lastSize != size) {
      _lastSize = size;
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
      canvas.drawArc(s.rect, s.startAngle, s.sweepAngle, true, s.paint);
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
    final needRebuild = data != oldDelegate.data
      || angle != oldDelegate.angle
      || labelsOffset != oldDelegate.labelsOffset
      || padding != oldDelegate.padding
      || strokes != oldDelegate.strokes
    ;
    if (needRebuild) {
      _layoutData = null;
      _oldPie = oldDelegate._pie;
    } else {
      _layoutData = oldDelegate._layoutData;
      _lastSize = oldDelegate._lastSize;
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

  _LayoutData<D> _buildLayout(final Size size)
  {
    const doublePi = pi * 2;
    final outerRect = Offset.zero & size;
    final innerRect = padding.deflateRect(outerRect);
    final center = innerRect.center;
    final side = innerRect.shortestSide;
    final radius = side / 2;
    final rect = Rect.fromCenter(center: center, width: side, height: side);
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
      layoutData.pie.sectors[sector.domain] = _Sector(
        rect: rect,
        startAngle: startAngle,
        sweepAngle: sweepAngle,
        paint: paint
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
            var h = semiDiagonal + (radius - semiDiagonal) * tY;
            final dAngle = atan2(semiDiagonal, h);
            final angle = ui.lerpDouble(
              startAngle + dAngle,
              endAngle - dAngle,
              tX,
            )!;
            var lblCenter = Offset(h * cos(angle), h * sin(angle));
            final lblRect = Rect.fromCenter(
              center: lblCenter,
              width: lblSize.width,
              height: lblSize.height,
            );
            final lblDistances = [
              lblRect.topLeft.distance,
              lblRect.topRight.distance,
              lblRect.bottomLeft.distance,
              lblRect.bottomRight.distance,
            ];
            final outDistances = lblDistances.where((d) => d > radius).toList();
            if (outDistances.isNotEmpty) {
              final adjustment = max(0.0, lblDistances.reduce(max) - radius);
              h -= adjustment;
              lblCenter = Offset(h * cos(angle), h * sin(angle));
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
        final point = center + Offset(
          cos(startAngle) * radius,
          sin(startAngle) * radius,
        );
        strokePath!
          ..moveTo(center.dx, center.dy)
          ..lineTo(point.dx, point.dy)
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
    if (animation == null) {
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
        sectors[domain] = _Sector(
          rect: Rect.lerp(oldSector.rect, newSector.rect,
            animation.value,
          )!,
          startAngle: ui.lerpDouble(oldSector.startAngle, newSector.startAngle,
            animation.value,
          )!,
          sweepAngle: ui.lerpDouble(oldSector.sweepAngle, newSector.sweepAngle,
            animation.value,
          )!,
          paint: Paint()
            ..color = Color.lerp(oldSector.paint.color, newSector.paint.color,
              animation.value,
            )!
            ..style = PaintingStyle.fill,
        );
        newSectors.remove(domain);
      }
      for (final entry in newSectors.entries.toList()) {
        final domain = entry.key;
        final newSector = entry.value;
        final oldSector = oldSectors.isEmpty
          ? _Sector(
              rect: newSector.rect,
              startAngle: angle,
              sweepAngle: 0.0,
              paint: newSector.paint,
            )
          : oldSectors.remove(oldSectors.keys.first)!;
        sectors[domain] = _Sector(
          rect: Rect.lerp(oldSector.rect, newSector.rect,
            animation.value,
          )!,
          startAngle: ui.lerpDouble(oldSector.startAngle, newSector.startAngle,
            animation.value,
          )!,
          sweepAngle: ui.lerpDouble(oldSector.sweepAngle, newSector.sweepAngle,
            animation.value,
          )!,
          paint: Paint()
            ..color = Color.lerp(oldSector.paint.color, newSector.paint.color,
              animation.value,
            )!
            ..style = PaintingStyle.fill,
        );
        newSectors.remove(domain);
      }
      for (final entry in oldSectors.entries.toList())  {
        final domain = entry.key;
        final oldSector = entry.value;
        if (sectors.containsKey(domain)) continue;
        sectors[domain] = _Sector(
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
        );
        oldSectors.remove(domain);
      }
      assert(newSectors.isEmpty);
      assert(oldSectors.isEmpty);
      Paint? strokePaint;
      Path? strokePath;
      final strokes = this.strokes;
      if (strokes != null && strokes.effective && sectors.isNotEmpty) {
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
            final point = center + Offset(
              cos(sector.startAngle) * radius,
              sin(sector.startAngle) * radius,
            );
            strokePath
              ..moveTo(center.dx, center.dy)
              ..lineTo(point.dx, point.dy)
            ;
          }
        }
        if (strokes.outer) {
          strokePath.addOval(sectors.values.first.rect);
        }
      }
      return _Pie(
        sectors: sectors,
        strokePath: strokePath,
        strokePaint: strokePaint,
      );
    }
  }

  _LayoutData<D>? _layoutData;
  Size? _lastSize;
  _Pie<D>? _pie;
  _Pie<D>? _oldPie;
}


class _LayoutData<D>
{
  final Rect rect;
  final Rect clipRect;
  final _Pie<D> pie;
  final List<(Offset, ui.Paragraph)> labels;

  const _LayoutData({
    required this.rect,
    required this.clipRect,
    required this.pie,
    required this.labels,
  });
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

  const _Sector({
    required this.rect,
    required this.startAngle,
    required this.sweepAngle,
    required this.paint,
  });
}
