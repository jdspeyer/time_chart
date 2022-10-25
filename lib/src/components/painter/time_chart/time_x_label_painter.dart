////////////////////////////////////////////////////////////////
/// Updated 10/10/2022 by Jake Speyer
///
/// TimeXLabelPainter is an extended class from XLabelPainter.
///
/// There is no time chart specific implementation for this class.
////////////////////////////////////////////////////////////////

import 'package:time_chart/src/components/painter/x_label_painter.dart';

class TimeXLabelPainter extends XLabelPainter {
  TimeXLabelPainter({
    required super.viewMode,
    required super.context,
    required super.dayCount,
    required super.firstValueDateTime,
    required super.repaint,
    required super.scrollController,
    required super.isFirstDataMovedNextDay,
    // required super.widgetMode,
  });
}
