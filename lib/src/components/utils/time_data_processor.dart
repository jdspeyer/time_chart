////////////////////////////////////////////////////////////////
/// Blink Chart Package
///
/// TimeDataProcessor is responsible for cleaning and assembling the data to be
/// displayed by the graphs.
///////////////////////////////////////////////////////////////////

import 'dart:math';
import '../utils/y_label_helper.dart';
import 'package:flutter/material.dart';
import 'package:time_chart/src/components/painter/chart_engine.dart';
import '../../../time_chart.dart';
import '../../chart.dart';
import 'time_assistant.dart' as time_assistant;

/// 0
const double _kMinHour = 0.0;

/// 24
const double _kMaxHour = 24.0;

const String _kNotSortedDataErrorMessage =
    'The data list is reversed or not sorted. Check the data parameter. The first data must be newest data.';

/// JS (Translated)
/// This is a mixin that processes the data appropriately.
///
/// This mixin is used to calculate [topHour] and [bottomHour] etc.
///
/// The algorithm for obtaining the above two standard times is as follows.
/// 1. Select only the data to be displayed on the current chart from the given data. That is, at the time to the right and to the left of the chart
/// Select only included data. At this time, a tolerance of one day is left and right to prevent the chart from being drawn incorrectly.
/// 2. Using the selected data, the reference values ​​are first obtained. The base value is the time range with the largest gaps in the data.
/// find and return
/// 3. Add one day to each of the data between [bottomHour] and 24 hours among the obtained standard values.
///
/// After the above process, [_processedData] contains the data modified according to the standard time.
mixin TimeDataProcessor {
  static const Duration _oneDayDuration = Duration(days: 1);

  /// JS (Translated)
  /// Returns the processed data according to the current [Chart] status.
  ///
  /// The data between [bottomHour] and 24 hours is carried over to the next day.

  /// JP -- Changed
  List get processedData => _processedData;
  List<DateTimeRange> get processedDataTime => _processedDataTime;

  List _processedData = [];
  List<DateTimeRange> _processedDataTime = [];

  final List<DateTimeRange> _inRangeDataList = [];

  int? get topHour => _topHour;
  int? _topHour;

  int? get bottomHour => _bottomHour;
  int? _bottomHour;

  int? get dayCount => _dayCount;
  int? _dayCount;

  /// JS (Translated)
  /// The first data exists between [bottomHour] and 24 o'clock (exactly 0 o'clock) and should be drawn in the next cell.
  /// In this case, it is `true`.
  bool get isFirstDataMovedNextDay => _isFirstDataMovedNextDay;
  bool _isFirstDataMovedNextDay = false;

  void processData(Chart chart, DateTime renderEndTime) {
    if (chart.data.isEmpty) {
      _handleEmptyData(chart);
      return;
    }
    // Used for the Amount Chart - JS
    if (chart.data is List<double>) {
      _processedData = [...chart.data];
    }
    // Used for the Time Chart - JS
    else {
      _processedDataTime = [...chart.data];
    }

    // Used regardless of chart type - JS
    _isFirstDataMovedNextDay = false;

    _countDays(chart.data);
    if (chart.data is List<DateTimeRange>) {
      _generateInRangeDataList(chart.data, chart.viewMode, renderEndTime);
    }
    switch (chart.chartType) {
      case ChartType.time:
        _setPivotHours(chart.defaultPivotHour);
        // Removed to override the 24 hour limit.
        // _processDataUsingBottomHour();
        break;
      case ChartType.amount:
        _calcAmountPivotHeights(chart.data);
    }
  }

  void _handleEmptyData(Chart chart) {
    switch (chart.chartType) {
      case ChartType.time:
        _topHour = chart.defaultPivotHour;
        _bottomHour = _topHour! + 8;
        break;
      case ChartType.amount:
        _topHour = 8;
        _bottomHour = 0;
    }
    _dayCount = 0;
  }

  // JP this is only for chart.time
  void _setPivotHours(int defaultPivotHour) {
    final timePair = _getPivotHoursFrom(_inRangeDataList);
    if (timePair == null) return;
    final startTime = timePair.startTime;
    final endTime = timePair.endTime;

    if (startTime.floor() == endTime.floor() && endTime < startTime) {
      _topHour = startTime.floor();
      _bottomHour = startTime.floor();

      return;
    }

    _topHour = startTime.floor();
    _bottomHour = endTime.ceil();
    if (_topHour! % 2 != _bottomHour! % 2) {
      _topHour = hourDiffBetween(1, _topHour).toInt();
    }
    _topHour = _topHour! % 24;
    _bottomHour = _bottomHour! % 24;
    // use default pivot hour if there is no space or the time range is fully visible
    if (_topHour == _bottomHour) {
      _topHour = defaultPivotHour;

      _bottomHour = defaultPivotHour;
    }
  }

  // JP -- Changed
  void _countDays(List dataList) {
    assert(dataList.isNotEmpty);
    // This is just the number of days
    _dayCount = dataList.length;
  }

  /// JS (Translated)
  /// Included from [renderEndTime] in the input [dataList] to the limited number of days of [viewMode]
  /// Create [_inRangeDataList].
  void _generateInRangeDataList(
    List<DateTimeRange> dataList,
    ViewMode viewMode,
    DateTime renderEndTime,
  ) {
    renderEndTime = renderEndTime.add(
      const Duration(days: ChartEngine.toleranceDay),
    );
    final renderStartTime = renderEndTime.add(Duration(
      days: -viewMode.dayCount - 2 * ChartEngine.toleranceDay,
    ));

    _inRangeDataList.clear();

    DateTime postEndTime =
        dataList.first.end.add(_oneDayDuration).dateWithoutTime();
    for (int i = 0; i < dataList.length; ++i) {
      if (i > 0) {
        assert(
          dataList[i - 1].end.isAfter(dataList[i].end),
          _kNotSortedDataErrorMessage,
        );
      }
      //final currentTime = dataList[i].end.dateWithoutTime();
      final currentTime = dataList[i].end.dateWithoutTime();
      // If the date is different from the previous data
      if (currentTime != postEndTime) {
        final difference = postEndTime.differenceDateInDay(currentTime);
        // if more than one day difference
        postEndTime = postEndTime.add(Duration(days: -difference));
      }
      postEndTime = currentTime;

      if (renderStartTime.isBefore(currentTime) &&
          currentTime.isBefore(renderEndTime)) {
        _inRangeDataList.add(dataList[i]);
      } else {
        _inRangeDataList.add(dataList[i]);
      }
    }
  }

  /// JS (Translated)
  /// Returns `true` if [timeDouble] is located between [bottomHour] and 24 o'clock (exactly 0 o'clock).
  ///
  /// Specifically, it refers to the case where the [timeDouble] time should be located in the next column on the chart.
  bool _isNextCellPosition(double timeDouble) {
    // If the time at the bottom is 0:00, the corresponding block must be displayed with the corresponding time unconditionally.
    if (bottomHour == 0) return false;
    return bottomHour! < timeDouble;
  }

  /// JS (Translated)
  /// If both the start time and end time of the data exist between [bottomHour] and 24:00, the data
  /// Process the next day.
  ///
  /// If it is not processed to the next day, the data to be drawn in the next cell can be drawn in the same cell. in the next column
  /// The data to be plotted refers to data that has the same date but is positioned next to the chart.
  ///
  /// Assume, for example, that the data is given so that the chart plots from 20:00 to 8:00. At this time, one of the data
  /// If it is between 21:00 and 23:00, it moves to the next day based on 0:00, so the corresponding data must be drawn in the next column.
  /// Used for chart.time
  void _processDataUsingBottomHour() {
    final len = _processedDataTime.length;
    for (int i = 0; i < len; ++i) {
      final DateTime startTime = _processedDataTime[i].start;
      final DateTime endTime = _processedDataTime[i].end;
      final double startTimeDouble = startTime.toDouble();
      final double endTimeDouble = endTime.toDouble();

      if (_isNextCellPosition(startTimeDouble) &&
          _isNextCellPosition(endTimeDouble)) {
        _processedDataTime[i] = DateTimeRange(
          start: startTime.add(_oneDayDuration),
          end: endTime.add(_oneDayDuration),
        );

        if (i == 0) {
          _dayCount = _dayCount! + 1;
          _isFirstDataMovedNextDay = true;
        }
      }
    }
  }

  /// JS (Translated)
  /// Obtains the values ​​that will be the standard for the time graph.
  ///
  /// The widest part of the interval with empty time data is selected, and the start time of the selected value is
  /// [topHour], end time becomes [bottomHour].
  _TimePair? _getPivotHoursFrom(List<DateTimeRange> dataList) {
    final List<_TimePair> rangeList = _getSortedRangeListFrom(dataList);
    if (rangeList.isEmpty) return null;

    // Find the widest part of the empty space.
    final len = rangeList.length;
    _TimePair resultPair =
        _TimePair(rangeList[0].startTime, rangeList[0].endTime);
    double maxInterval = 0.0;

    for (int i = 0; i < len; ++i) {
      final lo = i, hi = (i + 1) % len;
      final wakeUp = rangeList[lo].endTime;
      final sleepTime = rangeList[hi].startTime;

      double interval = sleepTime - wakeUp;
      if (interval < 0) {
        interval += 24;
      }

      if (maxInterval < interval) {
        maxInterval = interval;
        resultPair = _TimePair(sleepTime, wakeUp);
      }
    }
    return resultPair;
  }

  /// JS (Translated)
  /// Returns a range list of how the time data list is distributed in 24 hours in [double] format.
  ///
  /// These values ​​are sorted in ascending order.
  List<_TimePair> _getSortedRangeListFrom(List<DateTimeRange> dataList) {
    List<_TimePair> rangeList = [];

    for (int i = 0; i < dataList.length; ++i) {
      final curSleepPair =
          _TimePair(dataList[i].start.toDouble(), dataList[i].end.toDouble());

      // If 0 o'clock is in between, such as 23 o'clock to 6 o'clock, it is divided into two ranges based on 0 o'clock.
      if (curSleepPair.startTime > curSleepPair.endTime) {
        final frontPair = _TimePair(_kMinHour, curSleepPair.endTime);
        final backPair = _TimePair(curSleepPair.startTime, _kMaxHour);

        rangeList = _mergeRange(frontPair, rangeList);
        rangeList = _mergeRange(backPair, rangeList);
      } else {
        rangeList = _mergeRange(curSleepPair, rangeList);
      }
    }

    // sort in ascending order
    rangeList.sort((a, b) => a.compareTo(b));
    return rangeList;
  }

  /// JS (Translated)
  /// If there is a list in which [hour] is included in [rangeList], merge with the list
  /// Returns [rangeList].
  ///
  /// There are no overlapping values ​​among the values ​​of [rangeList].
  List<_TimePair> _mergeRange(_TimePair timePair, List<_TimePair> rangeList) {
    int loIdx = -1;
    int hiIdx = -1;

    for (int i = 0; i < rangeList.length; ++i) {
      final curPair = rangeList[i];
      if (timePair.inRange(curPair.startTime) &&
          timePair.inRange(curPair.endTime)) rangeList.removeAt(i--);
    }

    for (int i = 0; i < rangeList.length; ++i) {
      final _TimePair curSleepPair =
          _TimePair(rangeList[i].startTime, rangeList[i].endTime);

      if (loIdx == -1 && curSleepPair.inRange(timePair.startTime)) {
        loIdx = i;
      }
      if (hiIdx == -1 && curSleepPair.inRange(timePair.endTime)) {
        hiIdx = i;
      }
      if (loIdx != -1 && hiIdx != -1) {
        break;
      }
    }

    final newSleepPair = _TimePair(
        loIdx == -1 ? timePair.startTime : rangeList[loIdx].startTime,
        hiIdx == -1 ? timePair.endTime : rangeList[hiIdx].endTime);

    if (loIdx != -1 && loIdx == hiIdx) {
      rangeList.removeAt(loIdx);
    } else {
      if (loIdx != -1) {
        rangeList.removeAt(loIdx);
        if (loIdx < hiIdx) --hiIdx;
      }
      if (hiIdx != -1) rangeList.removeAt(hiIdx);
    }

    for (int i = 0; i < rangeList.length; ++i) {
      final curSleepPair = rangeList[i];
      if (newSleepPair.inRange(curSleepPair.startTime) &&
          newSleepPair.inRange(curSleepPair.endTime)) {
        rangeList.remove(curSleepPair);
      }
    }

    rangeList.add(newSleepPair);
    return rangeList;
  }

// JP -- Changed
  void _calcAmountPivotHeights(List dataList) {
    final int len = dataList.length;

    double maxResult = 0.0;
    double minResult = 0.0;

    double sum = 0.0;
    if (dataList is List<double>) {
      // FIXES issue with the datalist not processing negative numbers when finding max.
      // If there is a negative number that is larger than the largest possitive number it will
      // use that instead.
      minResult = dataList.reduce(min);
      maxResult = dataList.reduce(max);
      if (minResult.abs() > maxResult) {
        maxResult = minResult.abs();
      }

      // FIXES issue with infinite Y-Labels
      // THIS IS FOR THE Y-LABEL MAX HOUR or TOPHOUR
      // These are handset breakpoints for a better looking graph overall.
      // It finds the upper dividend (scaled based on the highest maxResult in the dataset)
      // Example: 1000+ maxResult will jump to the nearest 100 while 10+ results will just jump to the nearest 5.
      // if (maxResult >= 1000) {
      //   maxResult =
      //       YLabelCalculator.nearestUpperDividend(maxResult.ceil(), 100) + 0.0;
      // } else if (maxResult >= 500) {
      //   maxResult =
      //       YLabelCalculator.nearestUpperDividend(maxResult.ceil(), 50) + 0.0;
      // } else if (maxResult >= 100) {
      //   maxResult =
      //       YLabelCalculator.nearestUpperDividend(maxResult.ceil(), 25) + 0.0;
      // } else if (maxResult >= 50) {
      //   maxResult =
      //       YLabelCalculator.nearestUpperDividend(maxResult.ceil(), 10) + 0.0;
      // } else if (maxResult >= 10) {
      //   maxResult =
      //       YLabelCalculator.nearestUpperDividend(maxResult.ceil(), 4) + 0.0;
      // } else if (maxResult >= 5) {
      //   maxResult =
      //       YLabelCalculator.nearestUpperDividend(maxResult.ceil(), 2) + 0.0;
      // }
      maxResult =
          YLabelCalculator.customNearestUpperDividend(maxResult.ceil()) + 0.0;

      _topHour = maxResult.ceil();
    } else if (dataList is List<DateTimeRange>) {
      for (int i = 0; i < len; ++i) {
        final amount = dataList[i].durationInHours;
        sum += amount;

        // Calculates the height of each bar.
        if (i == len - 1 ||
            dataList[i].end.dateWithoutTime() !=
                dataList[i + 1].end.dateWithoutTime()) {
          maxResult = max(maxResult, sum);
          sum = 0.0;
        }
      }
      _topHour = ((maxResult.ceil()) / 2).ceil() * 2;
    }

    /// JS -- changed
    /// This sets the floor of the y-axis labels to be the smallest value
    /// in the list if the smallest value is less than 0.
    if (dataList is List<double> && (dataList).reduce(min) < 0.0) {
      //_bottomHour = ((dataList as List<double>).reduce(min).ceil() as int);
      _bottomHour = (_topHour as int) * -1;
    } else {
      _bottomHour = 0;
    }
  }

  /// JS (Translated)
  /// Find the time that has passed from [b] to [a]. For example, the time from 5 o'clock to 3 o'clock is 22 hours,
  /// The time that has passed from 16:00 to 19:00 is 3 hours.
  ///
  /// By using this inversely, we can get the start time from the end time.
  /// Put the total amount of time in [b] and the end time in [a] to return the start time.
  dynamic hourDiffBetween(dynamic a, dynamic b) {
    final c = b - a;
    if (c <= 0) return 24.0 + c;
    return c;
  }
}

class _TimePair implements Comparable {
  /// JS (Translated)
  /// Creates a class with start and end times of [double] type.
  const _TimePair(this._startTime, this._endTime);

  final double _startTime;
  final double _endTime;

  double get startTime => _startTime;

  double get endTime => _endTime;

  bool inRange(double a) => _startTime <= a && a <= _endTime;

  @override
  int compareTo(other) {
    if (_startTime < other.startTime) return -1;
    if (_startTime > other.startTime) return 1;
    return 0;
  }

  @override
  String toString() => 'startTime: $startTime, wakeUp: $endTime';
}
