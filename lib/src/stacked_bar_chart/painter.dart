import 'dart:collection';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../label_position.dart';
import '../ticks_resolver.dart';
import '../types.dart';
import 'stacked_data.dart';


class BarPainter extends CustomPainter
{
  final BarChartStacks data;
  final ValueListenable<double>? animation;
  final TicksResolver ticksResolver;
  final MeasureFormatter? measureFormatter;
  final bool showZeroValues;
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
  final EdgeInsets padding;
  final Clip clipBehavior;

  BarPainter({
    required this.data,
    this.animation,
    required this.ticksResolver,
    this.measureFormatter,
    this.showZeroValues = false,
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
    this.padding = EdgeInsets.zero,
    this.clipBehavior = Clip.hardEdge,
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
    final segments = _stacks = _getStacks(layoutData);
    for (final entry in segments.entries) {
      final stack = entry.value;
      final clip = !stack.clipRRect.isRect;
      if (stack.segments.isEmpty) continue;
      if (clip) {
        canvas.save();
        canvas.clipRRect(stack.clipRRect);
      }
      for (final entry in stack.segments.entries) {
        final segment = entry.value;
        final (rect, paint) = segment;
        canvas.drawRect(rect, paint);
      }
      if (clip) {
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
  bool shouldRepaint(final BarPainter oldDelegate)
  {
    final needRebuild = data != oldDelegate.data
      || ticksResolver != oldDelegate.ticksResolver
      || measureFormatter != oldDelegate.measureFormatter
      || showZeroValues != oldDelegate.showZeroValues
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
    if (needRebuild) {
      _oldStacks = oldDelegate._stacks;
      _layoutData = null;
    } else {
      _layoutData = oldDelegate._layoutData;
      _lastSize = oldDelegate._lastSize;
    }
    return needRebuild
      || clipBehavior != oldDelegate.clipBehavior;
  }

  @override
  bool shouldRebuildSemantics(final BarPainter oldDelegate)
  {
    return false;
  }

  Map<int, _LayoutStack> _getStacks(final _LayoutData layoutData)
  {
    if (animation == null) {
      return layoutData.stacks;
    } else {
      final result = <int, _LayoutStack>{};
      for (final entry in layoutData.stacks.entries) {
        final stackId = entry.key;
        final stack = entry.value;
        final oldStack = _oldStacks?[stackId];
        final oldSegments = oldStack?.segments ?? {};
        final anyOldSegment = oldSegments.isEmpty
          ? null
          : oldSegments.values.first;
        final rrect = oldStack == null
          ? stack.clipRRect
          : RRect.lerp(oldStack.clipRRect, stack.clipRRect, animation!.value)!;
        final layoutStack = result.putIfAbsent(stackId,
          () => _LayoutStack.empty(),
        );
        Rect? stackRect;
        for (final entry in stack.segments.entries) {
          final segmentId = entry.key;
          final segment = entry.value;
          final (newRect, newPaint) = segment;
          var oldSegment = oldSegments[segmentId];
          if (oldSegment == null) {
            final (dRect, _) = anyOldSegment ?? segment;
            switch (data.valueAxis) {
              case Axis.horizontal:
                oldSegment = (
                  Rect.fromLTRB(
                    layoutData.crossAxisOffset, dRect.top,
                    layoutData.crossAxisOffset, dRect.bottom,
                  ),
                  newPaint
                );
                break;
              case Axis.vertical:
                oldSegment = (
                  Rect.fromLTRB(
                    dRect.left, layoutData.crossAxisOffset,
                    dRect.right, layoutData.crossAxisOffset,
                  ),
                  newPaint
                );
                break;
            }
          }
          final (oldRect, oldPaint) = oldSegment;
          final rect = Rect.lerp(oldRect, newRect, animation!.value)!;
          final paint = Paint()
            ..color = Color.lerp(oldPaint.color, newPaint.color,
                animation!.value
              )!
            ..style = PaintingStyle.fill
          ;
          if (stackRect == null) {
            stackRect = rect;
          } else {
            stackRect = stackRect.expandToInclude(rect);
          }
          layoutStack.segments[segmentId] = (rect, paint);
        }
        final anyNewSegment = stack.segments.isEmpty
          ? null
          : stack.segments.values.first;
        for (final entry in oldSegments.entries.where(
          (e) => !stack.segments.containsKey(e.key)
        )) {
          final segmentId = entry.key;
          final oldSegment = entry.value;
          final (oldRect, oldPaint) = oldSegment;
          final (dRect, _) = anyNewSegment ?? oldSegment;
          final Rect newRect;
          switch (data.valueAxis) {
            case Axis.horizontal:
              newRect = Rect.fromLTRB(
                layoutData.crossAxisOffset, dRect.top,
                layoutData.crossAxisOffset, dRect.bottom,
              );
              break;
            case Axis.vertical:
              newRect = Rect.fromLTRB(
                dRect.left, layoutData.crossAxisOffset,
                dRect.right, layoutData.crossAxisOffset,
              );
              break;
          }
          final rect = Rect.lerp(oldRect, newRect, animation!.value)!;
          if (stackRect == null) {
            stackRect = rect;
          } else {
            stackRect = stackRect.expandToInclude(rect);
          }
          layoutStack.segments[segmentId] = (rect, oldPaint);
        }
        result[stackId] = _LayoutStack(
          segments: layoutStack.segments,
          clipRRect: RRect.fromRectAndCorners(stackRect!,
            topLeft: rrect.tlRadius,
            bottomLeft: rrect.blRadius,
            topRight: rrect.trRadius,
            bottomRight: rrect.brRadius,
          )
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
    var dataExtremes = data.stacks
      .map((e) => e.summs)
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
        - (barSpacing * (data.stacks.length - 1))
      ) / data.stacks.length,
    );

    final double upperMainZeroOffset;
    final double lowerMainZeroOffset;
    final double zeroOnMainAxis;
    double crossOffset;
    switch (data.valueAxis) {
      case Axis.horizontal:
        upperMainZeroOffset = data.inverted
          ? lowerPixels - innerRect.left - crossAxisField
          : lowerPixels + innerRect.left + crossAxisField;
        lowerMainZeroOffset = data.inverted
          ? upperPixels + innerRect.left + crossAxisField
          : upperPixels - innerRect.left - crossAxisField;
        zeroOnMainAxis = data.inverted
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
        zeroOnMainAxis = data.inverted
          ? upperMainZeroOffset
          : lowerMainZeroOffset;
        crossOffset = innerRect.left + mainAxisField + barPadding;
        break;
    }
    for (var i = 0; i < data.stacks.length; ++i) {
      final stack = data.stacks[i];
      final domainLabel = domainLabels[i];
      final List<(int, BarChartSegment)> lowerSegments, upperSegments;
      if (showZeroValues) {
        final divided = stack.dividedSegments;
        lowerSegments = divided.lower;
        upperSegments = divided.zero.followedBy(divided.upper).toList();
      } else {
        final divided = stack.dividedSegments;
        lowerSegments = divided.lower;
        upperSegments = divided.upper;
      }
      final barMargin = (
        start: i == 0 ? barPadding : barSpacing / 2,
        end: i == data.stacks.length - 1 ? barPadding : barSpacing / 2,
      );
      final startRadius = upperSegments.isEmpty
        ? Radius.zero
        : stack.radius;
      final endRadius = lowerSegments.isEmpty
        ? Radius.zero
        : stack.radius;
      final BorderRadius borderRadius;
      switch (data.valueAxis) {
        case Axis.horizontal:
          borderRadius = BorderRadius.horizontal(
            left: data.inverted ? startRadius : endRadius,
            right: data.inverted ? endRadius : startRadius,
          );
          break;
        case Axis.vertical:
          borderRadius = BorderRadius.vertical(
            top: data.inverted ? endRadius : startRadius,
            bottom: data.inverted ? startRadius : endRadius,
          );
          break;
      }
      _buildSections(layoutData,
        stackIndex: i,
        segments: upperSegments,
        valueAxis: data.valueAxis,
        inverted: data.inverted,
        dataRange: dataRange,
        mainAxisSize: mainAxisSize,
        mainZeroOffset: upperMainZeroOffset,
        crossOffset: crossOffset,
        barThickness: barThickness,
        barMargin: barMargin,
      );
      _buildSections(layoutData,
        stackIndex: i,
        segments: lowerSegments,
        valueAxis: data.valueAxis,
        inverted: !data.inverted,
        dataRange: dataRange,
        mainAxisSize: mainAxisSize,
        mainZeroOffset: lowerMainZeroOffset,
        crossOffset: crossOffset,
        barThickness: barThickness,
        barMargin: barMargin,
      );
      final layoutStack = layoutData.stacks[i];
      if (layoutStack != null) {
        layoutData.stacks[i] = layoutStack.withBorderRadius(borderRadius);
      }
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
    return layoutData.copyWith(crossAxisOffset: zeroOnMainAxis);
  }

  String _formatMeasure(final double measure)
  {
    return measureFormatter?.call(measure) ?? measure.toStringAsFixed(2);
  }

  static void _buildSections(final _LayoutData layoutData, {
    required final int stackIndex,
    required final List<(int, BarChartSegment)> segments,
    required final Axis valueAxis,
    required final bool inverted,
    required final double dataRange,
    required final double mainAxisSize,
    required final double mainZeroOffset,
    required final double crossOffset,
    required final double barThickness,
    required final ({ double start, double end}) barMargin,
  })
  {
    final stack = layoutData.stacks.putIfAbsent(stackIndex,
      () => _LayoutStack.empty(),
    );
    var mainOffset = mainZeroOffset;
    segments.sort((a, b) => a.$1.compareTo(b.$1));
    for (final (index, segment) in segments) {
      final measure = segment.value;
      final label = segment.label;
      final sectionLength = measure.abs() / dataRange * mainAxisSize;
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = segment.color
      ;
      switch (valueAxis) {
        case Axis.horizontal:
          final innerRect = Rect.fromLTWH(
            inverted
              ? mainAxisSize - mainOffset - sectionLength
              : mainOffset,
            crossOffset,
            sectionLength,
            barThickness,
          );
          stack.segments[index] = (innerRect, paint);
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
                layoutData.labels.add((lblOffset.topLeft, paragraph));
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
            crossOffset,
            inverted
              ? mainOffset
              : mainAxisSize - mainOffset - sectionLength,
            barThickness,
            sectionLength,
          );
          final rectPadding = EdgeInsets.only(
            left: barMargin.start,
            right: barMargin.end,
          );
          final outerRect = rectPadding.inflateRect(innerRect);
          stack.segments[index] = (innerRect, paint);
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
                if (lblSize.height <= innerRect.height) {
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
      mainOffset += sectionLength;
    }
  }

  _LayoutData? _layoutData;
  Size? _lastSize;
  Map<int, _LayoutStack>? _stacks;
  Map<int, _LayoutStack>? _oldStacks;
}


class _LayoutData
{
  final Rect clipRect;
  final double crossAxisOffset;
  final List<(Offset, Offset)> axisLines;
  final List<(Offset, Offset)> guideLines;
  final List<(Offset, ui.Paragraph)> mainLabels;
  final List<(Offset, ui.Paragraph)> crossLabels;
  final Map<int, _LayoutStack> stacks;
  final List<(Offset, ui.Paragraph)> labels;

  const _LayoutData({
    required this.clipRect,
    required this.crossAxisOffset,
    required this.axisLines,
    required this.guideLines,
    required this.mainLabels,
    required this.crossLabels,
    required this.stacks,
    required this.labels,
  });

  factory _LayoutData.empty(final Rect clipRect) => _LayoutData(
    clipRect: clipRect,
    crossAxisOffset: 0.0,
    axisLines: [],
    guideLines: [],
    mainLabels: [],
    crossLabels: [],
    stacks: {},
    labels: [],
  );

  _LayoutData copyWith({
    final Rect? clipRect,
    final double? crossAxisOffset,
    final List<(Offset, Offset)>? axisLines,
    final List<(Offset, Offset)>? guideLines,
    final List<(Offset, ui.Paragraph)>? mainLabels,
    final List<(Offset, ui.Paragraph)>? crossLabels,
    final Map<int, _LayoutStack>? stacks,
    final List<(Offset, ui.Paragraph)>? labels,
  }) => _LayoutData(
    clipRect: clipRect ?? this.clipRect,
    crossAxisOffset: crossAxisOffset ?? this.crossAxisOffset,
    axisLines: axisLines ?? this.axisLines,
    guideLines: guideLines ?? this.guideLines,
    mainLabels: mainLabels ?? this.mainLabels,
    crossLabels: crossLabels ?? this.crossLabels,
    stacks: stacks ?? this.stacks,
    labels: labels ?? this.labels,
  );
}


class _LayoutStack
{
  final Map<int, (Rect, Paint)> segments;
  final RRect clipRRect;

  const _LayoutStack({
    required this.segments,
    required this.clipRRect,
  });

  factory _LayoutStack.empty() => _LayoutStack(
    segments: SplayTreeMap(),
    clipRRect: RRect.zero,
  );

  _LayoutStack withBorderRadius(final BorderRadius radius)
  {
    if (segments.isEmpty) return this;
    Rect? clipRect;
    for (final segment in segments.values) {
      final (rect, _) = segment;
      if (clipRect == null) {
        clipRect = rect;
      } else {
        clipRect = clipRect.expandToInclude(rect);
      }
    }
    assert(clipRect != null);
    return _LayoutStack(
      segments: segments,
      clipRRect: radius.toRRect(clipRect!),
    );
  }
}
