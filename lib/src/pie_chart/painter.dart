import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import '../label_position.dart';
import 'pie_data.dart';


class PiePainter<D> extends CustomPainter
{
  final Pie<D> data;
  final double angle;
  final double labelsOffset;
  final EdgeInsets padding;
  final ValueListenable<double>? animation;

  PiePainter({
    required this.data,
    this.angle = 0.0,
    this.labelsOffset = 0.0,
    this.padding = EdgeInsets.zero,
    this.animation,
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

    canvas.clipRect(layoutData.clipRect, doAntiAlias: false);
    final sectors = _sectors = _getSectors(layoutData);
    for (final s in sectors.values) {
      canvas.drawArc(s.rect, s.startAngle, s.sweepAngle, true, s.paint);
    }
    if (animation == null) {
      for (final label in layoutData.labels) {
        final (offset, paragraph) = label;
        canvas.drawParagraph(paragraph, offset);
      }
    }
  }

  @override
  bool shouldRepaint(final PiePainter<D> oldDelegate)
  {
    final needRepaint = data != oldDelegate.data
      || angle != oldDelegate.angle
      || labelsOffset != oldDelegate.labelsOffset
      || padding != oldDelegate.padding
    ;
    if (needRepaint) {
      _oldSectors = oldDelegate._sectors;
      _layoutData = null;
    } else {
      _layoutData = oldDelegate._layoutData;
      _lastSize = oldDelegate._lastSize;
    }
    return needRepaint;
  }

  @override
  bool shouldRebuildSemantics(final PiePainter<D> oldDelegate)
  {
    return false;
  }

  _LayoutData<D> _buildLayout(final Size size)
  {
    const doublePi = pi * 2;
    const halfPi = pi / 2;
    const oneAndHalfPi = pi + halfPi;
    final outerRect = Offset.zero & size;
    final innerRect = padding.deflateRect(outerRect);
    final center = innerRect.center;
    final side = innerRect.shortestSide;
    final radius = side / 2;
    final rect = Rect.fromCenter(center: center, width: side, height: side);
    final layoutData = _LayoutData<D>.empty(
      rect: rect,
      clipRect: outerRect,
    );
    var startAngle = angle;
    final labels = <({
      Sector<D> sector,
      ({Offset offset, ui.Paragraph paragraph}) label
    })>[];
    for (final sector in data.sectors) {
      final paint = Paint()
        ..color = sector.color
        ..style = PaintingStyle.fill
      ;
      final sweepAngle = doublePi * sector.value / 100;
      layoutData.sectors[sector.domain] = _Sector(
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
            final h = radius + labelsOffset;
            final dAngle = atan2(semiDiagonal, h);
            final angle = ui.lerpDouble(
              startAngle + dAngle,
              endAngle - dAngle,
              tX,
            )! % doublePi;
            final lblAnchor = center + Offset(h * cos(angle), h * sin(angle));
            final isTop = angle > pi;
            final isLeft = angle > halfPi && angle < oneAndHalfPi;
            final lblOffset = isTop
              ? isLeft
                ? lblAnchor - Offset(lblSize.width, lblSize.height)
                : lblAnchor - Offset(0.0, lblSize.height)
              : isLeft
                ? lblAnchor - Offset(lblSize.width, 0.0)
                : lblAnchor;
            labels.add((
              sector: sector,
              label: (offset: lblOffset, paragraph: paragraph)
            ));
        }
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

  Map<D, _Sector> _getSectors(final _LayoutData<D> layoutData)
  {
    final animation = this.animation;
    if (animation == null) {
      return layoutData.sectors;
    } else {
      final sectors = <D, _Sector>{};
      final newSectors = Map<D, _Sector>.from(layoutData.sectors);
      final oldSectors = Map<D, _Sector>.from(_oldSectors!);
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
      return sectors;
    }
  }

  _LayoutData<D>? _layoutData;
  Size? _lastSize;
  Map<D, _Sector>? _sectors;
  Map<D, _Sector>? _oldSectors;
}


class _LayoutData<D>
{
  final Rect rect;
  final Rect clipRect;
  final Map<D, _Sector> sectors;
  final List<(Offset, ui.Paragraph)> labels;

  const _LayoutData({
    required this.rect,
    required this.clipRect,
    required this.sectors,
    required this.labels,
  });

  factory _LayoutData.empty({
    required final Rect rect,
    required final Rect clipRect,
  }) => _LayoutData(
    rect: rect,
    clipRect: clipRect,
    sectors: {},
    labels: [],
  );
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
