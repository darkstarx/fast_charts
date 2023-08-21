import 'dart:collection';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../label_position.dart';
import '../ticks_resolver.dart';
import '../types.dart';
import 'bar_data.dart';


class BarPainter extends CustomPainter
{
  final ChartBars data;
  final ValueListenable<double>? animation;
  final TicksResolver ticksResolver;
  final MeasureFormatter? measureFormatter;
  final TextStyle mainAxisTextStyle;
  final TextStyle crossAxisTextStyle;
  final Color axisColor;
  final double axisThickness;
  final Color guideLinesColor;
  final double guideLinesThickness;
  final double mainAxisLabelsOffset;
  final double crossAxisLabelsOffset;
  final double? mainAxisWidth;
  final double? crossAxisWidth;
  final bool showMainAxisLine;
  final bool showCrossAxisLine;
  final double barPadding;
  final double barSpacing;
  final double groupSpacing;
  final EdgeInsets padding;

  BarPainter({
    required this.data,
    this.animation,
    required this.ticksResolver,
    this.measureFormatter,
    required this.mainAxisTextStyle,
    required this.crossAxisTextStyle,
    required this.axisColor,
    this.axisThickness = 1.0,
    required this.guideLinesColor,
    this.guideLinesThickness = 1.0,
    this.mainAxisLabelsOffset = 2.0,
    this.crossAxisLabelsOffset = 2.0,
    this.mainAxisWidth,
    this.crossAxisWidth,
    this.showMainAxisLine = false,
    this.showCrossAxisLine = true,
    this.barPadding = 0.0,
    this.barSpacing = 0.0,
    this.groupSpacing = 0.0,
    this.padding = EdgeInsets.zero,
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
    final axisPaint = Paint()
      ..color = axisColor
      ..strokeWidth = axisThickness
    ;
    final guideLinesPaint = Paint()
      ..color = guideLinesColor
      ..strokeWidth = guideLinesThickness
    ;

    canvas.clipRect(layoutData.clipRect, doAntiAlias: false);
    for (final line in layoutData.guideLines) {
      final (p1, p2) = line;
      canvas.drawLine(p1, p2, guideLinesPaint);
    }
    for (final line in layoutData.axisLines) {
      final (p1, p2) = line;
      canvas.drawLine(p1, p2, axisPaint);
    }
    for (final label in layoutData.mainLabels) {
      final (offset, paragraph) = label;
      canvas.drawParagraph(paragraph, offset);
    }
    for (final label in layoutData.crossLabels) {
      final (offset, paragraph) = label;
      canvas.drawParagraph(paragraph, offset);
    }
    final barGroups = _barGroups = _getBars(layoutData);
    for (final entry in barGroups.entries) {
      final barGroup = entry.value;
      if (barGroup.bars.isEmpty) continue;
      for (final entry in barGroup.bars.entries) {
        final bar = entry.value;
        final (rect, paint) = bar;
        canvas.drawRRect(rect, paint);
      }
    }
    if (animation == null) {
      for (final label in layoutData.labels) {
        final (offset, paragraph) = label;
        canvas.drawParagraph(paragraph, offset);
      }
    }
  }

  @override
  bool shouldRepaint(final BarPainter oldDelegate)
  {
    final needRepaint = data != oldDelegate.data
      || ticksResolver != oldDelegate.ticksResolver
      || measureFormatter != oldDelegate.measureFormatter
      || mainAxisTextStyle != oldDelegate.mainAxisTextStyle
      || crossAxisTextStyle != oldDelegate.crossAxisTextStyle
      || axisColor != oldDelegate.axisColor
      || axisThickness != oldDelegate.axisThickness
      || guideLinesColor != oldDelegate.guideLinesColor
      || guideLinesThickness != oldDelegate.guideLinesThickness
      || mainAxisLabelsOffset != oldDelegate.mainAxisLabelsOffset
      || crossAxisLabelsOffset != oldDelegate.crossAxisLabelsOffset
      || mainAxisWidth != oldDelegate.mainAxisWidth
      || crossAxisWidth != oldDelegate.crossAxisWidth
      || showMainAxisLine != oldDelegate.showMainAxisLine
      || showCrossAxisLine != oldDelegate.showCrossAxisLine
      || barPadding != oldDelegate.barPadding
      || barSpacing != oldDelegate.barSpacing
      || padding != oldDelegate.padding
    ;
    if (needRepaint) {
      _oldBarGroups = oldDelegate._barGroups;
      _layoutData = null;
    } else {
      _layoutData = oldDelegate._layoutData;
      _lastSize = oldDelegate._lastSize;
    }
    return needRepaint;
  }

  @override
  bool shouldRebuildSemantics(final BarPainter oldDelegate)
  {
    return false;
  }

  Map<int, _LayoutBarGroup> _getBars(final _LayoutData layoutData)
  {
    if (animation == null) {
      return layoutData.barGroups;
    } else {
      final result = <int, _LayoutBarGroup>{};
      for (final entry in layoutData.barGroups.entries) {
        final groupId = entry.key;
        final group = entry.value;
        final oldGroup = _oldBarGroups?[groupId];
        final oldBars = oldGroup?.bars ?? {};
        final anyOldBar = oldBars.isEmpty
          ? null
          : oldBars.values.first;
        final layoutStack = result.putIfAbsent(groupId,
          () => _LayoutBarGroup.empty(),
        );
        for (final entry in group.bars.entries) {
          final barId = entry.key;
          final bar = entry.value;
          final (newRect, newPaint) = bar;
          var oldBar = oldBars[barId];
          if (oldBar == null) {
            final (dRect, _) = anyOldBar ?? bar;
            switch (data.valueAxis) {
              case Axis.horizontal:
                oldBar = (
                  RRect.fromLTRBAndCorners(
                    layoutData.crossAxisOffset, dRect.top,
                    layoutData.crossAxisOffset, dRect.bottom,
                    topLeft: dRect.tlRadius,
                    topRight: dRect.trRadius,
                    bottomLeft: dRect.blRadius,
                    bottomRight: dRect.brRadius,
                  ),
                  newPaint
                );
                break;
              case Axis.vertical:
                oldBar = (
                  RRect.fromLTRBAndCorners(
                    dRect.left, layoutData.crossAxisOffset,
                    dRect.right, layoutData.crossAxisOffset,
                    topLeft: dRect.tlRadius,
                    topRight: dRect.trRadius,
                    bottomLeft: dRect.blRadius,
                    bottomRight: dRect.brRadius,
                  ),
                  newPaint
                );
                break;
            }
          }
          final (oldRect, oldPaint) = oldBar;
          final rect = RRect.lerp(oldRect, newRect, animation!.value)!;
          final paint = Paint()
            ..color = Color.lerp(oldPaint.color, newPaint.color,
                animation!.value
              )!
            ..style = PaintingStyle.fill
          ;
          layoutStack.bars[barId] = (rect, paint);
        }
        final anyNewSegment = group.bars.isEmpty
          ? null
          : group.bars.values.first;
        for (final entry in oldBars.entries.where(
          (e) => !group.bars.containsKey(e.key)
        )) {
          final segmentId = entry.key;
          final oldSegment = entry.value;
          final (oldRect, oldPaint) = oldSegment;
          final (dRect, _) = anyNewSegment ?? oldSegment;
          final RRect newRect;
          switch (data.valueAxis) {
            case Axis.horizontal:
              newRect = RRect.fromLTRBAndCorners(
                layoutData.crossAxisOffset, dRect.top,
                layoutData.crossAxisOffset, dRect.bottom,
                topLeft: dRect.tlRadius,
                topRight: dRect.trRadius,
                bottomLeft: dRect.blRadius,
                bottomRight: dRect.brRadius,
              );
              break;
            case Axis.vertical:
              newRect = RRect.fromLTRBAndCorners(
                dRect.left, layoutData.crossAxisOffset,
                dRect.right, layoutData.crossAxisOffset,
                topLeft: dRect.tlRadius,
                topRight: dRect.trRadius,
                bottomLeft: dRect.blRadius,
                bottomRight: dRect.brRadius,
              );
              break;
          }
          final rect = RRect.lerp(oldRect, newRect, animation!.value)!;
          layoutStack.bars[segmentId] = (rect, oldPaint);
        }
        result[groupId] = _LayoutBarGroup(
          bars: layoutStack.bars,
        );
      }
      return result;
    }
  }

  _LayoutData _buildLayout(final Size size)
  {
    final outerRect = Offset.zero & size;
    final innerRect = padding.deflateRect(outerRect);
    final layoutData = _LayoutData.empty(outerRect);

    final double mainLabelWidth;
    final double crossLabelWidth;
    final TextAlign domainTextAlign;
    switch (data.valueAxis) {
      case Axis.horizontal:
        mainLabelWidth = innerRect.width / 2;
        crossLabelWidth = crossAxisWidth ?? innerRect.width / 2;
        domainTextAlign = TextAlign.right;
        break;
      case Axis.vertical:
        mainLabelWidth = mainAxisWidth ?? innerRect.width / 2;
        crossLabelWidth = innerRect.width / 2;
        domainTextAlign = TextAlign.center;
        break;
    }
    final domainLabels = <ui.Paragraph>[];
    var domainMaxSize = Size.zero;
    for (final group in data.groups) {
      final labelBuilder = ui.ParagraphBuilder(ui.ParagraphStyle(
        textDirection: TextDirection.ltr,
        textAlign: domainTextAlign,
      ));
      labelBuilder.pushStyle(mainAxisTextStyle.getTextStyle());
      labelBuilder.addText(group.domain);
      final label = labelBuilder.build();
      label.layout(ui.ParagraphConstraints(width: crossLabelWidth));
      domainMaxSize = Size(
        max(domainMaxSize.width, label.longestLine),
        max(domainMaxSize.height, label.height),
      );
      domainLabels.add(label);
    }

    final double crossAxisField;
    final double mainAxisSize, crossAxisSize;
    switch (data.valueAxis) {
      case Axis.horizontal:
        crossAxisField = (crossAxisWidth ?? domainMaxSize.width)
          + axisThickness + crossAxisLabelsOffset;
        mainAxisSize = innerRect.width - crossAxisField;
        crossAxisSize = innerRect.height;
        break;
      case Axis.vertical:
        crossAxisField = (crossAxisWidth ?? domainMaxSize.height)
          + axisThickness + crossAxisLabelsOffset;
        mainAxisSize = innerRect.height - crossAxisField;
        crossAxisSize = innerRect.width;
        break;
    }
    var dataExtremes = data.groups
      .map((e) => e.extremes)
      .fold(
        (lower: 0.0, upper: 0.0),
        (minmax, lowerupper) => (
          lower: min(minmax.lower, lowerupper.lower),
          upper: max(minmax.upper, lowerupper.upper),
        )
      )
    ;

    var dataRange = dataExtremes.upper - dataExtremes.lower;
    var upperPixels = dataExtremes.upper * mainAxisSize / dataRange;
    var lowerPixels = -dataExtremes.lower * mainAxisSize / dataRange;
    final double mainAxisField;
    final List<(double, String)> mainTicks;
    final tickValues = ticksResolver.getTickValues(
      minValue: dataExtremes.lower.smooth,
      maxValue: dataExtremes.upper.smooth,
      axisSize: mainAxisSize,
    );
    if (tickValues.isEmpty) {
      mainTicks = [ (0.0, _formatMeasure(0.0)) ];
    } else {
      if (tickValues.length > 1) {
        dataExtremes = (lower: tickValues.first, upper: tickValues.last);
        dataRange = dataExtremes.upper - dataExtremes.lower;
        upperPixels = dataExtremes.upper * mainAxisSize / dataRange;
        lowerPixels = -dataExtremes.lower * mainAxisSize / dataRange;
      }
      final tickValuesRange = tickValues.last - tickValues.first;
      mainTicks = tickValues
        .map((e) => (mainAxisSize * e / tickValuesRange, _formatMeasure(e)))
        .toList();
    }
    final mainLabels = <(double, ui.Paragraph)>[];
    var measureMaxSize = Size.zero;
    for (final tick in mainTicks) {
      final (offset, text) = tick;
      final labelBuilder = ui.ParagraphBuilder(ui.ParagraphStyle());
      labelBuilder.pushStyle(mainAxisTextStyle.getTextStyle());
      labelBuilder.addText(text);
      final label = labelBuilder.build();
      label.layout(ui.ParagraphConstraints(width: mainLabelWidth));
      measureMaxSize = Size(
        max(measureMaxSize.width, label.longestLine),
        max(measureMaxSize.height, label.height),
      );
      mainLabels.add((offset, label));
    }

    switch (data.valueAxis) {
      case Axis.horizontal:
        mainAxisField = (mainAxisWidth ?? measureMaxSize.height)
          + axisThickness + mainAxisLabelsOffset;
        final mainAxisOffset = innerRect.top + crossAxisSize - mainAxisField
          + axisThickness / 2;
        if (showMainAxisLine) {
          layoutData.axisLines.add((
            Offset(innerRect.left + crossAxisField, mainAxisOffset),
            Offset(innerRect.left + crossAxisField + mainAxisSize, mainAxisOffset),
          ));
        }
        final shift = innerRect.left + crossAxisField
          + (data.inverted ? upperPixels : lowerPixels);
        for (final label in mainLabels) {
          final (position, paragraph) = label;
          final labelOnMainAxis = data.inverted
            ? shift - position
            : shift + position;
          final line = (
            Offset(labelOnMainAxis, innerRect.top),
            Offset(labelOnMainAxis, innerRect.top + crossAxisSize - mainAxisField),
          );
          if (position == 0 && showCrossAxisLine) {
            layoutData.axisLines.add(line);
          } else {
            layoutData.guideLines.add(line);
          }
          layoutData.mainLabels.add((
            Offset(
              labelOnMainAxis - paragraph.longestLine / 2,
              mainAxisOffset + axisThickness / 2 + mainAxisLabelsOffset
            ),
            paragraph
          ));
        }
        break;
      case Axis.vertical:
        mainAxisField = (mainAxisWidth ?? measureMaxSize.width)
          + axisThickness + mainAxisLabelsOffset;
        final mainAxisOffset = innerRect.left + mainAxisField
          - axisThickness / 2;
        if (showMainAxisLine) {
          layoutData.axisLines.add((
            Offset(mainAxisOffset, innerRect.top),
            Offset(mainAxisOffset, innerRect.top + mainAxisSize),
          ));
        }
        final shift = innerRect.top + (data.inverted ? lowerPixels : upperPixels);
        for (final label in mainLabels) {
          final (position, paragraph) = label;
          final labelOnMainAxis = data.inverted
            ? shift + position
            : shift - position;
          final line = (
            Offset(innerRect.left + mainAxisField, labelOnMainAxis),
            Offset(innerRect.left + crossAxisSize, labelOnMainAxis),
          );
          if (position == 0 && showCrossAxisLine) {
            layoutData.axisLines.add(line);
          } else {
            layoutData.guideLines.add(line);
          }
          layoutData.mainLabels.add((
            Offset(
              mainAxisOffset - paragraph.longestLine - axisThickness / 2
                - mainAxisLabelsOffset,
              labelOnMainAxis - paragraph.height / 2,
            ),
            paragraph,
          ));
        }
        break;
    }

    final barThickness = max(
      0.0,
      (
        crossAxisSize
        - mainAxisField
        - barPadding * 2
        - (groupSpacing * (data.groups.length - 1))
        - data.groups.fold(0.0, (s, g) => s + barSpacing * (g.bars.length - 1))
      ) / data.groups.fold(0, (s, g) => s + g.bars.length),
    );

    final double upperMainZeroOffset;
    final double lowerMainZeroOffset;
    final double crossAxisOffset;
    double crossOffset;
    switch (data.valueAxis) {
      case Axis.horizontal:
        upperMainZeroOffset = data.inverted
          ? lowerPixels - innerRect.left - crossAxisField
          : lowerPixels + innerRect.left + crossAxisField;
        lowerMainZeroOffset = data.inverted
          ? upperPixels + innerRect.left + crossAxisField
          : upperPixels - innerRect.left - crossAxisField;
        crossAxisOffset = data.inverted
          ? lowerMainZeroOffset
          : upperMainZeroOffset;
        crossOffset = innerRect.top + barPadding;
        break;
      case Axis.vertical:
        upperMainZeroOffset = data.inverted
          ? lowerPixels + innerRect.top
          : lowerPixels - innerRect.top;
        lowerMainZeroOffset = data.inverted
          ? upperPixels - innerRect.top
          : upperPixels + innerRect.top;
        crossAxisOffset = data.inverted
          ? upperMainZeroOffset
          : lowerMainZeroOffset;
        crossOffset = innerRect.left + mainAxisField + barPadding;
        break;
    }
    for (var i = 0; i < data.groups.length; ++i) {
      final group = data.groups[i];
      final domainLabel = domainLabels[i];

      final groupThickness = barThickness * group.bars.length
        + barSpacing * (group.bars.length - 1);
      final groupMargin = (
        start: i == 0 ? barPadding : groupSpacing / 2,
        end: i == data.groups.length - 1 ? barPadding : groupSpacing / 2,
      );
      _buildGroupBars(layoutData,
        groupIndex: i,
        bars: group.bars,
        valueAxis: data.valueAxis,
        inverted: data.inverted,
        dataRange: dataRange,
        mainAxisSize: mainAxisSize,
        crossAxisOffset: crossAxisOffset,
        crossOffset: crossOffset,
        barThickness: barThickness,
        barSpacing: barSpacing,
        groupMargin: groupMargin,
      );

      switch (data.valueAxis) {
        case Axis.horizontal:
          final labelOffset = Offset(
            innerRect.left + crossAxisField - domainLabel.width
              - axisThickness / 2 - crossAxisLabelsOffset,
            crossOffset + (groupThickness - domainLabel.height) / 2,
          );
          layoutData.crossLabels.add((labelOffset, domainLabel));
          break;
        case Axis.vertical:
          final labelOffset = Offset(
            crossOffset + (groupThickness - domainLabel.width) / 2,
            innerRect.top + mainAxisSize + axisThickness / 2
              + crossAxisLabelsOffset,
          );
          layoutData.crossLabels.add((labelOffset, domainLabel));
          break;
      }
      crossOffset += groupSpacing
        + barThickness * group.bars.length
        + barSpacing * (group.bars.length - 1);
    }
    return layoutData.copyWith(crossAxisOffset: crossAxisOffset);
  }

  String _formatMeasure(final double measure)
  {
    return measureFormatter?.call(measure) ?? measure.toStringAsFixed(2);
  }

  static void _buildGroupBars(final _LayoutData layoutData, {
    required final int groupIndex,
    required final List<Bar> bars,
    required final Axis valueAxis,
    required final bool inverted,
    required final double dataRange,
    required final double mainAxisSize,
    required final double crossAxisOffset,
    required final double crossOffset,
    required final double barThickness,
    required final double barSpacing,
    required final ({ double start, double end}) groupMargin,
  })
  {
    final group = layoutData.barGroups.putIfAbsent(groupIndex,
      () => _LayoutBarGroup.empty(),
    );
    var offset = crossOffset;
    for (var index = 0; index < bars.length; ++index) {
      final bar = bars[index];
      final isFirst = index == 0;
      final isLast = index == bars.length - 1;
      final startMargin = isFirst ? groupMargin.start : barSpacing / 2;
      final endMargin = isLast ? groupMargin.end : barSpacing / 2;
      final measure = bar.value;
      final label = bar.label;
      final invert = inverted ^ (measure < 0);
      final barLength = measure.abs() / dataRange * mainAxisSize;
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = bar.color
      ;
      switch (valueAxis) {
        case Axis.horizontal:
          final innerRect = Rect.fromLTWH(
            invert ? crossAxisOffset - barLength : crossAxisOffset,
            offset,
            barLength,
            barThickness,
          );
          group.bars[index] = (
            RRect.fromRectAndCorners(innerRect,
              topRight: invert ? Radius.zero : bar.radius,
              bottomRight: invert ? Radius.zero : bar.radius,
              topLeft: invert ? bar.radius : Radius.zero,
              bottomLeft: invert ? bar.radius : Radius.zero,
            ),
            paint,
          );
          if (label != null) {
            final paragraphBuilder = ui.ParagraphBuilder(ui.ParagraphStyle())
              ..pushStyle(label.style.getTextStyle())
              ..addText(label.value)
            ;
            final paragraph = paragraphBuilder.build();
            paragraph.layout(ui.ParagraphConstraints(width: innerRect.width));
            final lblSize = Size(paragraph.longestLine, paragraph.height);
            final lblOffset = label.alignment.inscribe(lblSize, innerRect);
            switch (label.position) {
              case LabelPosition.inside:
                if (lblSize.height <= innerRect.height
                  && lblSize.width <= innerRect.width
                ) {
                  layoutData.labels.add((lblOffset.topLeft, paragraph));
                }
                break;
              case LabelPosition.outside:
                layoutData.labels.add((
                  Offset(
                    inverted
                      ? innerRect.left - lblSize.longestSide
                      : innerRect.right,
                    lblOffset.top,
                  ),
                  paragraph,
                ));
                break;
            }
          }
          break;
        case Axis.vertical:
          final innerRect = Rect.fromLTWH(
            offset,
            invert ? crossAxisOffset : crossAxisOffset - barLength,
            barThickness,
            barLength,
          );
          final rectPadding = EdgeInsets.only(
            left: startMargin,
            right: endMargin,
          );
          final outerRect = rectPadding.inflateRect(innerRect);
          group.bars[index] = (
            RRect.fromRectAndCorners(innerRect,
              topLeft: invert ? Radius.zero : bar.radius,
              topRight: invert ? Radius.zero : bar.radius,
              bottomLeft: invert ? bar.radius : Radius.zero,
              bottomRight: invert ? bar.radius : Radius.zero,
            ),
            paint,
          );
          if (label != null) {
            final paragraphBuilder = ui.ParagraphBuilder(ui.ParagraphStyle())
              ..pushStyle(label.style.getTextStyle())
              ..addText(label.value)
            ;
            final paragraph = paragraphBuilder.build();
            final double lblWidth;
            switch (label.position) {
              case LabelPosition.inside: lblWidth = innerRect.width;
              case LabelPosition.outside: lblWidth = outerRect.width;
            }
            paragraph.layout(ui.ParagraphConstraints(width: lblWidth));
            final lblSize = Size(paragraph.longestLine, paragraph.height);
            final lblOffset = label.alignment.inscribe(lblSize, innerRect);
            switch (label.position) {
              case LabelPosition.inside:
                if (lblSize.height <= innerRect.height
                  && lblSize.width <= innerRect.width
                ) {
                  layoutData.labels.add((lblOffset.topLeft, paragraph));
                }
                break;
              case LabelPosition.outside:
                layoutData.labels.add((
                  Offset(
                    lblOffset.left,
                    inverted ? outerRect.bottom : outerRect.top - lblSize.height,
                  ),
                  paragraph,
                ));
                break;
            }
          }
          break;
      }
      offset += barThickness + barSpacing;
    }
  }

  _LayoutData? _layoutData;
  Size? _lastSize;
  Map<int, _LayoutBarGroup>? _barGroups;
  Map<int, _LayoutBarGroup>? _oldBarGroups;
}


class _LayoutData
{
  final Rect clipRect;
  final double crossAxisOffset;
  final List<(Offset, Offset)> axisLines;
  final List<(Offset, Offset)> guideLines;
  final List<(Offset, ui.Paragraph)> mainLabels;
  final List<(Offset, ui.Paragraph)> crossLabels;
  final Map<int, _LayoutBarGroup> barGroups;
  final List<(Offset, ui.Paragraph)> labels;

  const _LayoutData({
    required this.clipRect,
    required this.crossAxisOffset,
    required this.axisLines,
    required this.guideLines,
    required this.mainLabels,
    required this.crossLabels,
    required this.barGroups,
    required this.labels,
  });

  factory _LayoutData.empty(final Rect clipRect) => _LayoutData(
    clipRect: clipRect,
    crossAxisOffset: 0.0,
    axisLines: [],
    guideLines: [],
    mainLabels: [],
    crossLabels: [],
    barGroups: {},
    labels: [],
  );

  _LayoutData copyWith({
    final Rect? clipRect,
    final double? crossAxisOffset,
    final List<(Offset, Offset)>? axisLines,
    final List<(Offset, Offset)>? guideLines,
    final List<(Offset, ui.Paragraph)>? mainLabels,
    final List<(Offset, ui.Paragraph)>? crossLabels,
    final Map<int, _LayoutBarGroup>? barGroups,
    final List<(Offset, ui.Paragraph)>? labels,
  }) => _LayoutData(
    clipRect: clipRect ?? this.clipRect,
    crossAxisOffset: crossAxisOffset ?? this.crossAxisOffset,
    axisLines: axisLines ?? this.axisLines,
    guideLines: guideLines ?? this.guideLines,
    mainLabels: mainLabels ?? this.mainLabels,
    crossLabels: crossLabels ?? this.crossLabels,
    barGroups: barGroups ?? this.barGroups,
    labels: labels ?? this.labels,
  );
}


class _LayoutBarGroup
{
  final Map<int, (RRect, Paint)> bars;

  const _LayoutBarGroup({
    required this.bars,
  });

  factory _LayoutBarGroup.empty() => _LayoutBarGroup(
    bars: SplayTreeMap(),
  );
}
