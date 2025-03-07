////////////////////////////////////////////////////////////////
/// Blink Chart Package
///
/// ToolTipShape Is responsible for the shape of the tooltip.
///
/// The shape of the tooltip is changed for negative amount chart graphs
/// because the arrow was not lining up correctly.
///////////////////////////////////////////////////////////////////

import 'package:flutter/material.dart';

import '../chart_type.dart';
import 'tooltip_overlay.dart';

class TooltipShapeBorder extends ShapeBorder {
  final Direction direction;
  final double arrowWidth;
  final double arrowHeight;
  final double arrowArc;
  final double radius;
  final bool isDateTime;
  final ChartType chartType;

  const TooltipShapeBorder({
    required this.direction,
    required this.chartType,
    this.radius = 6.0,
    this.arrowWidth = kTooltipArrowWidth,
    required this.isDateTime,
    this.arrowHeight = kTooltipArrowHeight,
    this.arrowArc = 0.2,
  }) : assert(arrowArc <= 1.0 && arrowArc >= 0.0);

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.only(bottom: arrowHeight);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    rect = Rect.fromPoints(
        rect.topLeft, rect.bottomRight - Offset(0, arrowHeight));
    final double x = arrowWidth, y = arrowHeight, r = 1 - arrowArc;

    late Offset pivotOffset;
    late double dir;
    switch (direction) {
      case Direction.left:
        pivotOffset = rect.centerRight;
        dir = 1.0;
        break;
      case Direction.right:
        pivotOffset = rect.centerLeft;
        dir = -1.0;
    }

    if (!isDateTime) {
      return Path()
        ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)))
        ..moveTo(pivotOffset.dx, pivotOffset.dy + y / 2)
        ..relativeLineTo(dir * x * r, -y / 2 * r)
        ..relativeQuadraticBezierTo(
            dir * x * (1 - r), -y / 2 * (1 - r), 0, -y * (1 - r))
        ..relativeLineTo(dir * -x * r, -y / 2 * r);
    }
    if (chartType == ChartType.time) {
      return Path()
        ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)))
        ..moveTo(pivotOffset.dx, pivotOffset.dy + 35 + y / 2)
        ..relativeLineTo(dir * x * r, -y / 2 * r)
        ..relativeQuadraticBezierTo(
            dir * x * (1 - r), -y / 2 * (1 - r), 0, -y * (1 - r))
        ..relativeLineTo(dir * -x * r, -y / 2 * r);
    } else {
      return Path()
        ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)))
        ..moveTo(pivotOffset.dx, pivotOffset.dy + y / 2)
        ..relativeLineTo(dir * x * r, -y / 2 * r)
        ..relativeQuadraticBezierTo(
            dir * x * (1 - r), -y / 2 * (1 - r), 0, -y * (1 - r))
        ..relativeLineTo(dir * -x * r, -y / 2 * r);
    }
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}
