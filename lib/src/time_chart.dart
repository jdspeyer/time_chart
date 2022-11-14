import 'package:flutter/material.dart';
import 'chart.dart';
import 'components/chart_type.dart';
import 'dart:math';
import 'components/view_mode.dart';
import './components/utils/time_converter.dart';

/// The padding to prevent cut off the top of the chart.
const double kTimeChartTopPadding = 4.0;

class TimeChart extends StatelessWidget {
  TimeChart({
    Key? key,
    this.yAxisLabel = 'hr',
    this.toolTipLabel = 'hr',
    this.useToday = true,
    this.chartType = ChartType.time,
    this.width,
    this.height = 280.0,
    this.barColor,
    this.detailColor,
    this.toggleButton = false,
    required this.data,
    this.timeChartSizeAnimationDuration = const Duration(milliseconds: 300),
    this.tooltipDuration = const Duration(seconds: 7),
    this.tooltipBackgroundColor,
    this.tooltipStart = "START",
    this.tooltipEnd = "END",
    this.eventDuration = 5.0,
    this.activeTooltip = true,
    this.viewMode = ViewMode.weekly,
    this.defaultPivotHour = 0,
    this.widgetMode = false, // JP -- added this for simplified widgets
  }) :
        // assert(0 <= defaultPivotHour && defaultPivotHour < 24),
        super(key: key);

  /// The type of chart.
  ///
  /// Default is the [ChartType.time].

  /// JS -- Changed
  /// Since we are inferring the chart type based on the data being passed in,
  /// there is no need for it to be a parameter.
  /// Its late definition is to allow the data parameter to be taken in. chartType then bases
  /// its typing off of data.
  ///
  /// If data is double --> amount if data is anything else (presumed to be DateTime) --> time.
  // late final ChartType chartType =
  //     (data is List<double>) ? ChartType.amount : ChartType.time;
  ///
  ///Updated
  final ChartType chartType;

  /// Optional label for the y-axis
  ///
  /// Default is hr
  final String yAxisLabel;

  /// Optional label for the tool tip
  ///
  /// Default is empty which will leave tooltip display as is.
  final String toolTipLabel;
  final double eventDuration;

  /// Optional boolean field whether to use the current date or the previous days date
  ///
  /// Defaults to true -- using todays date.
  final bool useToday;

  /// the max that the y-axis will extend to.
  /// defaults to the highest value.

  /// Optional label color modifier. Useful for changing themes.
  ///
  /// Default is gray
  // final Color toolTipLabelColor;

  /// Total chart width.
  ///
  /// Default is parent box width.
  final double? width;

  /// Total chart height
  ///
  /// Default is `280.0`. Actual height is [height] + 4.0([kTimeChartTopPadding]).
  final double height;

  /// The color of the bar in the chart.
  ///
  /// Default is the `Theme.of(context).colorScheme.secondary`.
  final Color? barColor;
  final Color? detailColor;
  late final Color? altColor = detailColor ?? barColor;

  /// The list of [double] or [DateTime].
  ///
  /// The first index is the latest data, The end data is the oldest data.
  /// It must be sorted because of correctly painting the chart.
  ///
  /// ```dart
  /// assert(data[0].isAfter(data[1])); // true
  /// ```
  final data;
  late final dataList = (chartType == ChartType.time)
      ? (data is List<DateTimeRange>
          ? data
          : (data is List<DateTime>)
              ? TimeConverter.timeToTimeRange(data, eventDuration)
              : TimeConverter.doublesToTime(data, useToday))
      : (data is List<double>
          ? data
          : TimeConverter.timeToDoubles(data, false));

  /// The size animation duration of time chart when is changed pivot hours.
  ///
  /// Default value is `Duration(milliseconds: 300)`.
  final Duration timeChartSizeAnimationDuration;

  /// The Tooltip duration.
  ///
  /// Default is `Duration(seconds: 7)`.
  final Duration tooltipDuration;

  /// The color of the tooltip background.
  ///
  /// [Theme.of(context).dialogBackgroundColor] is default color.
  final Color? tooltipBackgroundColor;

  /// The label of [ChartType.time] tooltip.
  ///
  /// Default is "start"
  final String tooltipStart;

  /// The label of [ChartType.time] tooltip.
  ///
  /// Default is "end"
  final String tooltipEnd;

  /// If it's `true` active showing the tooltip when tapped a bar.
  ///
  /// Default value is `true`
  final bool activeTooltip;

  /// The chart view mode.
  ///
  /// There is two type [ViewMode.weekly] and [ViewMode.monthly].
  final ViewMode viewMode;

  /// The hour is used as a pivot if the data time range is fully visible or
  /// there is no data when the type is the [ChartType.time].
  ///
  /// For example, this value will be used when you use the data like below.
  /// ```dart
  /// [DateTimeRange(
  ///       start: DateTime(2021, 12, 17, 3, 12),
  ///       end: DateTime(2021, 12, 18, 2, 30),
  /// )];
  /// ```
  ///
  /// If there is no data when the type is the [ChartType.amount], 8 Hours is
  /// used as a top hour, not this value.
  ///
  /// It must be in the range of 0 to 23.
  final int defaultPivotHour;

  /// If it's `true` the chart becomes a small widget.
  ///
  /// Default value is `false`
  final bool widgetMode;

  /// Enable the chart toggle button
  final bool toggleButton;

  @override
  Widget build(BuildContext context) {
    print('1. ${widgetMode}');
    // print('$chartType Is the type of chart we are going to construct <--');
    bool isDateTime = false;
    if (data is List<DateTime>) {
      isDateTime = true;
    }

    return LayoutBuilder(builder: (_, box) {
      final actualWidth = width ?? box.maxWidth;
      return SizedBox(
        height: height + kTimeChartTopPadding,
        width: actualWidth,
        child: Chart(
          key: ValueKey(viewMode),
          chartType: data is List<double>
              ? (data as List<double>).reduce(min) >= 0.0
                  ? chartType
                  : ChartType.amount
              : chartType,
          yAxisLabel: yAxisLabel,
          toolTipLabel: toolTipLabel,
          useToday: useToday,
          // toolTipLabelColor: toolTipLabelColor,
          width: actualWidth,
          height: height,
          barColor: barColor,
          detailColor: altColor,
          data: dataList,
          dataTime: data is List<DateTimeRange>
              ? data
              : data is List<double>
                  ? TimeConverter.doublesToTime(data, useToday)
                  : TimeConverter.timeToTimeRange(data, eventDuration),
          dataDouble: data is List<double>
              ? data
              : data is List<DateTimeRange>
                  ? TimeConverter.timeToDoubles(data, false)
                  : TimeConverter.timeToDoubles(
                      TimeConverter.timeToTimeRange(data, eventDuration), true),
          timeChartSizeAnimationDuration: timeChartSizeAnimationDuration,
          tooltipDuration: tooltipDuration,
          tooltipBackgroundColor: tooltipBackgroundColor,
          tooltipStart: tooltipStart,
          tooltipEnd: tooltipEnd,
          activeTooltip: widgetMode
              ? false
              : activeTooltip, // JP -- added this for simplified widgets for simplified widgets
          viewMode: widgetMode
              ? ViewMode.weekly
              : viewMode, // JP -- added this for simplified widgets for simplified widgets
          toggleButton: data is List<double>
              ? (data as List<double>).reduce(min) >= 0.0
                  ? toggleButton
                  : false
              : toggleButton,
          defaultPivotHour: defaultPivotHour,
          widgetMode:
              widgetMode, // JP -- added this for simplified widgets for simplified widgets
          isDateTime: isDateTime,
        ),
      );
    });
  }
}
