import 'dart:math';

import 'package:flutter/material.dart';
import 'package:time_chart/time_chart.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  // Data must be sorted.
  final List<double> smallDataList = [
    8.0,
    14.0,
    27.0,
    22.0,
    10.0,
    23.0,
    21.0,
    23.0,
    21.0,
    0.0,
    9.0,
    14.0
  ];

  final testRange = DateTimeRange(
    start: DateTime(2021, 2, 25, 0, 0),
    end: DateTime(2021, 2, 25, 7, 0),
  );

  //final smallDataList = [7, 14, 40, 30, 10, 27, 40, 37, 28, 0, 9, 14];
  // // Data must be sorted.
  // final smallDataList = [
  //   DateTimeRange(
  //     start: DateTime(2021, 2, 25, 0, 0),
  //     end: DateTime(2021, 2, 25, 48, 0),
  //   ),
  //   DateTimeRange(
  //     start: DateTime(2021, 2, 24, 0, 0),
  //     end: DateTime(2021, 2, 24, 8, 0),
  //   ),
  //   DateTimeRange(
  //     start: DateTime(2021, 2, 23, 0, 0),
  //     end: DateTime(2021, 2, 23, 23, 0),
  //   ),
  //   DateTimeRange(
  //     start: DateTime(2021, 2, 22, 0, 0),
  //     end: DateTime(2021, 2, 22, 23, 0),
  //   ),
  // ];

  final List<DateTimeRange> emptyDataList = [];

  // List<DateTimeRange> getRandomSampleDataList() {
  //   final List<DateTimeRange> list = [];
  //   final random = Random();

  //   for (int i = 0; i < 30; ++i) {
  //     final int randomMinutes1 = random.nextInt(59);
  //     final int randomMinutes2 = random.nextInt(59);
  //     final start = DateTime(2021, 2, 1 - i, 0, randomMinutes1);
  //     final end = DateTime(2021, 2, 1 - i, 7, randomMinutes2 + randomMinutes1);

  //     list.add(DateTimeRange(
  //       start: start,
  //       end: end,
  //     ));
  //   }
  //   return list;
  // }

  @override
  Widget build(BuildContext context) {
    const sizedBox = SizedBox(height: 16);
    print(testRange.duration);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Time chart example app')),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text('Weekly time chart'),
                // TimeChart(
                //   data: bigDataList,
                //   viewMode: ViewMode.weekly,
                // ),
                // sizedBox,
                // const Text('Monthly time chart'),
                // TimeChart(
                //   data: bigDataList,
                //   viewMode: ViewMode.monthly,
                // ),
                sizedBox,
                const Text('Weekly amount chart'),
                TimeChart(
                  data: smallDataList,
                  yAxisLabel: '',
                  toolTipLabel: 'BPM',
                  useToday: false,
                  chartType: ChartType.amount,
                  viewMode: ViewMode.weekly,
                  barColor: Colors.deepPurple,
                ),
                sizedBox,
                // const Text('Monthly amount chart'),
                // TimeChart(
                //   data: bigDataList,
                //   chartType: ChartType.amount,
                //   viewMode: ViewMode.monthly,
                //   barColor: Colors.deepPurple,
                // ),
                // sizedBox,
                // TimeChart(
                //   data: bigDataList,
                //   yAxisLabel: '',
                //   toolTipLabel: 'Blinks',
                //   chartType: ChartType.amount,
                //   viewMode: ViewMode.weekly,
                //   barColor: Colors.deepPurple,
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
