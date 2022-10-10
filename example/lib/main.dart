import 'dart:math';

import 'package:flutter/material.dart';
import 'package:time_chart/time_chart.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final List<double> dataList = [
    10.2,
    1.5,
    11.0,
    12.1,
    10.4,
    12.6,
    8.7,
    13.4,
    11.3,
    10.7,
    8,
    6.5,
  ];

  final List<double> dataListNegative = [
    60.0,
    -12.0,
    30.0,
    -30.4,
    59.0,
    -59.0,
    -49.3
  ];

  final List<DateTimeRange> dataListTime = [
    DateTimeRange(
      start: DateTime(2022, 10, 7, 9, 0),
      end: DateTime(2022, 10, 7, 15, 0),
    ),
    DateTimeRange(
      start: DateTime(2022, 10, 7, 6, 0),
      end: DateTime(2022, 10, 7, 8, 0),
    ),
    DateTimeRange(
      start: DateTime(2022, 10, 6, 6, 0),
      end: DateTime(2022, 10, 6, 10, 0),
    ),
    DateTimeRange(
      start: DateTime(2022, 10, 5, 6, 0),
      end: DateTime(2022, 10, 5, 10, 0),
    ),
    DateTimeRange(
      start: DateTime(2022, 10, 4, 6, 0),
      end: DateTime(2022, 10, 4, 10, 0),
    ),
    DateTimeRange(
      start: DateTime(2022, 10, 3, 6, 0),
      end: DateTime(2022, 10, 3, 10, 0),
    ),
    DateTimeRange(
      start: DateTime(2022, 10, 2, 6, 0),
      end: DateTime(2022, 10, 2, 10, 0),
    ),
    DateTimeRange(
      start: DateTime(2022, 10, 1, 6, 0),
      end: DateTime(2022, 10, 1, 10, 0),
    ),
    DateTimeRange(
      start: DateTime(2022, 9, 30, 6, 0),
      end: DateTime(2022, 9, 30, 10, 0),
    ),
  ];

  // final List<DateTimeRange> emptyDataList = [];

  // List<DateTimeRange> getRandomSampleDataList() {
  //   final List<DateTimeRange> list = [];
  //   final random = Random();

  //   for (int i = 0; i < smallDataList.length; ++i) {
  //     final start = DateTime(2022, 10, 4 - i, smallDataList[i] - 1, 0);
  //     final end = DateTime(2022, 10, 4 - i, smallDataList[i], 0);

  //     list.add(DateTimeRange(
  //       start: start,
  //       end: end,
  //     ));
  //   }
  //   return list;
  // }

  // late final List<DateTimeRange> dataList = getRandomSampleDataList();

  @override
  Widget build(BuildContext context) {
    const sizedBox = SizedBox(height: 16);

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Time chart example app')),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                sizedBox,
                const Text('Weekly amount chart'),
                TimeChart(
                  data: dataListNegative,
                  yAxisLabel: '',
                  toolTipLabel: 'Degrees',
                  useToday: false,
                  height: 300,
                  tooltipBackgroundColor: Colors.white,
                  viewMode: ViewMode.weekly,
                  barColor: Colors.deepPurple,
                ),
                sizedBox,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
