import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../ticks_resolver.dart';
import '../types.dart';
import 'stacked_data.dart';


class BarPainter extends CustomPainter
{
  final BarChartStacks data;
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
  final double barPadding;
  final double barSpacing;
  final EdgeInsets padding;

  BarPainter({
    required this.data,
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
    this.barPadding = 0.0,
    this.barSpacing = 0.0,
    this.padding = EdgeInsets.zero,
  });

  @override
  void paint(final Canvas canvas, final Size size)
  {
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
    for (final segment in layoutData.segments) {
      final (rrect, paint) = segment;
      canvas.drawRRect(rrect, paint);
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
      || barPadding != oldDelegate.barPadding
      || barSpacing != oldDelegate.barSpacing
      || padding != oldDelegate.padding
    ;
    if (needRepaint) {
      _layoutData = null;
    }
    return needRepaint;
  }

  @override
  bool shouldRebuildSemantics(final BarPainter oldDelegate)
  {
    return false;
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
    for (final stack in data.stacks) {
      final labelBuilder = ui.ParagraphBuilder(ui.ParagraphStyle(
        textDirection: TextDirection.ltr,
        textAlign: domainTextAlign,
      ));
      labelBuilder.pushStyle(mainAxisTextStyle.getTextStyle());
      labelBuilder.addText(stack.domain);
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
    var minmaxStackSumm = data.stacks
      .map((e) => e.summs)
      .fold(
        (lower: 0.0, upper: 0.0),
        (minmax, lowerupper) => (
          lower: min(minmax.lower, lowerupper.lower),
          upper: max(minmax.upper, lowerupper.upper),
        )
      )
    ;
    var maxStackSumm = minmaxStackSumm.upper - minmaxStackSumm.lower;
    var upperPixels = minmaxStackSumm.upper * mainAxisSize / maxStackSumm;
    var lowerPixels = -minmaxStackSumm.lower * mainAxisSize / maxStackSumm;
    final double mainAxisField;
    final List<(double, String)> mainTicks;
    final tickValues = ticksResolver.getTickValues(
      minValue: minmaxStackSumm.lower,
      maxValue: minmaxStackSumm.upper,
      axisSize: mainAxisSize,
    );
    if (tickValues.isEmpty) {
      mainTicks = [ (0.0, _formatMeasure(0.0)) ];
    } else {
      if (tickValues.length > 1) {
        minmaxStackSumm = (lower: tickValues.first, upper: tickValues.last);
        maxStackSumm = minmaxStackSumm.upper - minmaxStackSumm.lower;
        upperPixels = minmaxStackSumm.upper * mainAxisSize / maxStackSumm;
        lowerPixels = -minmaxStackSumm.lower * mainAxisSize / maxStackSumm;
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
        layoutData.axisLines.add((
          Offset(innerRect.left + crossAxisField, mainAxisOffset),
          Offset(innerRect.left + crossAxisField + mainAxisSize, mainAxisOffset),
        ));
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
          if (position == 0) {
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
        layoutData.axisLines.add((
          Offset(mainAxisOffset, innerRect.top),
          Offset(mainAxisOffset, innerRect.top + mainAxisSize),
        ));
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
          if (position == 0) {
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
        - (barSpacing * (data.stacks.length - 1))
      ) / data.stacks.length,
    );

    final double upperMainZeroOffset;
    final double lowerMainZeroOffset;
    double crossOffset;
    switch (data.valueAxis) {
      case Axis.horizontal:
        upperMainZeroOffset = data.inverted
          ? lowerPixels - innerRect.left - crossAxisField
          : lowerPixels + innerRect.left + crossAxisField;
        lowerMainZeroOffset = data.inverted
          ? upperPixels + innerRect.left + crossAxisField
          : upperPixels - innerRect.left - crossAxisField;
        crossOffset = innerRect.top + barPadding;
        break;
      case Axis.vertical:
        upperMainZeroOffset = data.inverted
          ? lowerPixels + innerRect.top
          : lowerPixels - innerRect.top;
        lowerMainZeroOffset = data.inverted
          ? upperPixels - innerRect.top
          : upperPixels + innerRect.top;
        crossOffset = innerRect.left + mainAxisField + barPadding;
        break;
    }
    for (var i = 0; i < data.stacks.length; ++i) {
      final domainLabel = domainLabels[i];
      final stack = data.stacks[i];
      final divided = stack.dividedSegments;
      _buildSections(layoutData,
        segments: divided.upper,
        valueAxis: data.valueAxis,
        inverted: data.inverted,
        maxStackSumm: maxStackSumm,
        mainAxisSize: mainAxisSize,
        mainZeroOffset: upperMainZeroOffset,
        crossOffset: crossOffset,
        barThickness: barThickness,
      );
      _buildSections(layoutData,
        segments: divided.lower,
        valueAxis: data.valueAxis,
        inverted: !data.inverted,
        maxStackSumm: maxStackSumm,
        mainAxisSize: mainAxisSize,
        mainZeroOffset: lowerMainZeroOffset,
        crossOffset: crossOffset,
        barThickness: barThickness,
      );
      switch (data.valueAxis) {
        case Axis.horizontal:
          final labelOffset = Offset(
            innerRect.left + crossAxisField - domainLabel.width
              - axisThickness / 2 - crossAxisLabelsOffset,
            crossOffset + (barThickness - domainLabel.height) / 2,
          );
          layoutData.crossLabels.add((labelOffset, domainLabel));
          break;
        case Axis.vertical:
          final labelOffset = Offset(
            crossOffset + (barThickness - domainLabel.width) / 2,
            innerRect.top + mainAxisSize + axisThickness / 2
              + crossAxisLabelsOffset,
          );
          layoutData.crossLabels.add((labelOffset, domainLabel));
          break;
      }
      crossOffset += barSpacing + barThickness;
    }
    return layoutData;
  }

  String _formatMeasure(final double measure)
  {
    return measureFormatter?.call(measure) ?? measure.toStringAsFixed(2);
  }

  static void _buildSections(final _LayoutData layoutData, {
    required final List<(int, BarChartSegment)> segments,
    required final Axis valueAxis,
    required final bool inverted,
    required final double maxStackSumm,
    required final double mainAxisSize,
    required final double mainZeroOffset,
    required final double crossOffset,
    required final double barThickness,
  })
  {
    var mainOffset = mainZeroOffset;
    for (final (_, segment) in segments) {
      final measure = segment.value;
      final sectionLength = measure.abs() / maxStackSumm * mainAxisSize;
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = segment.color
      ;
      switch (valueAxis) {
        case Axis.horizontal:
          final rect = Rect.fromLTWH(
            inverted
              ? mainAxisSize - mainOffset - sectionLength
              : mainOffset,
            crossOffset,
            sectionLength,
            barThickness,
          );
          layoutData.segments.add((
            RRect.fromRectAndCorners(rect,
              topLeft: segment.borderRadius.topLeft,
              bottomLeft: segment.borderRadius.bottomLeft,
              topRight: segment.borderRadius.topRight,
              bottomRight: segment.borderRadius.bottomRight,
            ),
            paint,
          ));
          break;
        case Axis.vertical:
          final rect = Rect.fromLTWH(
            crossOffset,
            inverted
              ? mainOffset
              : mainAxisSize - mainOffset - sectionLength,
            barThickness,
            sectionLength,
          );
          layoutData.segments.add((
            RRect.fromRectAndCorners(rect,
              topLeft: segment.borderRadius.topLeft,
              bottomLeft: segment.borderRadius.bottomLeft,
              topRight: segment.borderRadius.topRight,
              bottomRight: segment.borderRadius.bottomRight,
            ),
            paint,
          ));
          break;
      }
      mainOffset += sectionLength;
    }
  }

  _LayoutData? _layoutData;
}


class _LayoutData
{
  final Rect clipRect;
  final List<(Offset, Offset)> axisLines;
  final List<(Offset, Offset)> guideLines;
  final List<(Offset, ui.Paragraph)> mainLabels;
  final List<(Offset, ui.Paragraph)> crossLabels;
  final List<(RRect, Paint)> segments;

  const _LayoutData({
    required this.clipRect,
    required this.axisLines,
    required this.guideLines,
    required this.mainLabels,
    required this.crossLabels,
    required this.segments,
  });

  factory _LayoutData.empty(final Rect clipRect) => _LayoutData(
    clipRect: clipRect,
    axisLines: [],
    guideLines: [],
    mainLabels: [],
    crossLabels: [],
    segments: [],
  );
}
