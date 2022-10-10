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
    print('Min $bottomHour');
    final double labelInterval =
        (size.height - kXLabelHeight) / (topHour - bottomHour);
    final int hourDuration = topHour - bottomHour;
    print(hourDuration);
    final int timeStep;
    if (hourDuration % 10 == 0 && hourDuration > 48) {
      timeStep = 20;
    } else if (hourDuration >= 48) {
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

    // JS -- changed
    // If dealing with negatives then add a center line for the graph to sit on

    for (int time = topHour; time >= bottomHour; time = time - timeStep) {
      drawYText(canvas, size, '$time $yAxisLabel', posY);
      if (topHour > time && time > bottomHour) {
        drawHorizontalLine(canvas, size, posY);
      }
      posY += labelInterval * timeStep;
    }
  }
}
