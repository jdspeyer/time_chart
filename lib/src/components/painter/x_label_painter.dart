////////////////////////////////////////////////////////////////
/// Blink Chart Package
///
/// XLabelPainter is responsible for painting the X Axis labels on each chart.
///
/// While Amount Chart and Time Chart have their own implementations of this abstract class,
/// they do not add any additional functionality. All code for X-Axis Labels is found here.
///////////////////////////////////////////////////////////////////

import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:time_chart/src/components/painter/chart_engine.dart';
import 'package:time_chart/src/components/translations/translations.dart';
import 'package:time_chart/src/components/view_mode.dart';
import '../utils/x_label_helper.dart';

abstract class XLabelPainter extends ChartEngine {
  static const int toleranceDay = 1;

  XLabelPainter(
      {required super.viewMode,
      required super.context,
      this.isFirstDataMovedNextDay = false,
      required super.dayCount,
      required super.firstValueDateTime,
      required super.repaint,
      required super.scrollController,
      required super.widgetMode,
      required super.xAxisWidth //xAxisWidth contains the originally defined width by the user (passed by width parameter)
      });

  final bool isFirstDataMovedNextDay;

  @override
  void paint(Canvas canvas, Size size) {
    setDefaultValue(size);
    drawXLabels(canvas, size, isFirstDataMovedNextDay: isFirstDataMovedNextDay);
  }

  /// Draw horizontal labels.
  ///
  /// [isFirstDataMovedNextDay] sets vertical dividers and x labels every exactly 7 days when in monthly chart mode
  /// Value for drawing.
  void drawXLabels(
    Canvas canvas,
    Size size, {
    bool isFirstDataMovedNextDay = false,
  }) {
    final weekday = (widgetMode)
        ? getShortWeekdayList(context)
        : getSingleWeekdayList(context);
    final viewModeLimitDay = viewMode.dayCount;
    final dayFromScrollOffset = currentDayFromScrollOffset - toleranceDay;

    DateTime currentDate =
        firstValueDateTime!.add(Duration(days: -dayFromScrollOffset));

    void moveToYesterday() {
      currentDate = currentDate.add(const Duration(days: -1));
    }

    for (int i = dayFromScrollOffset;
        i <= dayFromScrollOffset + viewModeLimitDay + toleranceDay * 2;
        i++) {
      late String text;
      bool isDashed = true;

      switch (viewMode) {
        case ViewMode.hourly:
          text = currentDate.hour.toString();
          moveToYesterday();
          if (i % 4 == (isFirstDataMovedNextDay ? 0 : 3)) {
            final dx = size.width - (i + 1) * blockWidth!;
            // Quick & Dirty implementation for the hourly labels. Will be refactored.
            // TODO Refactor
            if (xAxisWidth >= 500) {
              _drawXText(
                  canvas,
                  size,
                  (i % 24) < 11
                      ? "${(11 - (i % 24))}PM"
                      : (i % 24) == 11
                          ? "Noon"
                          : (i % 24) == 23
                              ? "Midnight"
                              : "${(23 - (i % 24))} AM",
                  dx);
            } else {
              _drawXText(
                  canvas,
                  size,
                  (i % 24) < 11
                      ? "${(11 - (i % 24))}"
                      : (i % 24) == 11
                          ? "12PM"
                          : (i % 24) == 23
                              ? "12AM"
                              : "${(23 - (i % 24))}",
                  dx);
            }

            if (!widgetMode) {
              // JP -- added this for simplified widgets for simplified widgets
              _drawVerticalDivideLine(canvas, size, dx, isDashed);
            }
          }
          break;
        case ViewMode.weekly:
          text = widgetMode
              ? weekday[currentDate.weekday % 7][0]
              : weekday[currentDate.weekday %
                  7]; // JP -- added this for simplified widgets for simplified widgets
          if (currentDate.weekday == DateTime.sunday) isDashed = false;
          moveToYesterday();
          final dx = size.width - (i + 1) * blockWidth!;
          _drawXText(canvas, size, text, dx);
          // if (!widgetMode) {
          //   // JP -- added this for simplified widgets for simplified widgets
          //   _drawVerticalDivideLine(canvas, size, dx, isDashed);
          // }
          break;
        case ViewMode.monthly:
          text = currentDate.day.toString();
          moveToYesterday();
          // Monthly view mode displays the label once every 7 days.
          if (i % 7 == (isFirstDataMovedNextDay ? 0 : 6)) {
            final dx = size.width - (i + 1) * blockWidth!;
            _drawXText(canvas, size, text, dx);
            if (!widgetMode) {
              // JP -- added this for simplified widgets for simplified widgets
              _drawVerticalDivideLine(canvas, size, dx, isDashed);
            }
          }
          break;
        case ViewMode.sixMonth:
          text = currentDate.day.toString();
          moveToYesterday();
          // Monthly view mode displays the label once every 7 days.
          if (i % 4 == (isFirstDataMovedNextDay ? 0 : 3)) {
            final dx = size.width - (i + 1) * blockWidth!;
            _drawXText(canvas, size, text, dx);
            if (!widgetMode) {
              // JP -- added this for simplified widgets for simplified widgets
              _drawVerticalDivideLine(canvas, size, dx, isDashed);
            }
          }
          break;
        case ViewMode.year:
          text = currentDate.day.toString();
          moveToYesterday();
          // Monthly view mode displays the label once every 7 days.
          final dx = size.width - (i + 1) * blockWidth!;
          _drawXText(canvas, size, text, dx);
          if (!widgetMode) {
            // JP -- added this for simplified widgets for simplified widgets
            _drawVerticalDivideLine(canvas, size, dx, isDashed);
          }
          break;
      }

      // final dx = size.width - (i + 1) * blockWidth!;

      // _drawXText(canvas, size, text, dx);
      // _drawVerticalDivideLine(canvas, size, dx, isDashed);
    }
  }

  void _drawXText(Canvas canvas, Size size, String text, double dx) {
    TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: textTheme.bodyText2!.copyWith(color: kTextColor),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();

    final dy = size.height - textPainter.height;
    textPainter.paint(canvas, Offset(dx + paddingForAlignedBar, dy));
  }

  /// Draws a dividing line.
  void _drawVerticalDivideLine(
    Canvas canvas,
    Size size,
    double dx,
    bool isDashed,
  ) {
    Paint paint = Paint()
      ..color = kLineColor3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0;

    Path path = Path();
    path.moveTo(dx, 0);
    path.lineTo(dx, size.height);

    canvas.drawPath(
      isDashed
          ? dashPath(path,
              dashArray: CircularIntervalList<double>(<double>[2, 2]))
          : path,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant XLabelPainter oldDelegate) {
    return true;
  }
}
