import 'package:flutter/material.dart';
import 'package:time_chart/src/components/painter/y_label_painter.dart';

import '../chart_engine.dart';

class TimeYLabelPainter extends YLabelPainter {
  static const double _tolerance = 6.0;

  TimeYLabelPainter({
    required super.widgetMode,
    required super.context,
    required super.viewMode,
    required super.topHour,
    required super.bottomHour,
    required this.chartHeight,
    required this.topPosition,
  });

  final double chartHeight;

  /// T
  /// Draw an additional label using how far the top deviates during animation, or this is a value for not drawing.
  /// If it is negative, it is shifted up, and if it is positive, it is shifted downward.
  final double topPosition;

  bool _isVisible(double posY, {bool onTolerance = false}) {
    final actualPosY = posY + topPosition;
    final tolerance = onTolerance ? _tolerance : 0;
    return -tolerance <= actualPosY &&
        actualPosY <= chartHeight - kXLabelHeight + tolerance;
  }

  void _drawLabelAndLine(Canvas canvas, Size size, double posY, int? time) {
    if (_isVisible(posY)) drawHorizontalLine(canvas, size, posY);
    if (_isVisible(posY, onTolerance: true)) {
      drawYText(canvas, size, translations.formatHourOnly(time!), posY);
    }
  }

  @override
  void drawYLabels(Canvas canvas, Size size) {
    final double bottomY = size.height - kXLabelHeight;

    final int hourIncrement = (widgetMode) ? 4 : 2;

    /// T
    /// Draw the time in 2 hour increments from the top.
    final double gabY =
        bottomY / bottomHour.differenceAt(topHour) * hourIncrement;

    /// T
    /// true if all ranges are full and all ranges should be displayed.
    bool sameTopBottomHour = topHour == (bottomHour % 24);
    int time = topHour;
    double posY = 0.0;

    /// T
    /// During animation, the label and line of the upper part are drawn so that they are not empty.
    while (-topPosition <= posY) {
      if ((time -= 2) < 0) time += 24;
      posY -= gabY;
      _drawLabelAndLine(canvas, size, posY, time);
    }
    time = topHour;
    posY = 0.0;

    /// T
    /// Show left label at 2-space intervals.
    while (true) {
      _drawLabelAndLine(canvas, size, posY, time);

      // 맨 아래에 도달한 경우
      if (time == bottomHour % 24) {
        if (sameTopBottomHour) {
          sameTopBottomHour = false;
        } else {
          break;
        }
      }

      time = (time + 2) % 24;
      posY += gabY;
    }

    // 애니메이션시 하단 부분 레이블과 라인이 비지 않도록 그려준다.
    while (posY <= -topPosition + chartHeight) {
      time = (time + 2) % 24;
      posY += gabY;
      _drawLabelAndLine(canvas, size, posY, time);
    }
  }
}

extension on int {
  /// [before]까지의 차이 시간을 반환한다.
  int differenceAt(int before) {
    var ret = this - before;
    return ret + (ret <= 0 ? 24 : 0);
  }
}
