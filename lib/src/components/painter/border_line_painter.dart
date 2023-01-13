////////////////////////////////////////////////////////////////
/// Blink Chart Package
///
/// BorderLinePainter paints the axis borders and interrior borders.
/// It is disabled for Widget Modes to provide a cleaner feel.
///////////////////////////////////////////////////////////////////

import 'package:flutter/material.dart';
import 'chart_engine.dart';

class BorderLinePainter extends CustomPainter {
  BorderLinePainter({required this.widgetMode});
  bool
      widgetMode; // JP -- added this for simplified widgets for simplified widgets

  @override
  void paint(Canvas canvas, Size size) {
    Paint topPaint = Paint()
      ..color = kLineColor1
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = kLineStrokeWidth;
    Paint leftPaint = Paint()
      ..color = kLineColor2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = kLineStrokeWidth / 2;
    Paint bottomPaint = Paint()
      ..color = kLineColor2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = kLineStrokeWidth;

    final maxHeight = size.height - kXLabelHeight;
    if (widgetMode == false) {
      // JP -- added this for simplified widgets for simplified widgets
      canvas.drawLine(
          const Offset(0.0, 0.0), Offset(size.width, 0.0), topPaint);
      canvas.drawLine(
          const Offset(0.0, 0.0), Offset(0.0, maxHeight), leftPaint);
      canvas.drawLine(
          Offset(0.0, maxHeight), Offset(size.width, maxHeight), bottomPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
