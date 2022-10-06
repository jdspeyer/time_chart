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
                  data: dataList,
                  yAxisLabel: 'hr',
                  toolTipLabel: 'test',
                  useToday: true,
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
