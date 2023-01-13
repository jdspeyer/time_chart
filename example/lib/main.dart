////////////////////////////////////////////////////////////////
/// Blink Chart Package
///
/// This is the testing application for the Blink Chart package.
/// There is a lot of commented code for various tests that can be uncommented to run.
///////////////////////////////////////////////////////////////////

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

  // Standard double data set with smaller values
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
    5.7
  ];

  // A doubles data list with negative values.
  final List<double> dataListNegative = [
    15.0,
    -12.0,
    10.0,
    -30.4,
    20.0,
    -89.0,
    -49.3,
    -49.3,
    -49.3
  ];

  // A doubles data list with large values.
  final List<double> dataListLarge = [
    1000.2,
    0,
    1001.0,
    1200.1,
    1000.4,
    1501.0,
    800.7,
    600.2,
    800.3,
    900.7,
    1000.2,
    0,
    1100.0,
    1200.1,
    1000.4,
    1200.6,
    800.7,
    600.2,
    800.3,
    900.7,
    1100.0,
    1200.1,
    1000.4,
    1200.6,
    800.7,
    600.2,
    800.3,
    900.7,
    1100.0,
    1200.1,
    1000.4,
    1200.6,
    800.7,
    600.2,
    800.3,
    900.7,
    1100.0,
    1200.1,
    1000.4,
    1200.6,
    800.7,
    600.2,
    800.3,
    900.7,
  ];

  // A Data List with dateTimeRanges instead of doubles
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

  // A DateTime list (Not datetimerange)
  final List<DateTime> dataListSingleTimes = [
    DateTime(2022, 10, 26, 15, 0),
    DateTime(2022, 10, 26, 14, 0),
    DateTime(2022, 10, 25, 13, 0),
    DateTime(2022, 10, 25, 12, 0),
    DateTime(2022, 10, 25, 10, 0),
    DateTime(2022, 10, 24, 15, 0),
    DateTime(2022, 10, 24, 14, 0),
  ];

  // A DateTime list with small gaps between times to test bar heights.
  final List<DateTime> dataListSingleTimesSmallGap = [
    DateTime(2022, 10, 26, 15, 0),
    DateTime(2022, 10, 26, 14, 0),
    DateTime(2022, 10, 25, 15, 0),
    DateTime(2022, 10, 25, 14, 0),
    DateTime(2022, 10, 24, 15, 0),
    DateTime(2022, 10, 24, 14, 0),
  ];

  // A DateTime list with large gaps between times to test bar heights.
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

  // List of pure 0 values.
  final List<double> dataListEmpty = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];

  final List<DateTimeRange> emptyDataList = [];

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
                const Text('Amount Chart Example'),
                TimeChart(
                  data: dataList,
                  chartType: ChartType.amount,
                  yAxisLabel: '',
                  toolTipLabel: '',
                  useToday: false,
                  width: 350,
                  height: 200,
                  tooltipBackgroundColor: Colors.white,
                  viewMode: ViewMode.hourly,
                  barColor: Colors.deepPurple,
                  detailColor: Colors.purple,
                  widgetMode: false,
                  toggleButton: false,
                  eventDuration: 5,
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
