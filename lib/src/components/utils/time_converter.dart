////////////////////////////////////////////////////////////////
/// Blink Chart Package
///
/// TimeConverter converts various time/ amounts into other data types so that
/// users can toggle how the data looks accurately.
///
/// It is capable of converting the following:
/// 1. Doubles -> DateTimeRanges
/// 2. DateTimeRanges -> Doubles
/// 3. DateTime -> DateTimeRanges
///////////////////////////////////////////////////////////////////

import 'package:flutter/material.dart';

class TimeConverter {
  // JS - timeToDoubles
  //
  // Converts DateTimeRanges to Doubles.
  // This is used by added up the amount of hours per day (year.month.day) and converting that number of
  // hours into a double.
  static List<double> timeToDoubles(
      List<DateTimeRange> timeRanges, isDateTime) {
    Map<String, double> dataDoublesMap = {};
    List<double> dataDoublesList = [];
    List<int> durations = [];
    DateTime firstDay = timeRanges[timeRanges.length - 1].end;
    DateTime currentDay = timeRanges[0].start;

    // While the time complexity of this looks disgusting, it isnt as bad as it looks.
    // Since there wont be multiple years of data for, well a year, it really will only execute 2 for loops for each month of data and day of data.
    // Used to generate unique keys for the map.
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

  // JS - doubleToTime
  // Converts Doubles to DateTimeRanges
  // Assumes that each double represents a days worth of data and turns that into a DateTimeRange object.
  //
  // NOTE: Since there is no start time associated with a double it will give each DateTimeRange the same start time. This is really only used
  // to prevent the application from crashing if the toggle button is enabled on an amount first graph.
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

  // JS - timeToTimeRange
  // Converts DateTimes to DateTimeRanges
  // Used for one off events where the user is just going to input the time something occured.
  // The DateTimeRange is then calculated with a static hour value based on the range of the DateTimes passed in.
  static List<DateTimeRange> timeToTimeRange(
      List<DateTime> dates, double duration) {
    List<DateTimeRange> dataTimeRangesList = [];
    int highestHour = 0;
    int lowestHour = 9999999;

    for (int i = 0; i < dates.length; i++) {
      DateTime current = dates[i];
      highestHour = current.hour > highestHour ? current.hour : highestHour;
      lowestHour = current.hour < lowestHour ? current.hour : lowestHour;
    }

    // This is manually checked to ensure that the bars are the exact height
    // desired.
    if ((highestHour - lowestHour) > 18) {
      duration = 18.0;
    } else {
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
