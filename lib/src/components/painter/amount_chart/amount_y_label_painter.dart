////////////////////////////////////////////////////////////////
/// Blink Chart Package
///
/// AmountYLabelPainter is an extended class from YLabelPainter.
///
/// Draws the incremented labels on the y-axis with the provided labels.
///
/// TODO This class will work fine mostly; however, there are some alignment issues with
/// the X-axis (centered at Y level 0) does not get a YAxis label do to the label increments.
/// (TLDR 0 Might be skipped as a label when negative numbers are present, which visually can be confusing).
///
////////////////////////////////////////////////////////////////

import 'package:flutter/material.dart';
import 'package:time_chart/src/components/painter/y_label_painter.dart';
import '../chart_engine.dart';
import '../../utils/y_label_helper.dart';

class AmountYLabelPainter extends YLabelPainter {
  AmountYLabelPainter({
    required super.xAxisWidth,
    required super.widgetMode,
    required super.context,
    required super.viewMode,
    required super.topHour,
    required super.bottomHour,
    required this.yAxisLabel,
  });

  final String yAxisLabel;

  /// JS
  /// Overrides the parents abstract drawYLabels method and systemically adds labels based on the
  /// value of topHour and the total range (hourDuration) of the list of values passed in.
  @override
  void drawYLabels(Canvas canvas, Size size) {
    final double labelInterval =
        (size.height - kXLabelHeight) / (topHour - bottomHour);

    //JS - for timestepping equation
    int timeStep = YLabelCalculator.timeStep(topHour);

    double posY = 0;
    if (widgetMode == true) {
      // JP -- added this for simplified widgets for simplified widgets
      double posY = 10;
      drawYText(canvas, size, '$topHour', posY);
      drawYText(
          canvas, size, '$bottomHour', posY + (size.height - kXLabelHeight));
    } else {
      for (int time = topHour; time >= bottomHour; time = time - timeStep) {
        drawYText(canvas, size, '$time $yAxisLabel', posY);
        if (topHour > time && time > bottomHour) {
          drawHorizontalLine(canvas, size, posY);
        }
        posY += labelInterval * timeStep;
      }
    }
  }
}
