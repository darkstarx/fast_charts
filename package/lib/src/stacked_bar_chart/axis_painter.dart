// import 'package:flutter/widgets.dart';

// import '../ticks_resolver.dart';
// import '../types.dart';
// import 'stacked_data.dart';


// class BarMainAxisPainter extends CustomPainter
// {
//   final BarChartStacks data;
//   final TicksResolver ticksResolver;
//   final MeasureFormatter? measureFormatter;
//   final TextStyle mainAxisTextStyle;
//   final Color axisColor;
//   final double axisThickness;
//   final Color guideLinesColor;
//   final double guideLinesThickness;
//   final double mainAxisLabelsOffset;
//   final double crossAxisLabelsOffset;
//   final double? mainAxisMaxWidth;
//   final double? crossAxisMaxWidth;
//   final double barPadding;
//   final double barSpacing;

//   BarMainAxisPainter({
//     required this.data,
//     required this.ticksResolver,
//     this.measureFormatter,
//   });

//   @override
//   void paint(final Canvas canvas, final Size size)
//   {
//     // TODO: implement paint
//   }

//   @override
//   bool shouldRepaint(final BarMainAxisPainter oldDelegate)
//   {
//     return data != oldDelegate.data
//       || ticksResolver != oldDelegate.ticksResolver
//       || measureFormatter != oldDelegate.measureFormatter
//       || mainAxisTextStyle != oldDelegate.mainAxisTextStyle
//       || crossAxisTextStyle != oldDelegate.crossAxisTextStyle
//       || axisColor != oldDelegate.axisColor
//       || axisThickness != oldDelegate.axisThickness
//       || guideLinesColor != oldDelegate.guideLinesColor
//       || guideLinesThickness != oldDelegate.guideLinesThickness
//       || mainAxisLabelsOffset != oldDelegate.mainAxisLabelsOffset
//       || crossAxisLabelsOffset != oldDelegate.crossAxisLabelsOffset
//       || mainAxisMaxWidth != oldDelegate.mainAxisMaxWidth
//       || crossAxisMaxWidth != oldDelegate.crossAxisMaxWidth
//       || barPadding != oldDelegate.barPadding
//       || barSpacing != oldDelegate.barSpacing
//     ;
//   }

//   @override
//   bool shouldRebuildSemantics(final BarMainAxisPainter oldDelegate)
//   {
//     return false;
//   }
// }
