////////////////////////////////////////////////////////////////
/// Blink Chart Package
///
/// AmountXLabelPainter is an extended class from XLabelPainter.
///
/// There is no amount chart specific implementation for this class.
////////////////////////////////////////////////////////////////

import 'package:time_chart/src/components/painter/x_label_painter.dart';

class AmountXLabelPainter extends XLabelPainter {
  AmountXLabelPainter({
    required super.xAxisWidth,
    required super.viewMode,
    required super.context,
    required super.dayCount,
    required super.firstValueDateTime,
    required super.repaint,
    required super.scrollController,
    required super.widgetMode,
  });
}
