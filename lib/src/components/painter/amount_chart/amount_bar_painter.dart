////////////////////////////////////////////////////////////////
/// Updated 10/10/2022 by Jake Speyer
///
/// Amount Bar Painter (implementation of BarPainter abstract class) interacts with the canvas and draws the bars to
/// graphically represent the data being passed in.
///
/// Only opperates on lists of Doubles. DateTimeRanges are processed
/// by time_bar_painter.dart.
///
/// If the bottomHour (The smallest hour in the list passed in) is negative
/// then the amount chart will shift bar locations to center to display negative
/// values. Otherwise the bars will be displayed in a style typical of average bar charts.
////////////////////////////////////////////////////////////////

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
    required super.useToday,
    super.barColor,
  });

  @override
  void drawBar(Canvas canvas, Size size, List<AmountBarItem> coordinates) {
    final touchyCanvas = TouchyCanvas(context, canvas,
        scrollController: scrollController, scrollDirection: AxisDirection.left);

    /// JS
    /// Paint styling for normal bars (used by all bars if useToday is false)
    final paint = Paint()
      ..color = barColor ?? Theme.of(context).colorScheme.secondary
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    /// JS
    /// Paint styling for first bar (used to indicate to the user that data may fluctuate since data is current)
    final currentDayPaint = Paint()
      ..color = barColor!.withOpacity(0.5)
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    for (int index = 0; index < coordinates.length; index++) {
      /// JS
      /// offsetWithAmount contains the information specific to each bar in the passed in list (coordinates is a list of AmountBarItem).
      final AmountBarItem offsetWithAmount = coordinates[index];

      /// JS
      /// negativeBarHeight is the calculated height of the bar (top coords - bottom coords)
      /// offsetWithAmount.dy - the distance from the top of the bar (top coords).
      /// size.height         - the bottom of the bar (bottom coords).
      final negativeBarHeight = offsetWithAmount.dy - size.height;

      final double left = paddingForAlignedBar + offsetWithAmount.dx;
      final double right = paddingForAlignedBar + offsetWithAmount.dx + barWidth;

      /// JS
      /// top is the coordinate of the top face of the bar. It's value depends on:
      /// Is there a negative number present in the dataList (indicated by a negative bottomHour)?
      /// If no, then the top coordinate of the bar will not change and will be set to the calculated dy value.
      /// If yes, then the bar will be translated to the center of the graph (size.height/2 for possitive values & size.height/2 + negativeBarHeight for negative values).
      final double top = (bottomHour < 0)
          ? (offsetWithAmount.amount < 0)
              ? offsetWithAmount.dy - (size.height / 2 + negativeBarHeight) //negative
              : offsetWithAmount.dy - (size.height / 2)
          : offsetWithAmount.dy;

      /// JS
      /// bottom is the coordinate of the bottom face of the bar. It's value depends on:
      /// Is there a negative number present in the dataList (indicated by a negative bottomHour)?
      /// If no, then the bottom coordinate of the bar will not change and will be set to the bottom of the graph (size.height)
      /// If yes, then the bar will be translated to the center of the graph (size.height/2 for possitive values & size.height/2 + negativeBarHeight for negative values).
      final double bottom = (bottomHour < 0)
          ? (offsetWithAmount.amount < 0)
              ? size.height - (size.height / 2 + negativeBarHeight) //negative
              : size.height - (size.height / 2)
          : size.height;

      /// JS
      /// rRect repressents the bounding faces of the drawn chart bar using the previously calculated values.
      /// The corners of this bar will be rounded differently depending on if the number is negative or positive.
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

      /// JS
      /// Creates a callback for the tooltip with the bounding box of the chart bar.
      callback(_) => tooltipCallback!(
            amount: offsetWithAmount.amount,
            amountDate: DateTime.now().subtract(Duration(days: index)),
            position: scrollController!.position,
            rect: rRect.outerRect,
            barWidth: barWidth,
          );

      /// JS
      /// Checks to see if the painter is on the first day.
      /// If it is on the first day then it will use the first day paint color instead of the regular paint color.
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
  }

  @override
  List<AmountBarItem> generateCoordinates(Size size) {
    final List<AmountBarItem> coordinates = [];
    if (dataList.isEmpty) return [];
    final double intervalOfBars = size.width / dayCount;
    final int length = dataList.length;
    final int viewLimitDay = viewMode.dayCount;
    final dayFromScrollOffset = currentDayFromScrollOffset;
    const int startIndex = 0;

    /// JS
    /// amountSum is used to hold the value of the current passed in double.
    /// overwritten each time the for loop executes.
    double amountSum = 0;

    /// JP
    /// amountSum is used to hold the value of the current passed in double.
    /// overwritten each time the for loop executes.
    bool widgetMode;

    /// JS
    /// fakeBottomHour is used to avoid the complexities brought on by handling negative numbers.
    /// fakeBottomHour is constantly 0. This fixes issues such as subtracting away negative values in
    /// the normalizedTop equation.
    const fakeBottomHour = 0;

    for (int index = startIndex; index < length; index++) {
      final int barPosition = 1 + index;

      if (barPosition - dayFromScrollOffset > viewLimitDay + ChartEngine.toleranceDay * 2) break;

      /// JS
      /// Changed to override amountSum instead of add to it.
      /// Caused issues with negative numbers being added to the total and removing amounts.
      amountSum = dataList[index];
      // amountSum += dataList[index];

      /// JS
      /// possitveSum is the always possitive version of amountSum. Used in handling negative values
      /// in the normalizedTop equation.
      double possitiveSum = amountSum.abs();

      if (index == length - 1 || dataList[index] >= 0 || dataList[index] <= 0) {
        /// JS
        /// normalizedTop is the percentage of the chart.height that one particular bar should take up (1.0 indicates 100% height).
        /// in the case of negative values we divide the sum in half to get a bar that is half the height since the bars will be placed in the center.
        final double normalizedTop = (bottomHour < 0)
            ? max(0, (possitiveSum / 2 - fakeBottomHour)) / (topHour - fakeBottomHour)
            : max(0, possitiveSum - bottomHour) / (topHour - bottomHour);

        /// JS
        /// dy and dx represent the distances away from the top and sides of the chart each bar will be.
        final double dy = (size.height - normalizedTop * size.height);
        final double dx = size.width - intervalOfBars * barPosition;

        coordinates.add(AmountBarItem(dx, dy, amountSum, dataList[index]));

        amountSum = 0;
      }
    }

    return coordinates;
  }
}

/// JS
/// AmountBarItem contains information associated with each bar in the chart
/// dx - distance the bar is from the side of the chart.
/// dy - distance the top of the bar is from the top of the chart (the smaller this number is the bigger the amount should be). 0 would mean the bar fills 100% of the graph height.
/// amount - the actual numeric data the bar is representing (used for display in the tool tip and for calculations).
/// dateTime - the time/ date of the bar.
class AmountBarItem {
  final double dx;
  final double dy;
  final double amount;
  final double dateTime;
  // final bool widgetMode;

  AmountBarItem(this.dx, this.dy, this.amount, this.dateTime);
}
