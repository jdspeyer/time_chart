////////////////////////////////////////////////////////////////
/// Blink Chart Package
///
/// ToolTipOverlay is the core class for the tooltip which is displayed
/// when the user clicks on a bar on the graph (functionality is disabled in widget mode).
///////////////////////////////////////////////////////////////////
import 'package:flutter/material.dart';

import '../../../time_chart.dart';
import 'tooltip_shape_border.dart';
import 'tooltip_size.dart';
import '../translations/translations.dart';

const double kTooltipArrowWidth = 8.0;
const double kTooltipArrowHeight = 16.0;

enum Direction { left, right }

@immutable
class TooltipOverlay extends StatelessWidget {
  const TooltipOverlay({
    Key? key,
    required this.chartType,
    required this.yAxisLabel,
    required this.toolTipLabel,
    required this.isDateTime,
    required this.useToday,
    this.timeRange,
    this.bottomHour,
    this.amountHour,
    this.amountDate,
    required this.direction,
    this.backgroundColor,
    required this.start,
    required this.end,
  })  : assert((amountHour != null && amountDate != null) ||
            (timeRange != null && bottomHour != null)),
        super(key: key);

  final ChartType chartType;
  final String yAxisLabel;
  final String toolTipLabel;
  final bool isDateTime;
  final bool useToday;
  final int? bottomHour;
  final DateTimeRange? timeRange;
  final double? amountHour;
  final DateTime? amountDate;
  final Direction direction;
  final Color? backgroundColor;
  final String start;
  final String end;

  /// [DateTimeRange.end]를 기준으로 [bottomHour]에 의해 다음날로 수정되었을 수 있다.
  ///
  /// 만약 수정된 시간이면 하루 이전으로 변경해야 한다.
  DateTimeRange _getActualDateTime(DateTimeRange timeRange) {
    // bottomHour가 0시라면 전혀 수정된 값이 존재하지 않는다. TimeDataProcessor _isNextDay()
    // 함수에서 확인할 수 있다.
    if (bottomHour == 0) return timeRange;

    const oneBeforeDay = Duration(days: -1);
    final endTime = timeRange.end;

    return (endTime.hour == bottomHour && endTime.minute > 0) ||
            bottomHour! < endTime.hour
        ? DateTimeRange(
            start: timeRange.start.add(oneBeforeDay),
            end: endTime.add(oneBeforeDay))
        : timeRange;
  }

  @override
  Widget build(BuildContext context) {
    late Widget child;
    switch (chartType) {
      case ChartType.time:
        child = _TimeTooltipOverlay(
          timeRange: _getActualDateTime(timeRange!),
          toolTipLabel: toolTipLabel,
          isDateTime: isDateTime,
          useToday: useToday,
          start: start,
          end: end,
        );
        break;
      case ChartType.amount:
        child = _AmountTooltipOverlay(
          toolTipLabel: toolTipLabel,
          useToday: useToday,
          durationHour: amountHour!,
          durationDate: amountDate!,
        );
    }

    final themeData = Theme.of(context);

    return Material(
      color: const Color(0x00ffffff),
      child: Container(
        decoration: ShapeDecoration(
          color: backgroundColor ?? themeData.dialogBackgroundColor,
          shape: TooltipShapeBorder(
            direction: direction,
            isDateTime: isDateTime,
            chartType: chartType,
          ),
          shadows: const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 4.0,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

@immutable
class _TimeTooltipOverlay extends StatelessWidget {
  const _TimeTooltipOverlay({
    Key? key,
    required this.toolTipLabel,
    required this.isDateTime,
    required this.useToday,
    required this.timeRange,
    required this.start,
    required this.end,
  }) : super(key: key);

  final DateTimeRange timeRange;
  final String start;
  final String end;
  final String toolTipLabel;
  final bool isDateTime;
  final bool useToday;

  DateTime get _sleepTime => timeRange.start;

  DateTime get _wakeUp => timeRange.end;

  Widget _timeTile(BuildContext context, DateTime dateTime) {
    final translations = Translations(context);
    final textTheme = Theme.of(context).textTheme;
    final subtitle1 = textTheme.subtitle1!;
    return translations.formatTimeOfDayWidget(
      a: Text(
        translations.dateFormat('a', dateTime),
        style: subtitle1.copyWith(color: subtitle1.color!.withOpacity(0.5)),
        textScaleFactor: 1.0,
      ),
      hMM: Text(
        translations.dateFormat('h:mm', dateTime),
        style: textTheme.headline4!.copyWith(height: 1.1),
        textScaleFactor: 1.0,
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final translations = Translations(context);
    final textTheme = Theme.of(context).textTheme;
    final bodyText2 = textTheme.bodyText2!;
    final bodyTextStyle = bodyText2.copyWith(
        height: 1.4, color: bodyText2.color!.withOpacity(0.7));

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(start, style: bodyTextStyle, textScaleFactor: 1.0),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            _timeTile(context, _sleepTime),
          ],
        ),
        if (!isDateTime) const Expanded(child: Divider()),
        if (!isDateTime) Text(end, style: bodyTextStyle, textScaleFactor: 1.0),
        if (!isDateTime)
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              _timeTile(context, _wakeUp),
            ],
          ),
        Text(
          translations.compactDateTimeRange(
              DateTimeRange(start: _sleepTime, end: _wakeUp)),
          style: bodyTextStyle,
          textScaleFactor: 1.0,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const size = kTimeTooltipSize;
    const dateTimeSize = kTimeTooltipSizeSmall;
    return SizedBox(
      width: size.width,
      height: !isDateTime ? size.height : dateTimeSize.height,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _buildContent(context),
      ),
    );
  }
}

@immutable
class _AmountTooltipOverlay extends StatelessWidget {
  const _AmountTooltipOverlay({
    Key? key,
    required this.durationHour,
    required this.durationDate,
    required this.toolTipLabel,
    required this.useToday,
  }) : super(key: key);

  final double durationHour;
  final DateTime durationDate;
  final String toolTipLabel;
  final bool useToday;

  int _ceilMinutes() {
    double decimal = durationHour - durationHour.toInt();
    return (decimal * 60 + 0.01).toInt() == 60 ? 1 : 0;
  }

  String _getMinute() {
    double decimal = durationHour - durationHour.toInt();
    // 3.99와 같은 무한소수를 고려한다.
    int minutes = (decimal * 60 + 0.01).toInt() % 60;
    return minutes > 0 ? '$minutes' : '';
  }

  String _getHour() {
    if (toolTipLabel.isEmpty) {
      final hour = durationHour.toInt() + _ceilMinutes();
      return hour > 0 ? '$hour' : '';
    } else {
      return '${durationHour.floor()}';
    }
  }

  Widget _buildContent(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final translations = Translations(context);
    final textTheme = Theme.of(context).textTheme;
    final body2 = textTheme.bodyText2!;
    final bodyTextStyle = body2.copyWith(
      color: body2.color!.withOpacity(0.5),
      height: 1.2,
    );
    final sub1 = textTheme.subtitle1!;
    final subTitleStyle = sub1.copyWith(
      color: sub1.color!.withOpacity(0.5),
      height: 1.2,
    );
    final headerStyle = textTheme.headline4!.copyWith(height: 1.2);

    final hourString = _getHour();
    final minuteString = _getMinute();

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              if (hourString.isNotEmpty)
                Text(
                  _getHour(),
                  style: headerStyle,
                  textScaleFactor: 1.0,
                ),
              if (hourString.isNotEmpty)
                Text(
                  toolTipLabel.isEmpty ? translations.shortHour : toolTipLabel,
                  style: subTitleStyle,
                  textScaleFactor: 1.0,
                ),
              if (minuteString.isNotEmpty && toolTipLabel.isEmpty)
                Text(
                  _getMinute(),
                  style: headerStyle,
                  textScaleFactor: 1.0,
                ),
              if (minuteString.isNotEmpty && toolTipLabel.isEmpty)
                Text(
                  translations.shortMinute,
                  style: subTitleStyle,
                  textScaleFactor: 1.0,
                ),
            ],
          ),

          /// JS -- Changed
          /// checks of useToday has been turned on to
          /// display the currect day within the tooltip
          if (!useToday)
            Text(
              localizations.formatShortMonthDay(
                  durationDate.subtract(const Duration(days: 1))),
              style: bodyTextStyle,
              textScaleFactor: 1.0,
            ),
          if (useToday)
            Text(
              localizations.formatShortMonthDay(durationDate),
              style: bodyTextStyle,
              textScaleFactor: 1.0,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const size = kAmountTooltipSize;
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _buildContent(context),
      ),
    );
  }
}
