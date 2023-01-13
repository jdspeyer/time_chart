////////////////////////////////////////////////////////////////
/// Blink Chart Package
///
/// Chart Engine is one of the core abstract classes that is implemented by various
/// painters and tooltips to provide touch and painting functionality.
///
/// This has been the least modified file within the core package.
///////////////////////////////////////////////////////////////////

import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../view_mode.dart';
import '../translations/translations.dart';

const double kYLabelMargin = 12.0;
const int _kPivotYLabelHour = 12;

const double kXLabelHeight = 32.0;

const double kLineStrokeWidth = 0.8;

const double kBarWidthRatio = 0.7;
const double kBarPaddingWidthRatio = (1 - kBarWidthRatio) / 2;

const Color kLineColor1 = Color(0x44757575);
const Color kLineColor2 = Color(0x77757575);
const Color kLineColor3 = Color(0xAA757575);
const Color kTextColor = Color(0xFF757575);

abstract class ChartEngine extends CustomPainter {
  static const int toleranceDay = 1;

  ChartEngine({
    this.scrollController,
    int? dayCount,
    required this.viewMode,
    this.firstValueDateTime,
    required this.context,
    required this.xAxisWidth,
    required this.widgetMode, // JP -- added this for simplified widgets for simplified widgets
    super.repaint,
  })  : dayCount = math.max(dayCount ?? -1, viewMode.dayCount),
        translations = Translations(context);

  final ScrollController? scrollController;
  final int dayCount;
  final bool
      widgetMode; // JP -- added this for simplified widgets for simplified widgets
  final ViewMode viewMode;
  // JP -- Changed
  // final double? firstValueDateTime;
  final DateTime? firstValueDateTime;
  final BuildContext context;
  final Translations translations;
  final double xAxisWidth;

  int get currentDayFromScrollOffset {
    if (!scrollController!.hasClients) return 0;
    return (scrollController!.offset / blockWidth!).floor();
  }

  /// This is the size of the gap where the label on the right side of the entire graph will fit.
  double get rightMargin => _rightMargin;

  /// This is the size of the bar width.
  double get barWidth => _barWidth;

  /// This is a value to properly align the bar.
  double get paddingForAlignedBar => _paddingForAlignedBar;

  /// (The width of the space between the bars + the width of the bar) => The size of the block width.
  double? get blockWidth => _blockWidth;

  TextTheme get textTheme => Theme.of(context).textTheme;

  double _rightMargin = 0.0;
  double _barWidth = 0.0;
  double _paddingForAlignedBar = 0.0;
  double? _blockWidth;

  void setRightMargin() {
    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: translations.formatHourOnly(_kPivotYLabelHour),
        style: textTheme.bodyText2!.copyWith(color: kTextColor),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    _rightMargin = widgetMode ? tp.width - 2 : tp.width + kYLabelMargin;
  }

  void setDefaultValue(Size size) {
    setRightMargin();
    _blockWidth = size.width / dayCount;
    _barWidth = blockWidth! * kBarWidthRatio;
    // [padding] to align the bar to the center
    _paddingForAlignedBar = blockWidth! * kBarPaddingWidthRatio;
  }
}
