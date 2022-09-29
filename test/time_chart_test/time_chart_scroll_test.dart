// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:time_chart/src/chart.dart';
// import 'package:time_chart/src/components/scroll/my_single_child_scroll_view.dart';
// import 'package:time_chart/time_chart.dart';

// import '../utils/chart_state_utils.dart';

// void main() {
//   group('Time chart scrolling test', () {
//     testWidgets('scroll weekly time chart', (tester) async {
//       tester.binding.window.physicalSizeTestValue = const Size(400, 800);

//       await tester.pumpWidget(MaterialApp(
//         home: TimeChart(
//           data: [
//             8.0,
//             14.0,
//             27.0,
//             22.0,
//             10.0,
//             23.0,
//             21.0,
//             23.0,
//             21.0,
//             0.0,
//             9.0,
//             14.0,
//           ],
//           viewMode: ViewMode.weekly,
//         ),
//       ));
//       await tester.pump();

//       final ChartState chartState = getChartState(tester);
//       final scrollViewFinder = find.byType(MySingleChildScrollView);

//       expect(chartState.topHour, 20);
//       expect(chartState.bottomHour, 14);

//       await tester.drag(scrollViewFinder.last, const Offset(500, 0));
//       // waiting for changing pivot hours
//       await tester.pump(const Duration(seconds: 3));

//       expect(chartState.topHour, 23);
//       expect(chartState.bottomHour, 17);
//     });
//   });
// }
