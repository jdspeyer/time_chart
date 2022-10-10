import 'dart:math';

import 'package:flutter/material.dart';
import 'package:time_chart/src/components/painter/bar_painter.dart';
import 'package:touchable/touchable.dart';
import '../../utils/time_assistant.dart';
import '../chart_engine.dart';
import '../y_label_painter.dart';

class AmountBarPainter extends BarPainter<AmountBarItem> {
  AmountBarPainter({
    required super.scrollController,
    required super.repaint,
    super.tooltipCallback,
    required super.context,
    required super.dataList,
    required super.topHour,
    required super.bottomHour,
    required super.dayCount,
    required super.viewMode,

    /// JS -- Changed
    /// Passed through to here to check if the final bar
    /// style should be changed.
    required super.useToday,
    super.barColor,
  });

  @override
  void drawBar(Canvas canvas, Size size, List<AmountBarItem> coordinates) {
    final touchyCanvas = TouchyCanvas(context, canvas,
        scrollController: scrollController,
        scrollDirection: AxisDirection.left);
    final paint = Paint()
      ..color = barColor ?? Theme.of(context).colorScheme.secondary
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    /// JS -- Changed
    /// this is a different paint style used if the "use current day" parameter is passed.
    /// It colors the last bar (current day) to indicate to the use that the data is fluctuating.
    final currentDayPaint = Paint()
      ..color = barColor!.withOpacity(0.5)
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    for (int index = 0; index < coordinates.length; index++) {
      final AmountBarItem offsetWithAmount = coordinates[index];
      final negativeBarHeight = offsetWithAmount.dy - size.height;

      final double left = paddingForAlignedBar + offsetWithAmount.dx;
      final double right =
          paddingForAlignedBar + offsetWithAmount.dx + barWidth;
      final double top = (bottomHour < 0)
          ? (offsetWithAmount.amount < 0)
              ? offsetWithAmount.dy -
                  (size.height / 2 + negativeBarHeight) //negative
              : offsetWithAmount.dy - (size.height / 2)
          : offsetWithAmount.dy;
      final double bottom = (bottomHour < 0)
          ? (offsetWithAmount.amount < 0)
              ? size.height - (size.height / 2 + negativeBarHeight) //negative
              : size.height - (size.height / 2)
          : size.height;

      final rRect = (offsetWithAmount.amount > 0)
          ? RRect.fromRectAndCorners(
              Rect.fromLTRB(left, top, right, bottom),
              topLeft: barRadius,
              topRight: barRadius,
            )
          : RRect.fromRectAndCorners(
              Rect.fromLTRB(left, top, right, bottom),
              bottomLeft: barRadius,
              bottomRight: barRadius,
            );

      callback(_) => tooltipCallback!(
            amount: offsetWithAmount.amount,
            // JP -- Changed
            amountDate: DateTime.now().subtract(Duration(days: index)),
            position: scrollController!.position,
            rect: rRect.outerRect,
            barWidth: barWidth,
          );

      /// JS -- Changed
      /// Checks to see if the painter is on the first day.
      /// If it is on the first day then it will use the first day paint color instead of the
      /// regular paint color.
      if (index == 0 && useToday) {
        touchyCanvas.drawRRect(
          rRect,
          currentDayPaint,
          onTapUp: callback,
          onLongPressStart: callback,
          onLongPressMoveUpdate: callback,
        );
      } else {
        touchyCanvas.drawRRect(
          rRect,
          paint,
          onTapUp: callback,
          onLongPressStart: callback,
          onLongPressMoveUpdate: callback,
        );
      }
    }
    // if(bottomHour > 0) {
    //  _drawBrokeBarLine(canvas, size);
    // }
  }

  @override
  List<AmountBarItem> generateCoordinates(Size size) {
    final List<AmountBarItem> coordinates = [];
    if (dataList.isEmpty) return [];

    final double intervalOfBars = size.width / dayCount;
    final int length = dataList.length;
    final int viewLimitDay = viewMode.dayCount;
    final dayFromScrollOffset = currentDayFromScrollOffset;
    // JP -- Changed
    // final double startDateTime = dataList[0];
    // final DateTime startDateTime = getBarRenderStartDateTime(dataList);
    // print("startDateTime: $startDateTime");
    // JP -- Changed
    const int startIndex = 0;
    // final int startIndex = dataList.getLowerBound(startDateTime);
    // print("startIndex: $startIndex");

    double amountSum = 0;
    double fakeBottomHour = 0;

    for (int index = startIndex; index < length; index++) {
      // JP -- Changed
      final int barPosition = 1 + index;
      // final int barPosition = 1 + dataList.first.end.differenceDateInDay(dataList[index].end);

      if (barPosition - dayFromScrollOffset >
          viewLimitDay + ChartEngine.toleranceDay * 2) break;

      // JP -- Changed
      amountSum = dataList[index];
      double possitiveSum = amountSum.abs();

      // amountSum += dataList[index].durationInHours;
      print("amountSum: $amountSum");

      // JP -- Changed
      if (index == length - 1 || dataList[index] >= 0 || dataList[index] <= 0) {
        // if (index == length - 1 ||
        //     dataList[index].end.differenceDateInDayBar(dataList[index + 1].end) > 0) {

        /// JS -- Changed
        /// checks to see if there is a negative value as the lowest number.
        /// If there is, it will take the abs of the amount sum.
        final double normalizedTop = (bottomHour < 0)
            ? max(0, (possitiveSum / 2 - fakeBottomHour)) /
                (topHour - fakeBottomHour)
            : max(0, possitiveSum - bottomHour) / (topHour - bottomHour);
        print(normalizedTop);
        //final double dy = size.height - normalizedTop * size.height;
        final double dy = (size.height - normalizedTop * size.height);
        print('Distance - $dy');
        final double dx = size.width - intervalOfBars * barPosition;
        // JP -- Changed
        coordinates.add(AmountBarItem(dx, dy, amountSum, dataList[index]));
        // coordinates.add(AmountBarItem(dx, dy, amountSum, dataList[index].end));

        amountSum = 0;
      } else if (index == length - 1 || dataList[index] <= 0) {}
    }

    return coordinates;
  }
}

class AmountBarItem {
  final double dx;
  final double dy;
  final double amount;
  // JP -- Changed
  final double dateTime;
  // final DateTime dateTime;

  AmountBarItem(this.dx, this.dy, this.amount, this.dateTime);
}
