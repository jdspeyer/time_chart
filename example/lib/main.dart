import 'dart:math';

import 'package:flutter/material.dart';
import 'package:time_chart/time_chart.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final List<double> dataList = [
    10.2,
    0,
    11.0,
    12.1,
    10.4,
    12.6,
    8.7,
    6.2,
    8.3,
    9.7,
  ];

  final List<double> dataListNegative = [60.0, -12.0, 30.0, -30.4, 59.0, -59.0, -49.3];

  final List<DateTimeRange> dataListTime = [
    DateTimeRange(
      start: DateTime(2022, 10, 26, 9, 0),
      end: DateTime(2022, 10, 26, 15, 0),
    ),
    DateTimeRange(
      start: DateTime(2022, 10, 25, 6, 0),
      end: DateTime(2022, 10, 25, 8, 0),
    ),
    DateTimeRange(
      start: DateTime(2022, 10, 24, 6, 0),
      end: DateTime(2022, 10, 24, 10, 0),
    ),
    DateTimeRange(
      start: DateTime(2022, 10, 23, 6, 0),
      end: DateTime(2022, 10, 23, 10, 0),
    ),
    DateTimeRange(
      start: DateTime(2022, 10, 22, 6, 0),
      end: DateTime(2022, 10, 22, 10, 0),
    ),
    DateTimeRange(
      start: DateTime(2022, 10, 21, 6, 0),
      end: DateTime(2022, 10, 21, 10, 0),
    ),
    DateTimeRange(
      start: DateTime(2022, 10, 20, 6, 0),
      end: DateTime(2022, 10, 20, 10, 0),
    ),
    DateTimeRange(
      start: DateTime(2022, 10, 19, 6, 0),
      end: DateTime(2022, 10, 19, 10, 0),
    ),
    DateTimeRange(
      start: DateTime(2022, 10, 18, 6, 0),
      end: DateTime(2022, 10, 18, 10, 0),
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
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Time chart example app')),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text('Weekly amount chart'),
                Row(
                  children: [
                    SizedBox(
                      width: 180,
                      height: 250,
                      child: TimeChart(
                        data: dataList,
                        yAxisLabel: 'test',
                        toolTipLabel: 'Degrees',
                        useToday: false,
                        width: 180,
                        height: 230,
                        tooltipBackgroundColor: Colors.white,
                        viewMode: ViewMode.weekly,
                        barColor: Colors.deepPurple,
                        widgetMode: true, // JP -- added this for simplified widgets
                      ),
                    ),
                    SizedBox(
                      width: 180,
                      height: 200,
                      child: TimeChart(
                        data: dataListNegative,
                        yAxisLabel: 'test',
                        toolTipLabel: 'Degrees',
                        useToday: false,
                        width: 180,
                        height: 180,
                        tooltipBackgroundColor: Colors.white,
                        viewMode: ViewMode.weekly,
                        barColor: Colors.deepPurple,
                        widgetMode: true, // JP -- added this for simplified widgets
                      ),
                    ),
                  ],
                ),
                TimeChart(
                  data: dataListTime,
                  yAxisLabel: 'test',
                  toolTipLabel: 'Degrees',
                  useToday: false,
                  width: 300,
                  height: 250,
                  tooltipBackgroundColor: Colors.white,
                  viewMode: ViewMode.weekly,
                  barColor: Colors.deepPurple,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
