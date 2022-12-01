import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:time_chart/time_chart.dart';
import 'package:flutter/services.dart';

void main() {
  // Step 2
  WidgetsFlutterBinding.ensureInitialized();
  // Step 3
  SystemChrome.setPreferredOrientations([
    // DeviceOrientation.landscapeLeft,
    // DeviceOrientation.landscapeRight,
  ]).then((value) => runApp(MyApp()));
  runApp(MyApp());
}

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
    11.0,
    12.1,
    10.4,
    12.6,
    8.7,
    6.2,
    8.3,
    9.7,
    11.0,
    12.1,
    10.4,
    12.6,
    8.7,
    6.2,
    8.3,
    9.7,
    11.0,
    12.1,
    10.4,
    12.6,
    8.7,
    6.2,
    8.3,
    9.7,
  ];

  final List<double> dataListNegative = [0.0, -12.0, 1.0, -30.4, 0.0, -90.0, -49.3];

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

  final List<DateTime> dataListSingleTimes = [
    DateTime(2022, 10, 26, 15, 0),
    DateTime(2022, 10, 26, 14, 0),
    DateTime(2022, 10, 25, 13, 0),
    DateTime(2022, 10, 25, 12, 0),
    DateTime(2022, 10, 25, 10, 0),
    DateTime(2022, 10, 24, 15, 0),
    DateTime(2022, 10, 24, 14, 0),
  ];

  final List<DateTime> dataListSingleTimesSmallGap = [
    DateTime(2022, 10, 26, 15, 0),
    DateTime(2022, 10, 26, 14, 0),
    DateTime(2022, 10, 25, 15, 0),
    DateTime(2022, 10, 25, 14, 0),
    DateTime(2022, 10, 24, 15, 0),
    DateTime(2022, 10, 24, 14, 0),
  ];

  final List<DateTime> dataListSingleTimesLargeGap = [
    DateTime(2022, 10, 26, 23, 0),
    DateTime(2022, 10, 26, 1, 0),
    DateTime(2022, 10, 25, 13, 0),
    DateTime(2022, 10, 25, 12, 0),
    DateTime(2022, 10, 24, 15, 0),
    DateTime(2022, 10, 24, 14, 0),
    DateTime(2022, 10, 23, 8, 0),
    DateTime(2022, 10, 23, 5, 0),
    DateTime(2022, 10, 23, 2, 0),
    DateTime(2022, 10, 23, 1, 0),
    DateTime(2022, 10, 22, 12, 0),
    DateTime(2022, 10, 22, 5, 0),
    DateTime(2022, 10, 22, 3, 0),
    DateTime(2022, 10, 20, 2, 0),
  ];

  final List<double> dataListEmpty = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];

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
    // double screenWidth = MediaQuery.of(context).size.width;
    // double screenHeight = MediaQuery.of(context).size.height;

    // double rectangleWidgetWidth = screenWidth * .95;
    // double squareWidgetWidth = rectangleWidgetWidth * .48;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Time chart example app')),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text('Time Chart Base'),
                // Row(
                //   children: [
                //     SizedBox(
                //       width: 180,
                //       height: 250,
                //       child: TimeChart(
                //         data: dataList,
                //         chartType: ChartType.amount,
                //         yAxisLabel: 'test',
                //         toolTipLabel: 'Degrees',
                //         useToday: false,
                //         width: 180,
                //         height: 230,
                //         tooltipBackgroundColor: Colors.white,
                //         viewMode: ViewMode.weekly,
                //         barColor: Colors.deepPurple,
                //         widgetMode:
                //             false, // JP -- added this for simplified widgets
                //       ),
                //     ),
                //     SizedBox(
                //       width: 180,
                //       height: 200,
                //       child: TimeChart(
                //         data: dataListTime,
                //         yAxisLabel: 'test',
                //         toolTipLabel: 'Degrees',
                //         useToday: false,
                //         width: 180,
                //         height: 180,
                //         tooltipBackgroundColor: Colors.white,
                //         viewMode: ViewMode.weekly,
                //         barColor: Colors.deepPurple,
                //         widgetMode:
                //             true, // JP -- added this for simplified widgets
                //       ),
                //     ),
                //   ],
                // ),
                // TimeChart(
                //   data: dataListNegative,
                //   chartType: ChartType.amount,
                //   yAxisLabel: '°',
                //   toolTipLabel: 'Degrees',
                //   useToday: false,
                //   width: 300,
                //   height: 200,
                //   tooltipBackgroundColor: Colors.white,
                //   viewMode: ViewMode.weekly,
                //   barColor: Colors.deepPurple,
                //   detailColor: Colors.blue,
                //   widgetMode: false,
                //   toggleButton: true,
                // ),
                // Padding(
                //   padding: EdgeInsets.only(top: 10, bottom: 10),
                // ),
                const Text('Amount Chart Base'),
                TimeChart(
                  data: dataList,
                  chartType: ChartType.amount,
                  yAxisLabel: 'test',
                  toolTipLabel: 'Degrees',
                  useToday: true,
                  width: 750,
                  height: 200,
                  tooltipBackgroundColor: Colors.white,
                  viewMode: ViewMode.hourly,
                  barColor: Colors.deepPurple,
                  detailColor: Colors.purple,
                  widgetMode: false,
                  toggleButton: false,
                ),
                // Padding(
                //   padding: EdgeInsets.only(top: 10, bottom: 10),
                // ),
                // const Text('Set Duration Chart - Normal'),
                // TimeChart(
                //   data: dataListSingleTimes,
                //   chartType: ChartType.time,
                //   yAxisLabel: '',
                //   toolTipLabel: 'Degrees',
                //   useToday: true,
                //   width: 300,
                //   height: 200,
                //   tooltipBackgroundColor: Colors.white,
                //   viewMode: ViewMode.weekly,
                //   barColor: Colors.deepPurple,
                //   detailColor: Colors.blue,
                //   widgetMode: false,
                //   toggleButton: true,
                // ),
                // Padding(
                //   padding: EdgeInsets.only(top: 10, bottom: 10),
                // ),
                // const Text('Set Duration Chart - Large Gap'),
                // TimeChart(
                //   data: dataListSingleTimesLargeGap,
                //   chartType: ChartType.time,
                //   yAxisLabel: '',
                //   toolTipLabel: ' Drops',
                //   useToday: false,
                //   width: 300,
                //   height: 200,
                //   tooltipBackgroundColor: Colors.white,
                //   viewMode: ViewMode.weekly,
                //   barColor: Colors.deepPurple,
                //   detailColor: Colors.blue,
                //   widgetMode: false,
                //   toggleButton: true,
                //   eventDuration: 25,
                // ),
                // Padding(
                //   padding: EdgeInsets.only(top: 10, bottom: 10),
                // ),
                // const Text('Set Duration Chart - Small Gap'),
                // TimeChart(
                //   data: dataListSingleTimesSmallGap,
                //   chartType: ChartType.time,
                //   yAxisLabel: '',
                //   toolTipLabel: ' Drops',
                //   useToday: false,
                //   width: 300,
                //   height: 200,
                //   tooltipBackgroundColor: Colors.white,
                //   viewMode: ViewMode.weekly,
                //   barColor: Colors.deepPurple,
                //   detailColor: Colors.blue,
                //   widgetMode: false,
                //   toggleButton: true,
                //   eventDuration: 25,
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
