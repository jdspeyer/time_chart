import 'dart:math';

import 'package:flutter/material.dart';
import 'package:time_chart/time_chart.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  // Data must be sorted.
  // JP -- Changed
  // final List<double> smallDataList = [30, 1.0, 17.0, 12, 10, 15, 8, 13, 11, 1, 9, 14];

  // // JP -- Changed
  final smallDataList = [15, 1, 20, 12, 10, 15, 8, 13, 11, 1, 9, 14];

  final List<DateTimeRange> emptyDataList = [];

  List<DateTimeRange> getRandomSampleDataList() {
    final List<DateTimeRange> list = [];
    final random = Random();

    for (int i = 0; i < smallDataList.length; ++i) {
      if (smallDataList[i] < 0) {
        smallDataList[i] = 0;
      }
      final start = DateTime(2021, 2, 1 - i, 0, 0);
      final end = DateTime(2021, 2, 1 - i, smallDataList[i], 0);

      list.add(DateTimeRange(
        start: start,
        end: end,
      ));
    }
    return list;
  }

  late final List<DateTimeRange> bigDataList = getRandomSampleDataList();

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
                  // JP -- Changed
                  // data: smallDataList,
                  data: bigDataList,
                  yAxisLabel: 'test',
                  toolTipLabel: 'txt',
                  useToday: false,
                  height: 250,
                  tooltipBackgroundColor: Colors.blueGrey,
                  chartType: ChartType.amount,
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
