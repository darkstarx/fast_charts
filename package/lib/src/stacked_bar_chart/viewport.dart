import 'dart:collection';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../label_position.dart';
import '../ticks_resolver.dart';
import '../types.dart';
import 'stacked_data.dart';


class StackedBarChartViewport extends LeafRenderObjectWidget
{
  final BarChartStacks data;
  final ValueListenable<double>? animation;
  final TicksResolver ticksResolver;
  final MeasureFormatter? measureFormatter;
  final double labelsOffset;
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
  final double? barThickness;
  final EdgeInsets padding;
  final Clip clipBehavior;
  final ViewportOffset viewportOffset;

  const StackedBarChartViewport({
    super.key,
    required this.data,
    this.animation,
    required this.ticksResolver,
    this.measureFormatter,
    this.labelsOffset = 2.0,
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
    this.barThickness,
    this.padding = EdgeInsets.zero,
    this.clipBehavior = Clip.hardEdge,
    required this.viewportOffset,
  });

  @override
  RenderObject createRenderObject(final BuildContext context)
  {
    return StackedBarChartViewportRenderObject(
      data: data,
      animation: animation,
      ticksResolver: ticksResolver,
      measureFormatter: measureFormatter,
      labelsOffset: labelsOffset,
      showZeroValues: showZeroValues,
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
      padding: padding,
      clipBehavior: clipBehavior,
      viewportOffset: viewportOffset,
    );
  }

  @override
  void updateRenderObject(final BuildContext context,
    final StackedBarChartViewportRenderObject renderObject,
  )
  {
    renderObject
      ..data = data
      ..animation = animation
      ..ticksResolver = ticksResolver
      ..measureFormatter = measureFormatter
      ..labelsOffset = labelsOffset
      ..showZeroValues = showZeroValues
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
      ..padding = padding
      ..clipBehavior = clipBehavior
      ..viewportOffset = viewportOffset
    ;
  }
}


class StackedBarChartViewportRenderObject extends RenderBox
{
  BarChartStacks get data => _data;
  set data(final BarChartStacks value)
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

  bool get showZeroValues => _showZeroValues;
  set showZeroValues(final bool value)
  {
    if (_showZeroValues == value) return;
    _showZeroValues = value;
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

  StackedBarChartViewportRenderObject({
    required final BarChartStacks data,
    final ValueListenable<double>? animation,
    required final TicksResolver ticksResolver,
    final MeasureFormatter? measureFormatter,
    final double labelsOffset = 2.0,
    final bool showZeroValues = false,
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
    final EdgeInsets padding = EdgeInsets.zero,
    final Clip clipBehavior = Clip.hardEdge,
    required final ViewportOffset viewportOffset,
  })
  : _data = data
  , _animation = animation
  , _ticksResolver = ticksResolver
  , _measureFormatter = measureFormatter
  , _labelsOffset = labelsOffset
  , _showZeroValues = showZeroValues
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
    _layoutData?.dispose();
    _layoutData = null;
    _stacks?.dispose();
    _stacks = null;
    _oldStacks?.dispose();
    _oldStacks = null;
    super.detach();
  }

  @override
  void performLayout()
  {
    final newSize = constraints.biggest;
    if (!hasSize || size != newSize) {
      _layoutData?.dispose();
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
          stacksNumber: data.stacks.length,
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
    final stacks = _stacks = _getStacks(layoutData);
    final stackLabels = <LayoutLabel>[];
    for (final stack in stacks.values) {
      if (stack.segments.isEmpty) continue;
      stackLabels.addAll(stack.labels);
      final stackRRect = stack.clipRRect.shift(-viewOffset);
      if (barThickness != null
        && !layoutData.scrollAreaClipRect.overlaps(stackRRect.outerRect)
      ) {
        continue;
      }
      final clip = !stackRRect.isRect;
      if (clip) {
        canvas.save();
        canvas.clipRRect(stackRRect);
      }
      for (final entry in stack.segments.entries) {
        final segment = entry.value;
        final (rect, paint) = segment;
        canvas.drawRect(rect.shift(-viewOffset), paint);
      }
      if (clip) {
        canvas.restore();
      }
    }
    if (animation == null) {
      for (final label in stackLabels) {
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
    if (_oldStacks != _stacks) {
      _oldStacks?.dispose();
      _oldStacks = _stacks;
    }
    _layoutData?.dispose();
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
      case Axis.vertical:
        crossAxisField = (crossAxisWidth ?? domainMaxSize.height)
          + axisThickness + crossAxisLabelsOffset;
        mainAxisSize = innerRect.height - crossAxisField;
        crossAxisSize = innerRect.width;
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
    if (layoutData == null) {
      for (final label in mainLabels) {
        final (_, paragraph) = label;
        paragraph.dispose();
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
      stacksNumber: data.stacks.length,
    );

    final double upperMainZeroOffset;
    final double lowerMainZeroOffset;
    final double zeroOnMainAxis;
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
        zeroOnMainAxis = data.inverted
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
        zeroOnMainAxis = data.inverted
          ? upperMainZeroOffset
          : lowerMainZeroOffset;
        scrollAreaClipRect = Offset(innerRect.left + mainAxisField, outerRect.top)
          & Size(innerRect.width - mainAxisField, outerRect.height);
        crossOffset = innerRect.left + mainAxisField + barPadding;
    }
    for (var i = 0; i < data.stacks.length; ++i) {
      final stack = data.stacks[i];
      final domainLabel = layoutMetrics.domainLabels[i];
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
        case Axis.vertical:
          borderRadius = BorderRadius.vertical(
            top: data.inverted ? endRadius : startRadius,
            bottom: data.inverted ? startRadius : endRadius,
          );
      }
      _buildSections(layoutData,
        stackIndex: i,
        segments: upperSegments,
        valueAxis: data.valueAxis,
        inverted: data.inverted,
        dataRange: layoutMetrics.dataRange,
        mainAxisSize: layoutMetrics.mainAxisSize,
        mainZeroOffset: upperMainZeroOffset,
        crossOffset: crossOffset,
        barThickness: barThickness,
        barMargin: barMargin,
        labelsOffset: labelsOffset,
      );
      _buildSections(layoutData,
        stackIndex: i,
        segments: lowerSegments,
        valueAxis: data.valueAxis,
        inverted: !data.inverted,
        dataRange: layoutMetrics.dataRange,
        mainAxisSize: layoutMetrics.mainAxisSize,
        mainZeroOffset: lowerMainZeroOffset,
        crossOffset: crossOffset,
        barThickness: barThickness,
        barMargin: barMargin,
        labelsOffset: labelsOffset,
      );
      final layoutStack = layoutData.stacks[i];
      if (layoutStack != null) {
        layoutData.stacks[i] = layoutStack.withBorderRadius(borderRadius);
      }
      final labelSize = Size(domainLabel.width, domainLabel.height);
      final Offset labelOffset;
      final Rect labelRect;
      switch (data.valueAxis) {
        case Axis.horizontal:
          labelOffset = Offset(
            innerRect.left + crossAxisField - domainLabel.width
              - axisThickness / 2 - crossAxisLabelsOffset,
            crossOffset + (barThickness - domainLabel.height) / 2,
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
            crossOffset + (barThickness - domainLabel.width) / 2,
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
      crossOffset += barSpacing + barThickness;
    }
    return layoutData.copyWith(
      scrollAreaClipRect: scrollAreaClipRect,
      layoutMetrics: layoutMetrics,
      crossAxisOffset: zeroOnMainAxis,
    );
  }

  LayoutStacks _getStacks(final LayoutData layoutData)
  {
    if (animation == null) {
      return LayoutStacks.copy(layoutData.stacks);
    } else {
      final result = LayoutStacks.empty();
      final oldStacks = _oldStacks;
      if (oldStacks != null) {
        for (final entry in oldStacks.entries) {
          if (layoutData.stacks.containsKey(entry.key)) continue;
          final oldStack = entry.value;
          final oldClipRRect = oldStack.clipRRect;
          final oldStackCenter = switch (data.valueAxis) {
            Axis.horizontal => Offset(
              layoutData.crossAxisOffset, oldClipRRect.center.dy,
            ),
            Axis.vertical => Offset(
              oldClipRRect.center.dx, layoutData.crossAxisOffset,
            ),
          };
          final zeroRRect = RRect.fromRectAndCorners(
            Rect.fromCenter(center: oldStackCenter, width: 0, height: 0),
            topLeft: oldClipRRect.tlRadius,
            topRight: oldClipRRect.trRadius,
            bottomLeft: oldClipRRect.blRadius,
            bottomRight: oldClipRRect.brRadius,
          );
          final rrect = RRect.lerp(oldClipRRect, zeroRRect, animation!.value)!;
          final layoutStack = result.putIfAbsent(entry.key,
            () => LayoutStack.empty(),
          );
          Rect? stackRect;
          for (final entry in oldStack.segments.entries) {
            final segment = entry.value;
            final (oldRect, oldPaint) = segment;
            final newRect = Rect.fromCenter(center: oldStackCenter,
              width: 0, height: 0,
            );
            final newColor = oldPaint.color.withAlpha(0);
            final rect = Rect.lerp(oldRect, newRect, animation!.value)!;
            final paint = Paint()
              ..color = Color.lerp(oldPaint.color, newColor, animation!.value)!
              ..style = PaintingStyle.fill
            ;
            if (stackRect == null) {
              stackRect = rect;
            } else {
              stackRect = stackRect.expandToInclude(rect);
            }
            layoutStack.segments[entry.key] = (rect, paint);
          }
          final clipRRect = RRect.fromRectAndCorners(stackRect!,
            topLeft: rrect.tlRadius,
            bottomLeft: rrect.blRadius,
            topRight: rrect.trRadius,
            bottomRight: rrect.brRadius,
          );
          result[entry.key] = layoutStack.withClipRRect(clipRRect);
        }
      }
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
          () => LayoutStack.empty(),
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
              case Axis.vertical:
                oldSegment = (
                  Rect.fromLTRB(
                    dRect.left, layoutData.crossAxisOffset,
                    dRect.right, layoutData.crossAxisOffset,
                  ),
                  newPaint
                );
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
            case Axis.vertical:
              newRect = Rect.fromLTRB(
                dRect.left, layoutData.crossAxisOffset,
                dRect.right, layoutData.crossAxisOffset,
              );
          }
          final rect = Rect.lerp(oldRect, newRect, animation!.value)!;
          if (stackRect == null) {
            stackRect = rect;
          } else {
            stackRect = stackRect.expandToInclude(rect);
          }
          layoutStack.segments[segmentId] = (rect, oldPaint);
        }
        final clipRRect = RRect.fromRectAndCorners(stackRect!,
          topLeft: rrect.tlRadius,
          bottomLeft: rrect.blRadius,
          topRight: rrect.trRadius,
          bottomRight: rrect.brRadius,
        );
        result[stackId] = layoutStack.withClipRRect(clipRRect);
      }
      return result;
    }
  }

  String _formatMeasure(final double measure)
  {
    return measureFormatter?.call(measure) ?? measure.toStringAsFixed(2);
  }

  static void _buildSections(final LayoutData layoutData, {
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
    required final double labelsOffset,
  })
  {
    final stack = layoutData.stacks.putIfAbsent(stackIndex,
      () => LayoutStack.empty(),
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
                if (lblSize <= innerRect.size) {
                  stack.labels.add(LayoutLabel(
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
                stack.labels.add(LayoutLabel(
                  offset: offset,
                  rect: offset & lblSize,
                  paragraph: paragraph,
                ));
            }
          }
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
                if (lblSize <= innerRect.size) {
                  stack.labels.add(LayoutLabel(
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
                stack.labels.add(LayoutLabel(
                  offset: offset,
                  rect: offset & lblSize,
                  paragraph: paragraph,
                ));
            }
          }
      }
      mainOffset += sectionLength;
    }
  }

  LayoutData? _layoutData;
  LayoutStacks? _stacks;
  LayoutStacks? _oldStacks;

  BarChartStacks _data;
  ValueListenable<double>? _animation;
  TicksResolver _ticksResolver;
  MeasureFormatter? _measureFormatter;
  double _labelsOffset;
  bool _showZeroValues;
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
  });

  /// Calculates the bar thickness based on [crossAxisSize].
  double calcBarThickness({
    required final double barPadding,
    required final double barSpacing,
    required final int stacksNumber,
  })
  {
    return max(
      0.0,
      (
        crossAxisSize
        - mainAxisField
        - barPadding * 2
        - (barSpacing * max(stacksNumber - 1, 0))
      ) / stacksNumber,
    );
  }

  /// Calculates `crossAxisSize` based on [barThickness].
  double calcCrossAxisSize({
    required final double barPadding,
    required final double barSpacing,
    required final double barThickness,
    required final int stacksNumber,
  }) => mainAxisField + calcScrollAreaSize(
    barPadding: barPadding,
    barSpacing: barSpacing,
    barThickness: barThickness,
    stacksNumber: stacksNumber,
  );

  void dispose()
  {
    for (final label in domainLabels) {
      label.dispose();
    }
  }

  static double calcScrollAreaSize({
    required final double barPadding,
    required final double barSpacing,
    required final double barThickness,
    required final int stacksNumber,
  }) => barPadding * 2
      + barSpacing * max(stacksNumber - 1, 0)
      + barThickness * stacksNumber;
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
  final LayoutStacks stacks;

  const LayoutData({
    required this.clipRect,
    required this.scrollAreaClipRect,
    required this.crossAxisOffset,
    required this.axisLines,
    required this.guideLines,
    required this.mainLabels,
    required this.crossLabels,
    required this.stacks,
  });

  factory LayoutData.empty(final Rect clipRect) => LayoutData(
    clipRect: clipRect,
    scrollAreaClipRect: Rect.zero,
    crossAxisOffset: 0.0,
    axisLines: [],
    guideLines: [],
    mainLabels: [],
    crossLabels: [],
    stacks: LayoutStacks.empty(),
  );

  void dispose()
  {
    for (final e in mainLabels) {
      final (_, paragraph) = e;
      paragraph.dispose();
    }
    for (final label in crossLabels) {
      label.dispose();
    }
    stacks.dispose();
  }

  /// Returns a copy of this layout data with specified changes.
  ///
  /// Be careful with [mainLabels], [crossLabels] and [stacks]. This method
  /// is not responsible for disposing the old values, so they must be disposed
  /// manually if they are not needed anymore.
  /// Also be careful while disposing a copy of this layout data, internal data
  /// may be disposed twice.
  LayoutData copyWith({
    final Rect? clipRect,
    final Rect? scrollAreaClipRect,
    final LayoutMetrics? layoutMetrics,
    final double? crossAxisOffset,
    final List<(Offset, Offset)>? axisLines,
    final List<(Offset, Offset)>? guideLines,
    final List<(Offset, ui.Paragraph)>? mainLabels,
    final List<LayoutLabel>? crossLabels,
    final LayoutStacks? stacks,
  }) => LayoutData(
    clipRect: clipRect ?? this.clipRect,
    scrollAreaClipRect: scrollAreaClipRect ?? this.scrollAreaClipRect,
    crossAxisOffset: crossAxisOffset ?? this.crossAxisOffset,
    axisLines: axisLines ?? this.axisLines,
    guideLines: guideLines ?? this.guideLines,
    mainLabels: mainLabels ?? this.mainLabels,
    crossLabels: crossLabels ?? this.crossLabels,
    stacks: stacks ?? this.stacks,
  );
}


class LayoutStacks
{
  Iterable<MapEntry<int, LayoutStack>> get entries => _stacks.entries;

  Iterable<LayoutStack> get values => _stacks.values;

  LayoutStacks.empty()
  : _stacks = {}
  , _shouldBeDisposed = true
  ;

  LayoutStacks.copy(final LayoutStacks source)
  : _stacks = source._stacks
  , _shouldBeDisposed = false
  ;

  LayoutStack? operator [](final int key) => _stacks[key];

  void operator []=(final int key, final LayoutStack value)
  {
    _stacks[key] = value;
  }

  bool containsKey(final int key) => _stacks.containsKey(key);

  LayoutStack putIfAbsent(final int key, final LayoutStack Function() ifAbsent)
  {
    return _stacks.putIfAbsent(key, ifAbsent);
  }

  void dispose()
  {
    if (!_shouldBeDisposed) return;
    for (final stack in _stacks.values) {
      stack.dispose();
    }
    _shouldBeDisposed = false;
  }

  bool _shouldBeDisposed;

  final Map<int, LayoutStack> _stacks;
}


class LayoutStack
{
  final Map<int, (Rect, Paint)> segments;
  final List<LayoutLabel> labels;
  final RRect clipRRect;

  factory LayoutStack.empty() => LayoutStack._(
    segments: SplayTreeMap(),
    labels: [],
    clipRRect: RRect.zero,
  );

  LayoutStack withClipRRect(final RRect clipRRect) => LayoutStack._(
    segments: segments,
    labels: labels,
    clipRRect: clipRRect,
  );

  LayoutStack withBorderRadius(final BorderRadius radius)
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
    return LayoutStack._(
      segments: segments,
      labels: labels,
      clipRRect: radius.toRRect(clipRect!),
    );
  }

  void dispose()
  {
    for (final label in labels) {
      label.dispose();
    }
  }

  const LayoutStack._({
    required this.segments,
    required this.labels,
    required this.clipRRect,
  });
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

  void dispose()
  {
    paragraph.dispose();
  }
}
