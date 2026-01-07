import 'dart:collection';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../label_position.dart';
import '../ticks_resolver.dart';
import '../types.dart';
import 'bar_data.dart';


class GroupedBarChartViewport extends LeafRenderObjectWidget
{
  final ChartBars data;
  final ValueListenable<double>? animation;
  final TicksResolver ticksResolver;
  final MeasureFormatter? measureFormatter;
  final double labelsOffset;
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
  final double? barThickness;
  final double groupSpacing;
  final EdgeInsets padding;
  final Clip clipBehavior;
  final ViewportOffset viewportOffset;

  const GroupedBarChartViewport({
    super.key,
    required this.data,
    this.animation,
    required this.ticksResolver,
    this.measureFormatter,
    this.labelsOffset = 2.0,
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
    this.barThickness,
    this.groupSpacing = 0.0,
    this.padding = EdgeInsets.zero,
    this.clipBehavior = Clip.hardEdge,
    required this.viewportOffset,
  });

  @override
  RenderObject createRenderObject(final BuildContext context)
  {
    return GroupedBarChartViewportRenderObject(
      data: data,
      animation: animation,
      ticksResolver: ticksResolver,
      measureFormatter: measureFormatter,
      labelsOffset: labelsOffset,
      mainAxisTextStyle: mainAxisTextStyle,
      crossAxisTextStyle: crossAxisTextStyle,
      axisColor: axisColor,
      axisThickness: axisThickness,
      guideLinesColor: guideLinesColor,
      guideLinesThickness: guideLinesThickness,
      mainAxisLabelsOffset: mainAxisLabelsOffset,
      crossAxisLabelsOffset: crossAxisLabelsOffset,
      mainAxisWidth: mainAxisWidth,
      crossAxisWidth: crossAxisWidth,
      showMainAxisLine: showMainAxisLine,
      showCrossAxisLine: showCrossAxisLine,
      barPadding: barPadding,
      barSpacing: barSpacing,
      barThickness: barThickness,
      groupSpacing: groupSpacing,
      padding: padding,
      clipBehavior: clipBehavior,
      viewportOffset: viewportOffset,
    );
  }

  @override
  void updateRenderObject(final BuildContext context,
    final GroupedBarChartViewportRenderObject renderObject,
  )
  {
    renderObject
      ..data = data
      ..animation = animation
      ..ticksResolver = ticksResolver
      ..measureFormatter = measureFormatter
      ..labelsOffset = labelsOffset
      ..mainAxisTextStyle = mainAxisTextStyle
      ..crossAxisTextStyle = crossAxisTextStyle
      ..axisColor = axisColor
      ..axisThickness = axisThickness
      ..guideLinesColor = guideLinesColor
      ..guideLinesThickness = guideLinesThickness
      ..mainAxisLabelsOffset = mainAxisLabelsOffset
      ..crossAxisLabelsOffset = crossAxisLabelsOffset
      ..mainAxisWidth = mainAxisWidth
      ..crossAxisWidth = crossAxisWidth
      ..showMainAxisLine = showMainAxisLine
      ..showCrossAxisLine = showCrossAxisLine
      ..barPadding = barPadding
      ..barSpacing = barSpacing
      ..barThickness = barThickness
      ..groupSpacing = groupSpacing
      ..padding = padding
      ..clipBehavior = clipBehavior
      ..viewportOffset = viewportOffset
    ;
  }
}


class GroupedBarChartViewportRenderObject extends RenderBox
{
  ChartBars get data => _data;
  set data(final ChartBars value)
  {
    if (_data == value) return;
    _data = value;
    markNeedsRebuild();
  }

  ValueListenable<double>? get animation => _animation;
  set animation(final ValueListenable<double>? value)
  {
    if (_animation == value) return;
    if (attached) {
      _animation?.removeListener(markNeedsPaint);
    }
    _animation = value;
    if (attached) {
      _animation?.addListener(markNeedsPaint);
    }
    markNeedsPaint();
  }

  TicksResolver get ticksResolver => _ticksResolver;
  set ticksResolver(final TicksResolver value)
  {
    if (_ticksResolver == value) return;
    _ticksResolver = value;
    markNeedsRebuild();
  }

  MeasureFormatter? get measureFormatter => _measureFormatter;
  set measureFormatter(final MeasureFormatter? value)
  {
    if (_measureFormatter == value) return;
    _measureFormatter = value;
    markNeedsRebuild();
  }

  double get labelsOffset => _labelsOffset;
  set labelsOffset(final double value)
  {
    if (_labelsOffset == value) return;
    _labelsOffset = value;
    markNeedsRebuild();
  }

  TextStyle get mainAxisTextStyle => _mainAxisTextStyle;
  set mainAxisTextStyle(final TextStyle value)
  {
    if (_mainAxisTextStyle == value) return;
    _mainAxisTextStyle = value;
    markNeedsRebuild();
  }

  TextStyle get crossAxisTextStyle => _crossAxisTextStyle;
  set crossAxisTextStyle(final TextStyle value)
  {
    if (_crossAxisTextStyle == value) return;
    _crossAxisTextStyle = value;
    markNeedsRebuild();
  }

  Color get axisColor => _axisColor;
  set axisColor(final Color value)
  {
    if (_axisColor == value) return;
    _axisColor = value;
    markNeedsPaint();
  }

  double get axisThickness => _axisThickness;
  set axisThickness(final double value)
  {
    if (_axisThickness == value) return;
    _axisThickness = value;
    markNeedsRebuild();
  }

  Color get guideLinesColor => _guideLinesColor;
  set guideLinesColor(final Color value)
  {
    if (_guideLinesColor == value) return;
    _guideLinesColor = value;
    markNeedsPaint();
  }

  double get guideLinesThickness => _guideLinesThickness;
  set guideLinesThickness(final double value)
  {
    if (_guideLinesThickness == value) return;
    _guideLinesThickness = value;
    markNeedsPaint();
  }

  double get mainAxisLabelsOffset => _mainAxisLabelsOffset;
  set mainAxisLabelsOffset(final double value)
  {
    if (_mainAxisLabelsOffset == value) return;
    _mainAxisLabelsOffset = value;
    markNeedsRebuild();
  }

  double get crossAxisLabelsOffset => _crossAxisLabelsOffset;
  set crossAxisLabelsOffset(final double value)
  {
    if (_crossAxisLabelsOffset == value) return;
    _crossAxisLabelsOffset = value;
    markNeedsRebuild();
  }

  double? get mainAxisWidth => _mainAxisWidth;
  set mainAxisWidth(final double? value)
  {
    if (_mainAxisWidth == value) return;
    _mainAxisWidth = value;
    markNeedsRebuild();
  }

  double? get crossAxisWidth => _crossAxisWidth;
  set crossAxisWidth(final double? value)
  {
    if (_crossAxisWidth == value) return;
    _crossAxisWidth = value;
    markNeedsRebuild();
  }

  bool get showMainAxisLine => _showMainAxisLine;
  set showMainAxisLine(final bool value)
  {
    if (_showMainAxisLine == value) return;
    _showMainAxisLine = value;
    markNeedsRebuild();
  }

  bool get showCrossAxisLine => _showCrossAxisLine;
  set showCrossAxisLine(final bool value)
  {
    if (_showCrossAxisLine == value) return;
    _showCrossAxisLine = value;
    markNeedsRebuild();
  }

  double get barPadding => _barPadding;
  set barPadding(final double value)
  {
    if (_barPadding == value) return;
    _barPadding = value;
    markNeedsRebuild();
  }

  double get barSpacing => _barSpacing;
  set barSpacing(final double value)
  {
    if (_barSpacing == value) return;
    _barSpacing = value;
    markNeedsRebuild();
  }

  double? get barThickness => _barThickness;
  set barThickness(final double? value)
  {
    if (_barThickness == value) return;
    _barThickness = value;
    markNeedsRebuild();
  }

  double get groupSpacing => _groupSpacing;
  set groupSpacing(final double value)
  {
    if (_groupSpacing == value) return;
    _groupSpacing = value;
    markNeedsRebuild();
  }

  EdgeInsets get padding => _padding;
  set padding(final EdgeInsets value)
  {
    if (_padding == value) return;
    _padding = value;
    markNeedsRebuild();
  }

  Clip get clipBehavior => _clipBehavior;
  set clipBehavior(final Clip value)
  {
    if (_clipBehavior == value) return;
    _clipBehavior = value;
    markNeedsPaint();
  }

  ViewportOffset get viewportOffset => _viewportOffset;
  set viewportOffset(final ViewportOffset value)
  {
    if (_viewportOffset == value) return;
    if (attached) {
      _viewportOffset.removeListener(markNeedsPaint);
    }
    _viewportOffset = value;
    if (attached) {
      _viewportOffset.addListener(markNeedsPaint);
    }
    markNeedsLayout();
  }

  @override
  bool get isRepaintBoundary => true;

  GroupedBarChartViewportRenderObject({
    required final ChartBars data,
    final ValueListenable<double>? animation,
    required final TicksResolver ticksResolver,
    final MeasureFormatter? measureFormatter,
    final double labelsOffset = 2.0,
    required final TextStyle mainAxisTextStyle,
    required final TextStyle crossAxisTextStyle,
    required final Color axisColor,
    final double axisThickness = 1.0,
    required final Color guideLinesColor,
    final double guideLinesThickness = 1.0,
    final double mainAxisLabelsOffset = 2.0,
    final double crossAxisLabelsOffset = 2.0,
    final double? mainAxisWidth,
    final double? crossAxisWidth,
    final bool showMainAxisLine = false,
    final bool showCrossAxisLine = true,
    final double barPadding = 0.0,
    final double barSpacing = 0.0,
    final double? barThickness,
    final double groupSpacing = 0.0,
    final EdgeInsets padding = EdgeInsets.zero,
    final Clip clipBehavior = Clip.hardEdge,
    required final ViewportOffset viewportOffset,
  })
  : _data = data
  , _animation = animation
  , _ticksResolver = ticksResolver
  , _measureFormatter = measureFormatter
  , _labelsOffset = labelsOffset
  , _mainAxisTextStyle = mainAxisTextStyle
  , _crossAxisTextStyle = crossAxisTextStyle
  , _axisColor = axisColor
  , _axisThickness = axisThickness
  , _guideLinesColor = guideLinesColor
  , _guideLinesThickness = guideLinesThickness
  , _mainAxisLabelsOffset = mainAxisLabelsOffset
  , _crossAxisLabelsOffset = crossAxisLabelsOffset
  , _mainAxisWidth = mainAxisWidth
  , _crossAxisWidth = crossAxisWidth
  , _showMainAxisLine = showMainAxisLine
  , _showCrossAxisLine = showCrossAxisLine
  , _barPadding = barPadding
  , _barSpacing = barSpacing
  , _barThickness = barThickness
  , _groupSpacing = groupSpacing
  , _padding = padding
  , _clipBehavior = clipBehavior
  , _viewportOffset = viewportOffset
  ;

  @override
  void attach(final PipelineOwner owner)
  {
    super.attach(owner);
    _viewportOffset.addListener(markNeedsPaint);
    _animation?.addListener(markNeedsPaint);
  }

  @override
  void detach()
  {
    _viewportOffset.removeListener(markNeedsPaint);
    _animation?.removeListener(markNeedsPaint);
    super.detach();
  }

  @override
  double computeMinIntrinsicWidth(final double height)
  {
    return constraints.maxWidth;
  }

  @override
  double computeMaxIntrinsicWidth(final double height)
  {
    return constraints.maxWidth;
  }

  @override
  double computeMinIntrinsicHeight(final double width)
  {
    return constraints.maxHeight;
  }

  @override
  double computeMaxIntrinsicHeight(final double width)
  {
    return constraints.maxHeight;
  }

  @override
  void performLayout()
  {
    final newSize = constraints.biggest;
    if (!hasSize || size != newSize) {
      _layoutData = null;
      size = newSize;
    }
    _layoutData ??= _buildLayout();
    final scrollAreaClipRect = _layoutData!.scrollAreaClipRect;
    final viewportDimension = switch (data.valueAxis) {
      Axis.horizontal => scrollAreaClipRect.height,
      Axis.vertical => scrollAreaClipRect.width,
    };
    final contentDimension = barThickness == null
      ? viewportDimension
      : LayoutMetrics.calcScrollAreaSize(
          barPadding: barPadding,
          barSpacing: barSpacing,
          barThickness: barThickness!,
          groupSpacing: groupSpacing,
          groups: data.groups,
        );
    const minScrollExtent = 0.0;
    final maxScrollExtent = max(
      contentDimension - viewportDimension,
      minScrollExtent,
    );
    if (viewportOffset.hasPixels) {
      if (viewportOffset.pixels > maxScrollExtent) {
        viewportOffset.correctBy(maxScrollExtent - viewportOffset.pixels);
      } else if (viewportOffset.pixels < minScrollExtent) {
        viewportOffset.correctBy(minScrollExtent - viewportOffset.pixels);
      }
    }
    viewportOffset.applyViewportDimension(viewportDimension);
    viewportOffset.applyContentDimensions(minScrollExtent, maxScrollExtent);
  }

  @override
  void paint(final PaintingContext context, final Offset offset)
  {
    assert(() {
      if (_layoutData == null) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary('layoutData is null during painting.'),
          ErrorHint(
            'This is an internal error. Please fill the issue if you see this '
            'error.',
          ),
        ]);
      }
      return true;
    }());
    final layoutData = _layoutData ??= _buildLayout();
    final axisPaint = Paint()
      ..color = axisColor
      ..strokeWidth = axisThickness
    ;
    final guideLinesPaint = Paint()
      ..color = guideLinesColor
      ..strokeWidth = guideLinesThickness
    ;
    final canvas = context.canvas;
    final viewOffset = switch (data.valueAxis) {
      Axis.horizontal => Offset(0.0, viewportOffset.pixels),
      Axis.vertical => Offset(viewportOffset.pixels, 0.0),
    };

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
    canvas.clipRect(layoutData.scrollAreaClipRect);
    for (final label in layoutData.crossLabels) {
      if (barThickness != null) {
        final labelRect = label.rect.shift(-viewOffset);
        if (!layoutData.scrollAreaClipRect.overlaps(labelRect)) {
          continue;
        }
      }
      canvas.drawParagraph(label.paragraph, label.offset - viewOffset);
    }
    final barGroups = _barGroups = _getBars(layoutData);
    final barGroupLabels = <LayoutLabel>[];
    for (final barGroup in barGroups.values) {
      if (barGroup.bars.isEmpty) continue;
      for (final bar in barGroup.bars.values) {
        final label = bar.label;
        if (label != null) {
          barGroupLabels.add(label);
        }
        final barRRect = bar.rect.shift(-viewOffset);
        if (barThickness != null
          && !layoutData.scrollAreaClipRect.overlaps(barRRect.outerRect)
        ) {
          continue;
        }
        canvas.drawRRect(barRRect, bar.paint);
      }
    }
    if (animation == null) {
      for (final label in barGroupLabels) {
        final offset = label.offset - viewOffset;
        if (barThickness != null) {
          final rect = label.rect.shift(-viewOffset);
          if (!layoutData.scrollAreaClipRect.overlaps(rect)) continue;
        }
        canvas.drawParagraph(label.paragraph, offset);
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

  void markNeedsRebuild()
  {
    _oldBarGroups = _barGroups;
    _layoutData = null;
    markNeedsLayout();
  }

  /// Calculates layout metrics based on the [size] of the widget.
  ///
  /// Optionally fills in the [layoutData] with `axisLines`, `guideLines` and
  /// `mainLabels`.
  LayoutMetrics calcLayoutMetrics(final Size size, {
    final LayoutData? layoutData,
  })
  {
    final outerRect = Offset.zero & size;
    final innerRect = padding.deflateRect(outerRect);

    final double mainLabelWidth;
    final double crossLabelWidth;
    final TextAlign domainTextAlign;
    switch (data.valueAxis) {
      case Axis.horizontal:
        mainLabelWidth = innerRect.width / 2;
        crossLabelWidth = crossAxisWidth ?? innerRect.width / 2;
        domainTextAlign = TextAlign.right;
      case Axis.vertical:
        mainLabelWidth = mainAxisWidth ?? innerRect.width / 2;
        crossLabelWidth = innerRect.width / 2;
        domainTextAlign = TextAlign.center;
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
      case Axis.vertical:
        crossAxisField = (crossAxisWidth ?? domainMaxSize.height)
          + axisThickness + crossAxisLabelsOffset;
        mainAxisSize = innerRect.height - crossAxisField;
        crossAxisSize = innerRect.width;
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

    final double mainAxisField;
    switch (data.valueAxis) {
      case Axis.horizontal:
        mainAxisField = (mainAxisWidth ?? measureMaxSize.height)
          + axisThickness + mainAxisLabelsOffset;
        final mainAxisOffset = innerRect.top + crossAxisSize - mainAxisField
          + axisThickness / 2;
        if (showMainAxisLine) {
          layoutData?.axisLines.add((
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
            layoutData?.axisLines.add(line);
          } else {
            layoutData?.guideLines.add(line);
          }
          layoutData?.mainLabels.add((
            Offset(
              labelOnMainAxis - paragraph.longestLine / 2,
              mainAxisOffset + axisThickness / 2 + mainAxisLabelsOffset
            ),
            paragraph
          ));
        }
      case Axis.vertical:
        mainAxisField = (mainAxisWidth ?? measureMaxSize.width)
          + axisThickness + mainAxisLabelsOffset;
        final mainAxisOffset = innerRect.left + mainAxisField
          - axisThickness / 2;
        if (showMainAxisLine) {
          layoutData?.axisLines.add((
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
            layoutData?.axisLines.add(line);
          } else {
            layoutData?.guideLines.add(line);
          }
          layoutData?.mainLabels.add((
            Offset(
              mainAxisOffset - paragraph.longestLine - axisThickness / 2
                - mainAxisLabelsOffset,
              labelOnMainAxis - paragraph.height / 2,
            ),
            paragraph,
          ));
        }
    }

    return LayoutMetrics(
      innerRect: innerRect,
      mainAxisSize: mainAxisSize,
      mainAxisField: mainAxisField,
      crossAxisField: crossAxisField,
      crossAxisSize: crossAxisSize,
      lowerPixels: lowerPixels,
      upperPixels: upperPixels,
      dataRange: dataRange,
      domainLabels: domainLabels,
    );
  }

  LayoutData _buildLayout()
  {
    final outerRect = Offset.zero & size;
    final layoutData = LayoutData.empty(outerRect);
    final layoutMetrics = calcLayoutMetrics(size, layoutData: layoutData);

    final innerRect = layoutMetrics.innerRect;
    final lowerPixels = layoutMetrics.lowerPixels;
    final upperPixels = layoutMetrics.upperPixels;
    final mainAxisField = layoutMetrics.mainAxisField;
    final crossAxisField = layoutMetrics.crossAxisField;

    final barThickness = this.barThickness ?? layoutMetrics.calcBarThickness(
      barPadding: barPadding,
      barSpacing: barSpacing,
      groupSpacing: groupSpacing,
      groups: data.groups,
    );

    final double upperMainZeroOffset;
    final double lowerMainZeroOffset;
    final double crossAxisOffset;
    final Rect scrollAreaClipRect;
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
        scrollAreaClipRect = Offset(outerRect.left, innerRect.top)
          & Size(outerRect.width, innerRect.height - mainAxisField);
        crossOffset = innerRect.top + barPadding;
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
        scrollAreaClipRect = Offset(innerRect.left + mainAxisField, outerRect.top)
          & Size(innerRect.width - mainAxisField, outerRect.height);
        crossOffset = innerRect.left + mainAxisField + barPadding;
    }
    for (var i = 0; i < data.groups.length; ++i) {
      final group = data.groups[i];
      final domainLabel = layoutMetrics.domainLabels[i];

      final groupThickness = barThickness * group.bars.length
        + barSpacing * (group.bars.length - 1);
      final groupMargin = (
        start: i == 0 ? barPadding : groupSpacing / 2,
        end: i == data.groups.length - 1 ? barPadding : groupSpacing / 2,
      );
      _buildBarGroups(layoutData,
        groupIndex: i,
        bars: group.bars,
        valueAxis: data.valueAxis,
        inverted: data.inverted,
        dataRange: layoutMetrics.dataRange,
        mainAxisSize: layoutMetrics.mainAxisSize,
        crossAxisOffset: crossAxisOffset,
        crossOffset: crossOffset,
        barThickness: barThickness,
        barSpacing: barSpacing,
        groupMargin: groupMargin,
        labelsOffset: labelsOffset,
      );

      final labelSize = Size(domainLabel.width, domainLabel.height);
      final Offset labelOffset;
      final Rect labelRect;
      switch (data.valueAxis) {
        case Axis.horizontal:
          labelOffset = Offset(
            innerRect.left + crossAxisField - domainLabel.width
              - axisThickness / 2 - crossAxisLabelsOffset,
            crossOffset + (groupThickness - domainLabel.height) / 2,
          );
          final rect = labelOffset & labelSize;
          labelRect = Rect.fromLTRB(
            rect.right - domainLabel.longestLine,
            rect.top,
            rect.right,
            rect.bottom,
          );
        case Axis.vertical:
          labelOffset = Offset(
            crossOffset + (groupThickness - domainLabel.width) / 2,
            innerRect.top + layoutMetrics.mainAxisSize + axisThickness / 2
              + crossAxisLabelsOffset,
          );
          final rect = labelOffset & labelSize;
          labelRect = Rect.fromCenter(
            center: rect.center,
            width: domainLabel.longestLine,
            height: rect.height,
          );
      }
      layoutData.crossLabels.add(LayoutLabel(
        offset: labelOffset,
        rect: labelRect,
        paragraph: domainLabel,
      ));
      crossOffset += groupSpacing
        + barThickness * group.bars.length
        + barSpacing * (group.bars.length - 1);
    }
    return layoutData.copyWith(
      crossAxisOffset: crossAxisOffset,
      scrollAreaClipRect: scrollAreaClipRect,
    );
  }

  Map<int, LayoutBarGroup> _getBars(final LayoutData layoutData)
  {
    if (animation == null) {
      return layoutData.barGroups;
    } else {
      final result = <int, LayoutBarGroup>{};
      final oldBarGroups = _oldBarGroups;
      if (oldBarGroups != null) {
        for (final entry in oldBarGroups.entries) {
          if (layoutData.barGroups.containsKey(entry.key)) continue;
          final group = entry.value;
          final layoutBarGroup = result.putIfAbsent(entry.key,
            () => LayoutBarGroup.empty(),
          );
          for (final entry in group.bars.entries) {
            final oldBar = entry.value;
            final oldBarCenter = switch (data.valueAxis) {
              Axis.horizontal => Offset(
                layoutData.crossAxisOffset, oldBar.rect.center.dy,
              ),
              Axis.vertical => Offset(
                oldBar.rect.center.dx, layoutData.crossAxisOffset,
              ),
            };
            final newBarRect = RRect.fromRectAndCorners(
              Rect.fromCenter(center: oldBarCenter, width: 0, height: 0),
              topLeft: oldBar.rect.tlRadius,
              topRight: oldBar.rect.trRadius,
              bottomLeft: oldBar.rect.blRadius,
              bottomRight: oldBar.rect.brRadius,
            );
            final newColor = oldBar.paint.color.withAlpha(0);
            final rect = RRect.lerp(oldBar.rect, newBarRect, animation!.value)!;
            final paint = Paint()
              ..color = Color.lerp(oldBar.paint.color, newColor, animation!.value)!
              ..style = PaintingStyle.fill
            ;
            layoutBarGroup.bars[entry.key] = LayoutBar(rect: rect, paint: paint);
          }
          result[entry.key] = LayoutBarGroup(
            bars: layoutBarGroup.bars,
          );
        }
      }
      for (final entry in layoutData.barGroups.entries) {
        final groupId = entry.key;
        final group = entry.value;
        final oldGroup = _oldBarGroups?[groupId];
        final oldBars = oldGroup?.bars ?? {};
        final anyOldBar = oldBars.isEmpty
          ? null
          : oldBars.values.first;
        final layoutBarGroup = result.putIfAbsent(groupId,
          () => LayoutBarGroup.empty(),
        );
        for (final entry in group.bars.entries) {
          final barId = entry.key;
          final bar = entry.value;
          final (newRect, newPaint) = (bar.rect, bar.paint);
          var oldBar = oldBars[barId];
          if (oldBar == null) {
            final dRect = (anyOldBar ?? bar).rect;
            switch (data.valueAxis) {
              case Axis.horizontal:
                oldBar = LayoutBar(
                  rect: RRect.fromLTRBAndCorners(
                    layoutData.crossAxisOffset, dRect.top,
                    layoutData.crossAxisOffset, dRect.bottom,
                    topLeft: dRect.tlRadius,
                    topRight: dRect.trRadius,
                    bottomLeft: dRect.blRadius,
                    bottomRight: dRect.brRadius,
                  ),
                  paint: newPaint,
                );
              case Axis.vertical:
                oldBar = LayoutBar(
                  rect: RRect.fromLTRBAndCorners(
                    dRect.left, layoutData.crossAxisOffset,
                    dRect.right, layoutData.crossAxisOffset,
                    topLeft: dRect.tlRadius,
                    topRight: dRect.trRadius,
                    bottomLeft: dRect.blRadius,
                    bottomRight: dRect.brRadius,
                  ),
                  paint: newPaint,
                );
            }
          }
          final (oldRect, oldPaint) = (oldBar.rect, oldBar.paint);
          final rect = RRect.lerp(oldRect, newRect, animation!.value)!;
          final paint = Paint()
            ..color = Color.lerp(oldPaint.color, newPaint.color,
                animation!.value
              )!
            ..style = PaintingStyle.fill
          ;
          layoutBarGroup.bars[barId] = LayoutBar(rect: rect, paint: paint);
        }
        final anyNewBar = group.bars.isEmpty
          ? null
          : group.bars.values.first;
        for (final entry in oldBars.entries.where(
          (e) => !group.bars.containsKey(e.key)
        )) {
          final barId = entry.key;
          final oldBar = entry.value;
          final (oldRect, oldPaint) = (oldBar.rect, oldBar.paint);
          final dRect = (anyNewBar ?? oldBar).rect;
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
            case Axis.vertical:
              newRect = RRect.fromLTRBAndCorners(
                dRect.left, layoutData.crossAxisOffset,
                dRect.right, layoutData.crossAxisOffset,
                topLeft: dRect.tlRadius,
                topRight: dRect.trRadius,
                bottomLeft: dRect.blRadius,
                bottomRight: dRect.brRadius,
              );
          }
          final rect = RRect.lerp(oldRect, newRect, animation!.value)!;
          layoutBarGroup.bars[barId] = LayoutBar(rect: rect, paint: oldPaint);
        }
        result[groupId] = LayoutBarGroup(
          bars: layoutBarGroup.bars,
        );
      }
      return result;
    }
  }

  String _formatMeasure(final double measure)
  {
    return measureFormatter?.call(measure) ?? measure.toStringAsFixed(2);
  }

  static void _buildBarGroups(final LayoutData layoutData, {
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
    required final double labelsOffset,
  })
  {
    final group = layoutData.barGroups.putIfAbsent(groupIndex,
      () => LayoutBarGroup.empty(),
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
          var layoutBar = LayoutBar(
            rect: RRect.fromRectAndCorners(innerRect,
              topRight: invert ? Radius.zero : bar.radius,
              bottomRight: invert ? Radius.zero : bar.radius,
              topLeft: invert ? bar.radius : Radius.zero,
              bottomLeft: invert ? bar.radius : Radius.zero,
            ),
            paint: paint,
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
                if (lblSize <= innerRect.size) {
                  layoutBar = layoutBar.withLabel(LayoutLabel(
                    offset: lblOffset.topLeft,
                    rect: lblOffset,
                    paragraph: paragraph,
                  ));
                }
              case LabelPosition.outside:
                final offset = Offset(
                  inverted
                    ? innerRect.left - lblSize.width - labelsOffset
                    : innerRect.right + labelsOffset,
                  lblOffset.top,
                );
                layoutBar = layoutBar.withLabel(LayoutLabel(
                  offset: offset,
                  rect: offset & lblSize,
                  paragraph: paragraph,
                ));
            }
          }
          group.bars[index] = layoutBar;
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
          var layoutBar = LayoutBar(
            rect: RRect.fromRectAndCorners(innerRect,
              topLeft: invert ? Radius.zero : bar.radius,
              topRight: invert ? Radius.zero : bar.radius,
              bottomLeft: invert ? bar.radius : Radius.zero,
              bottomRight: invert ? bar.radius : Radius.zero,
            ),
            paint: paint,
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
                if (lblSize <= innerRect.size) {
                  layoutBar = layoutBar.withLabel(LayoutLabel(
                    offset: lblOffset.topLeft,
                    rect: lblOffset,
                    paragraph: paragraph,
                  ));
                }
              case LabelPosition.outside:
                final offset = Offset(
                  lblOffset.left,
                  inverted
                    ? outerRect.bottom + labelsOffset
                    : outerRect.top - lblSize.height - labelsOffset,
                );
                layoutBar = layoutBar.withLabel(LayoutLabel(
                  offset: offset,
                  rect: offset & lblSize,
                  paragraph: paragraph,
                ));
            }
          }
          group.bars[index] = layoutBar;
      }
      offset += barThickness + barSpacing;
    }
  }

  LayoutData? _layoutData;
  Map<int, LayoutBarGroup>? _barGroups;
  Map<int, LayoutBarGroup>? _oldBarGroups;

  ChartBars _data;
  ValueListenable<double>? _animation;
  TicksResolver _ticksResolver;
  MeasureFormatter? _measureFormatter;
  double _labelsOffset;
  TextStyle _mainAxisTextStyle;
  TextStyle _crossAxisTextStyle;
  Color _axisColor;
  double _axisThickness;
  Color _guideLinesColor;
  double _guideLinesThickness;
  double _mainAxisLabelsOffset;
  double _crossAxisLabelsOffset;
  double? _mainAxisWidth;
  double? _crossAxisWidth;
  bool _showMainAxisLine;
  bool _showCrossAxisLine;
  double _barPadding;
  double _barSpacing;
  double? _barThickness;
  double _groupSpacing;
  EdgeInsets _padding;
  Clip _clipBehavior;
  ViewportOffset _viewportOffset;
}


class LayoutMetrics
{
  final Rect innerRect;
  final double mainAxisSize;
  final double mainAxisField;
  final double crossAxisSize;
  final double crossAxisField;
  final double lowerPixels;
  final double upperPixels;
  final double dataRange;
  final List<ui.Paragraph> domainLabels;
  // final List<BarsGroup> groups;

  const LayoutMetrics({
    required this.innerRect,
    required this.mainAxisSize,
    required this.mainAxisField,
    required this.crossAxisField,
    required this.crossAxisSize,
    required this.lowerPixels,
    required this.upperPixels,
    required this.dataRange,
    required this.domainLabels,
    // required this.groups,
  });

  /// Calculates the bar thickness based on [crossAxisSize].
  double calcBarThickness({
    required final double barPadding,
    required final double barSpacing,
    required final double groupSpacing,
    required final List<BarsGroup> groups,
  })
  {
    return max(
      0.0,
      (
        crossAxisSize
        - mainAxisField
        - barPadding * 2
        - groups.fold(0.0, (s, g) => s + barSpacing * max(g.bars.length - 1, 0))
        - (groupSpacing * (groups.length - 1))
      ) / groups.fold(0, (s, g) => s + g.bars.length),
    );
  }

  /// Calculates `crossAxisSize` based on [barThickness].
  double calcCrossAxisSize({
    required final double barPadding,
    required final double barSpacing,
    required final double barThickness,
    required final double groupSpacing,
    required final List<BarsGroup> groups,
  }) => mainAxisField + calcScrollAreaSize(
    barPadding: barPadding,
    barSpacing: barSpacing,
    barThickness: barThickness,
    groupSpacing: groupSpacing,
    groups: groups,
  );

  static double calcScrollAreaSize({
    required final double barPadding,
    required final double barSpacing,
    required final double barThickness,
    required final double groupSpacing,
    required final List<BarsGroup> groups,
  }) => barPadding * 2
      + groups.fold(0.0, (s, g) => s + barSpacing * max(g.bars.length - 1, 0))
      + (groupSpacing * (groups.length - 1))
      + barThickness * groups.fold(0, (s, g) => s + g.bars.length);

}


class LayoutData
{
  final Rect clipRect;
  final Rect scrollAreaClipRect;
  final double crossAxisOffset;
  final List<(Offset, Offset)> axisLines;
  final List<(Offset, Offset)> guideLines;
  final List<(Offset, ui.Paragraph)> mainLabels;
  final List<LayoutLabel> crossLabels;
  final Map<int, LayoutBarGroup> barGroups;

  const LayoutData({
    required this.clipRect,
    required this.scrollAreaClipRect,
    required this.crossAxisOffset,
    required this.axisLines,
    required this.guideLines,
    required this.mainLabels,
    required this.crossLabels,
    required this.barGroups,
  });

  factory LayoutData.empty(final Rect clipRect) => LayoutData(
    clipRect: clipRect,
    scrollAreaClipRect: Rect.zero,
    crossAxisOffset: 0.0,
    axisLines: [],
    guideLines: [],
    mainLabels: [],
    crossLabels: [],
    barGroups: {},
  );

  LayoutData copyWith({
    final Rect? clipRect,
    final Rect? scrollAreaClipRect,
    final double? crossAxisOffset,
    final List<(Offset, Offset)>? axisLines,
    final List<(Offset, Offset)>? guideLines,
    final List<(Offset, ui.Paragraph)>? mainLabels,
    final List<LayoutLabel>? crossLabels,
    final Map<int, LayoutBarGroup>? barGroups,
  }) => LayoutData(
    clipRect: clipRect ?? this.clipRect,
    scrollAreaClipRect: scrollAreaClipRect ?? this.scrollAreaClipRect,
    crossAxisOffset: crossAxisOffset ?? this.crossAxisOffset,
    axisLines: axisLines ?? this.axisLines,
    guideLines: guideLines ?? this.guideLines,
    mainLabels: mainLabels ?? this.mainLabels,
    crossLabels: crossLabels ?? this.crossLabels,
    barGroups: barGroups ?? this.barGroups,
  );
}


class LayoutBarGroup
{
  final Map<int, LayoutBar> bars;

  const LayoutBarGroup({
    required this.bars,
  });

  factory LayoutBarGroup.empty() => LayoutBarGroup(
    bars: SplayTreeMap(),
  );
}


class LayoutBar
{
  final RRect rect;
  final Paint paint;
  final LayoutLabel? label;

  const LayoutBar({
    required this.rect,
    required this.paint,
    this.label,
  });

  LayoutBar withLabel(final LayoutLabel label) => LayoutBar(
    rect: rect, paint: paint, label: label,
  );
}


class LayoutLabel
{
  final Offset offset;
  final Rect rect;
  final ui.Paragraph paragraph;

  const LayoutLabel({
    required this.offset,
    required this.rect,
    required this.paragraph,
  });
}
