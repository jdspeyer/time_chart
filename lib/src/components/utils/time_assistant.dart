////////////////////////////////////////////////////////////////
/// Blink Chart Package
///
/// TimeAssistant is used to easily navigate along a TimeChart or AmountChart.
///
/// Included multiple helper functions to make drawing the graphs less repetitive.
///////////////////////////////////////////////////////////////////

import 'dart:math';

import 'package:flutter/material.dart';

/// Get the number of months in the last month.
int getPreviousMonthFrom(int month) {
  if (month == 1) return 12;
  return month - 1;
}

/// Calculates the time that has passed from [a] to [b].
int diffBetween(int a, int b) {
  final result = b - a;

  if (result < 0) return 24 + result;
  return result;
}

/// JS (Translated)
/// Current reference to previous reference times (top: [beforeTop], bottom: [beforeBottom])
/// Obtain animation direction using times (top: [top], bottom: [bottom]).
///
/// Returns true if up, false if down.
bool isDirUpward(int beforeTop, int beforeBottom, int top, int bottom) {
  if (beforeBottom <= beforeTop) beforeBottom += 24;
  if (bottom <= top) bottom += 24;

  void goFront() {
    top += 24;
    bottom += 24;
  }

  void goBack() {
    top -= 24;
    bottom -= 24;
  }

  // Move from the back to the front and move to the backmost to find the section that overlaps the most.
  while (bottom > beforeTop) {
    goBack();
  }
  goFront();

  int upward = 0, downward = 0;
  while (beforeBottom > top) {
    if (beforeTop < top) {
      upward = max(upward, min(bottom - top, beforeBottom - top));
    } else {
      downward = max(downward, min(bottom - top, bottom - beforeTop));
    }
    goFront();
  }
  return upward > downward;
}

/// Returns `true` if [hour] is included in [range].
bool isInRangeHour(DateTimeRange range, int hour) {
  DateTime time =
      DateTime(range.start.year, range.start.month, range.start.day, hour);
  // Allows to be positioned between two times.
  if (time.isBefore(range.start)) time = time.add(const Duration(days: 1));

  if (range.start.isBefore(time) && time.isBefore(range.end)) return true;
  return false;
}

extension DateTimeUtils on DateTime {
  /// Return `true` if [other] has same date without time.
  bool isSameDateWith(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  /// Return day that date difference with [other].
  int differenceDateInDay(DateTime other) {
    DateTime thisDate = dateWithoutTime();

    DateTime otherDate = other.dateWithoutTime();

    return thisDate.difference(otherDate).inDays;
  }

  int differenceDateInDayBar(DateTime other) {
    return 1;
  }

  DateTime dateWithoutTime() {
    return DateTime(year, month, day);
  }

  double toDouble() {
    return hour.toDouble() + minute.toDouble() / 60;
  }
}

extension DateTimeRangeUtils on DateTimeRange {
  double get durationInHours {
    return duration.inMinutes / 60;
  }
}

extension DateTimeRangeListUtils on List<DateTimeRange> {
  /// Performs a binary search and returns the index of the data with the most recent date that exceeds the [targetDate] date.
  ///
  /// When calling this, the values ​​in the list must be sorted by the date at which the first index is later.
  int getLowerBound(DateTime targetDate) {
    int min = 0;
    int max = length;
    int result = -1;

    while (min < max) {
      result = min + ((max - min) >> 1);
      final DateTimeRange element = this[result];
      final int comp = targetDate.differenceDateInDay(element.end);
      if (comp == 0) {
        break;
      }
      if (comp < 0) {
        min = result + 1;
      } else {
        max = result;
      }
    }
    // Select the most recent date data within the same day.
    while (
        result - 1 >= 0 && this[result - 1].end.day == this[result].end.day) {
      result--;
    }
    return result;
  }
}
