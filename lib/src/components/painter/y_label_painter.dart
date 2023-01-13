////////////////////////////////////////////////////////////////
/// Blink Chart Package
///
/// YLabelPainter is responsible for painting the Y Axis labels on each chart.
///
/// Unlike XLabelPainter both TimeChart and AmountCharts have their own custom implementations
/// for most of the core functionality of the YAxis. This just has some core functionality that
/// is shared between the two graph types.
///////////////////////////////////////////////////////////////////

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:time_chart/src/components/painter/chart_engine.dart';

abstract class YLabelPainter extends ChartEngine {
  YLabelPainter({
    required super.xAxisWidth,
    required super.widgetMode,
    required super.viewMode,
    required super.context,
    required this.topHour,
    required this.bottomHour,
  });

  final int topHour;
  final int bottomHour;

  @override
  @nonVirtual
  void paint(Canvas canvas, Size size) {
    setRightMargin();
    drawYLabels(canvas, size);
  }

  void drawYLabels(Canvas canvas, Size size);

  /// Draw text labels for the Y-axis.
  void drawYText(Canvas canvas, Size size, String text, double y) {
    TextSpan span = TextSpan(
      text: text,
      style: textTheme.bodyText2!.copyWith(color: kTextColor),
    );

    TextPainter tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();

    tp.paint(
      canvas,
      Offset(
        size.width - rightMargin + kYLabelMargin,
        y - textTheme.bodyText2!.fontSize! / 2,
      ),
    );
  }

  /// Draw a horizontal line on the graph
  void drawHorizontalLine(Canvas canvas, Size size, double dy) {
    Paint paint = Paint()
      ..color = kLineColor1
      ..strokeCap = StrokeCap.round
      ..strokeWidth = kLineStrokeWidth;

    canvas.drawLine(Offset(0, dy), Offset(size.width - rightMargin, dy), paint);
  }

  @override
  bool shouldRepaint(covariant YLabelPainter oldDelegate) {
    return oldDelegate.topHour != topHour ||
        oldDelegate.bottomHour != bottomHour;
  }
}
