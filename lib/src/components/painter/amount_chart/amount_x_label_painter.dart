////////////////////////////////////////////////////////////////
/// Updated 10/10/2022 by Jake Speyer
///
/// AmountXLabelPainter is an extended class from XLabelPainter.
///
/// There is no amount chart specific implementation for this class.
////////////////////////////////////////////////////////////////

import 'package:time_chart/src/components/painter/x_label_painter.dart';

class AmountXLabelPainter extends XLabelPainter {
  AmountXLabelPainter({
    required super.viewMode,
    required super.context,
    required super.dayCount,
    required super.firstValueDateTime,
    required super.repaint,
    required super.scrollController,
  });
}
