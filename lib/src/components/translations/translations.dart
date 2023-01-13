////////////////////////////////////////////////////////////////
/// Blink Chart Package
///
/// Translations is not a used file for Blink Chart currently.
///
/// Allowes for time to be displayed in either English or Korean. More languages
/// could be added in the future if there are plans to add supported languages to the app.
///////////////////////////////////////////////////////////////////

import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class Translations {
  const Translations(this._context);

  final BuildContext _context;

  String get languageCode =>
      Localizations.localeOf(_context).toString().substring(0, 2);

  bool get isKorean => languageCode == 'ko';

  String get shortHour {
    if (isKorean) return "시간";
    return "hr";
  }

  String get shortMinute {
    if (isKorean) return "분";
    return "min";
  }

  /// Returns 'true' if the time format is 10:00 AM, 'false' if it is 10:00 AM
  bool get isAHMM {
    return MaterialLocalizations.of(_context).timeOfDayFormat() ==
        TimeOfDayFormat.a_space_h_colon_mm;
  }

  String dateFormat(String pattern, DateTime date) {
    initializeDateFormatting('en', null);
    return DateFormat(pattern, languageCode).format(date);
  }

  String compactDateTimeRange(DateTimeRange range) {
    final shortMonthList = getShortMonthList(_context);
    final daySuffix = isKorean ? '일' : '';
    final sleepTimeMonth = shortMonthList[range.start.month - 1];
    final wakeUpMonth = shortMonthList[range.end.month - 1];

    String result;
    if (range.start.day != range.end.day) {
      if (range.start.month != range.end.month) {
        result = '$sleepTimeMonth ${range.start.day}$daySuffix - '
            '$wakeUpMonth ${range.end.day}$daySuffix';
      } else {
        result = '$wakeUpMonth ${range.start.day} - ${range.end.day}$daySuffix';
      }
    } else {
      result = '$wakeUpMonth ${range.end.day}$daySuffix';
    }

    return result;
  }

  /// en: 11:30 AM
  Widget formatTimeOfDayWidget({
    required Widget a,
    required Widget hMM,
    double interval = 4,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
  }) {
    final isAHMMFormat = isAHMM;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      mainAxisAlignment: mainAxisAlignment,
      children: [
        if (isAHMMFormat) ...<Widget>[
          a,
          SizedBox(width: interval),
        ],
        hMM,
        if (!isAHMMFormat) ...<Widget>[
          SizedBox(width: interval),
          a,
        ],
      ],
    );
  }

  /// Returns the translated time.
  ///
  /// For example, in Korean, if [hour] is 13, 1:00 PM is returned.
  /// In case of English, 1 PM is returned.
  String formatHourOnly(int hour) {
    final date = DateTime(1, 1, 1, hour);
    String format;
    if (isAHMM) {
      format = 'a h시';
    } else {
      format = 'h a';
    }
    return dateFormat(format, date);
  }
}

///Sun, Mon, Tue,...
List<String> getShortWeekdayList(BuildContext context) {
  return dateTimeSymbolMap()[_locale(context)].SHORTWEEKDAYS;
}

List<String> getSingleWeekdayList(BuildContext context) {
  return dateTimeSymbolMap()[_locale(context)].NARROWWEEKDAYS;
}

///Jan, Feb, Mar,...
List<String> getShortMonthList(BuildContext context) {
  return dateTimeSymbolMap()[_locale(context)].SHORTMONTHS;
}

String _locale(BuildContext context) {
  return Localizations.localeOf(context).toString().substring(0, 2);
}
