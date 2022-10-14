////////////////////////////////////////////////////////////////
/// Updated 10/10/2022 by Jake Speyer
///
/// AmountYLabelPainter is an extended class from YLabelPainter.
///
/// Draws the incremented labels on the y-axis with the provided labels.
///
/// NEEDS TO BE REWRITTEN  FOR MORE ACCURATE PLACEMENT WHEN GIVEN NEGATIVE NUMBERS.
////////////////////////////////////////////////////////////////

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

  /// JS
  /// Overrides the parents abstract drawYLabels method and systemically adds labels based on the
  /// value of topHour and the total range (hourDuration) of the list of values passed in.
  @override
  void drawYLabels(Canvas canvas, Size size) {
    final double labelInterval =
        (size.height - kXLabelHeight) / (topHour - bottomHour);
    final int hourDuration = topHour - bottomHour;
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

    for (int time = topHour; time >= bottomHour; time = time - timeStep) {
      drawYText(canvas, size, '$time $yAxisLabel', posY);
      if (topHour > time && time > bottomHour) {
        drawHorizontalLine(canvas, size, posY);
      }
      posY += labelInterval * timeStep;
    }
  }
}
