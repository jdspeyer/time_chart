import 'package:flutter/material.dart';

class TimeConverter {
  // Converter
  static List<double> timeToDoubles(
      List<DateTimeRange> timeRanges, isDateTime) {
    Map<String, double> dataDoublesMap = {};
    List<double> dataDoublesList = [];
    List<int> durations = [];
    DateTime firstDay = timeRanges[timeRanges.length - 1].end;
    DateTime currentDay = timeRanges[0].start;

    for (int year = firstDay.year; year <= currentDay.year; year++) {
      for (int month = firstDay.month; month <= currentDay.month; month++) {
        for (int day = firstDay.day; day <= currentDay.day; day++) {
          String timeKey = '${year}.${month}.${day}';
          dataDoublesMap[timeKey] = 0;
        }
      }
    }

    for (int i = 0; i < timeRanges.length; i++) {
      DateTime time = timeRanges[i].start;
      double duration = ((timeRanges[i].duration.inMinutes) / 60);

      String timeKey = '${time.year}.${time.month}.${time.day}';

      if (dataDoublesMap.containsKey(timeKey)) {
        dataDoublesMap[timeKey] = !isDateTime
            ? (dataDoublesMap[timeKey]! + duration)
            : dataDoublesMap[timeKey]! + 1;
      } else {
        dataDoublesMap[timeKey] = !isDateTime ? duration : 1;
      }
    }
    dataDoublesMap.entries.forEach((day) => dataDoublesList.add(day.value));
    return List<double>.from(dataDoublesList.reversed);
  }

  /// DOUBLES TO TIME METHOD
  static List<DateTimeRange> doublesToTime(
      List<double> doubles, bool useToday) {
    List<DateTimeRange> dataTimeRangesList = [];
    DateTime today =
        useToday ? DateTime.now() : DateTime.now().subtract(Duration(days: 1));

    for (int i = 0; i < doubles.length; i++) {
      final duration = (doubles[i] >= 0)
          ? (doubles[i] > 24.0)
              ? 23.0
              : doubles[i]
          : 0.0;

      DateTime start = DateTime(today.year, today.month, today.day, 0, 0);
      int totalHours = duration.floor();
      int totalMinutes = ((duration - totalHours) * 60).floor();

      DateTime end = DateTime(
          start.year, start.month, start.day, totalHours, totalMinutes);

      dataTimeRangesList.add(DateTimeRange(end: end, start: start));

      today = today.subtract(Duration(days: 1));
    }
    return dataTimeRangesList;
  }

  // DATETIME -> DATETIMERANGE
  static List<DateTimeRange> timeToTimeRange(
      List<DateTime> dates, double duration) {
    List<DateTimeRange> dataTimeRangesList = [];
    int highestHour = 0;
    int lowestHour = 999;

    for (int i = 0; i < dates.length; i++) {
      DateTime current = dates[i];
      highestHour = current.hour > highestHour ? current.hour : highestHour;
      lowestHour = current.hour < lowestHour ? current.hour : lowestHour;
    }

    if ((highestHour - lowestHour) > 18) {
      print('-> ${highestHour - lowestHour}');
      duration = 18.0;
    } else {
      print('-> ${highestHour - lowestHour}');
      duration = 10.0;
    }

    for (int i = 0; i < dates.length; i++) {
      DateTime start = dates[i];
      DateTime end = start.add(Duration(minutes: duration.ceil()));

      dataTimeRangesList.add(DateTimeRange(end: end, start: start));
    }

    return dataTimeRangesList;
  }
}
