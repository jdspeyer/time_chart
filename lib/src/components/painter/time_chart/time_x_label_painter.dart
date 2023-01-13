////////////////////////////////////////////////////////////////
/// Blink Chart Package
///
///
/// TimeXLabelPainter is an extended class from XLabelPainter.
///
/// There is no time chart specific implementation for this class.
////////////////////////////////////////////////////////////////

import 'package:time_chart/src/components/painter/x_label_painter.dart';

class TimeXLabelPainter extends XLabelPainter {
  TimeXLabelPainter({
    required super.xAxisWidth,
    required super.viewMode,
    required super.widgetMode,
    required super.context,
    required super.dayCount,
    required super.firstValueDateTime,
    required super.repaint,
    required super.scrollController,
    required super.isFirstDataMovedNextDay,
  });
}
