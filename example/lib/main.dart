import 'dart:math';

import 'package:flutter/material.dart';
import 'package:time_chart/time_chart.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  // Data must be sorted.
  // JP -- Changed
  final List<double> dataList = [15, 1.5, 17.0, 12, 10, 15, 8, 13, 11, 1, 25, 20];

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
                  data: dataList,
                  yAxisLabel: 'test',
                  toolTipLabel: 'txt',
                  useToday: false,
                  height: 300,
                  tooltipBackgroundColor: Colors.white,
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
