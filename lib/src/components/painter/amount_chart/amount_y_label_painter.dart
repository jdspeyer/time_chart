import 'package:flutter/material.dart';
import 'package:time_chart/src/components/painter/y_label_painter.dart';

import '../chart_engine.dart';

class AmountYLabelPainter extends YLabelPainter {
  AmountYLabelPainter(
      {required super.context,
      required super.viewMode,
      required super.topHour,
      required super.bottomHour,
      required this.yAxisLabel});

  final String yAxisLabel;

  @override
  void drawYLabels(Canvas canvas, Size size) {
    final double labelInterval =
        (size.height - kXLabelHeight) / (topHour - bottomHour);
    final int hourDuration = topHour - bottomHour;
    final int timeStep;
    if (hourDuration >= 48) {
      timeStep = 16;
    } else if (hourDuration >= 24) {
      timeStep = 8;
    } else if (hourDuration >= 12) {
      timeStep = 4;
    } else if (hourDuration >= 8) {
      timeStep = 2;
    } else {
      timeStep = 1;
    }

    double posY = 0;

    for (int time = topHour; time >= bottomHour; time = time - timeStep) {
      drawYText(canvas, size, '$time $yAxisLabel', posY);
      if (topHour > time && time > bottomHour) {
        drawHorizontalLine(canvas, size, posY);
      }

      posY += labelInterval * timeStep;
    }
  }
}
