import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_chart/src/chart.dart';
import 'package:time_chart/time_chart.dart';

void main() {
  group('AmountChart y labels', () {
    testWidgets('have 4 hours intervals if max amount is over 8 hours',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: TimeChart(
          chartType: ChartType.amount,
          data: [
            2.0,
            5.0,
          ],
        ),
      ));

      await expectLater(
        find.byType(Chart),
        matchesGoldenFile('golden/y_label_golden1.png'),
        skip: !Platform.isMacOS,
      );
    });

    testWidgets('have 2 hours intervals if max amount is in range (4, 8] hours',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: TimeChart(
          chartType: ChartType.amount,
          data: [2.0, 5.0],
        ),
      ));

      await expectLater(
        find.byType(Chart),
        matchesGoldenFile('golden/y_label_golden2.png'),
        skip: !Platform.isMacOS,
      );
    });

    testWidgets('have 1 hour interval if max amount is below 4 hours',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: TimeChart(
          chartType: ChartType.amount,
          data: [2.0, 5.0],
        ),
      ));

      await expectLater(
        find.byType(Chart),
        matchesGoldenFile('golden/y_label_golden3.png'),
        skip: !Platform.isMacOS,
      );
    });
  });
}
