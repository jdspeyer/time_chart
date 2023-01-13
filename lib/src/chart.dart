////////////////////////////////////////////////////////////////
/// Blink Chart Package
///
/// Chart is responsible for assembling the core TimeChart and AmountCharts.
///////////////////////////////////////////////////////////////////

import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:touchable/touchable.dart';

import '../time_chart.dart';
import 'components/painter/amount_chart/amount_x_label_painter.dart';
import 'components/painter/amount_chart/amount_y_label_painter.dart';
import 'components/painter/time_chart/time_x_label_painter.dart';
import 'components/painter/border_line_painter.dart';
import 'components/scroll/custom_scroll_physics.dart';
import 'components/scroll/my_single_child_scroll_view.dart';
import 'components/painter/chart_engine.dart';
import 'components/painter/time_chart/time_y_label_painter.dart';
import 'components/utils/time_assistant.dart';
import 'components/utils/time_data_processor.dart';
import 'components/painter/amount_chart/amount_bar_painter.dart';
import 'components/painter/time_chart/time_bar_painter.dart';
import 'components/tooltip/tooltip_overlay.dart';
import 'components/tooltip/tooltip_size.dart';
import 'components/translations/translations.dart';
import 'components/utils/context_utils.dart';
import './components/utils/chart_toggle.dart';

class Chart<T> extends StatefulWidget {
  Chart({
    Key? key,
    required this.chartType,
    required this.yAxisLabel,
    required this.toolTipLabel,
    required this.useToday,
    required this.width,
    required this.height,
    required this.barColor,
    required this.detailColor,
    required this.data,
    required this.dataTime,
    required this.dataDouble,
    required this.timeChartSizeAnimationDuration,
    required this.tooltipDuration,
    required this.tooltipBackgroundColor,
    required this.tooltipStart,
    required this.tooltipEnd,
    required this.activeTooltip,
    required this.viewMode,
    required this.defaultPivotHour,
    required this.widgetMode, // JP -- added this for simplified widgets
    required this.toggleButton,
    required this.isDateTime,
  }) : super(key: key);

  ChartType chartType;
  final String yAxisLabel;
  final String toolTipLabel;
  final bool useToday;
  final double width;
  final double height;
  final Color? barColor;
  final Color? detailColor;
  var data;
  var dataTime;
  var dataDouble;
  final Duration timeChartSizeAnimationDuration;
  final Duration tooltipDuration;
  final Color? tooltipBackgroundColor;
  final String tooltipStart;
  final String tooltipEnd;
  final bool activeTooltip;
  final ViewMode viewMode;
  final int defaultPivotHour;
  final bool widgetMode; // JP -- added this for simplified widgets
  final bool toggleButton;
  final bool isDateTime;

  @override
  ChartState createState() => ChartState();
}

class ChartState extends State<Chart>
    with TickerProviderStateMixin, TimeDataProcessor {
  static const Duration _tooltipFadeInDuration = Duration(milliseconds: 100);
  static const Duration _tooltipFadeOutDuration = Duration(milliseconds: 75);
  CustomScrollPhysics? _scrollPhysics;
  final _scrollControllerGroup = LinkedScrollControllerGroup();
  late final ScrollController _barController;
  late final ScrollController _xLabelController;
  late final AnimationController _sizeController;
  late final Animation<double> _sizeAnimation;

  Timer? _pivotHourUpdatingTimer;

  /// Used to display tooltips.
  OverlayEntry? _overlayEntry;

  /// Set how long the tooltip is floating.
  Timer? _tooltipHideTimer;

  Rect? _currentVisibleTooltipRect;

  /// Handles the fade in out animation of tooltips.
  late final AnimationController _tooltipController;

  /// It is the sum of the width of the bar and the blank space on either side of it.
  double? _blockWidth;

  /// The height of the entire graph at the start of the animation
  late double _animationBeginHeight = widget.height;

  /// Height value to start at the correct position when starting the animation
  double? _heightForAlignTop;

  final ValueNotifier<double> _scrollOffsetNotifier = ValueNotifier(0);

  double _previousScrollOffset = 0;

  @override
  void initState() {
    super.initState();

    _barController = _scrollControllerGroup.addAndGet();
    _xLabelController = _scrollControllerGroup.addAndGet();

    _sizeController = AnimationController(
      duration: widget.timeChartSizeAnimationDuration,
      vsync: this,
    );
    _tooltipController = AnimationController(
      duration: _tooltipFadeInDuration,
      reverseDuration: _tooltipFadeOutDuration,
      vsync: this,
    );

    _sizeAnimation = CurvedAnimation(
      parent: _sizeController,
      curve: Curves.easeInOut,
    );

    // Listen to global pointer events so that we can hide a tooltip immediately
    // if some other control is clicked on.
    GestureBinding.instance.pointerRouter.addGlobalRoute(_handlePointerEvent);

    _addScrollNotifier();
    processData(widget, getFirstItemDate());
  }

  @override
  void didUpdateWidget(covariant Chart oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.data != widget.data) {
      processData(widget, getFirstItemDate());
    }
  }

  @override
  void dispose() {
    _removeEntry();
    _barController.dispose();
    _xLabelController.dispose();
    _sizeController.dispose();
    _tooltipController.dispose();
    _cancelTimer();
    GestureBinding.instance.pointerRouter
        .removeGlobalRoute(_handlePointerEvent);
    super.dispose();
  }

  // JP -- Changed
  DateTime getFirstItemDate({Duration addition = Duration.zero}) {
    return widget.chartType == ChartType.amount
        ? DateTime.now()
        : DateTime.now();
  }

  void _addScrollNotifier() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final minDifference = _blockWidth!;

      _scrollControllerGroup.addOffsetChangedListener(() {
        final difference =
            (_scrollControllerGroup.offset - _previousScrollOffset).abs();

        if (difference >= minDifference) {
          _scrollOffsetNotifier.value = _scrollControllerGroup.offset;
          _previousScrollOffset = _scrollControllerGroup.offset;
        }
      });
    });
  }

  void _handlePointerEvent(PointerEvent event) {
    if (_overlayEntry == null) return;
    if (event is PointerDownEvent) _removeEntry();
  }

  /// A tooltip is displayed when the corresponding bar is clicked.
  ///
  /// The position is the distance away from the left in the x-axis direction and the top in the y-axis direction.
  ///
  /// Use a callback to manage overlay entries here.
  void _tooltipCallback({
    // JP -- Changed
    // double? range,
    DateTimeRange? range,
    double? amount,
    // JP -- Changed
    DateTime? amountDate,
    required Rect rect,
    required ScrollPosition position,
    required double barWidth,
  }) {
    if (!widget.activeTooltip) return;

    // Ignore the tooltip of a bar that is out of the range of the currently visible graph.
    final viewRange = _blockWidth! * widget.viewMode.dayCount;
    final actualPosition = position.maxScrollExtent - position.pixels;
    if (rect.left < actualPosition || actualPosition + viewRange < rect.left) {
      return;
    }

    // Ignore if the currently visible tooltip is called again.
    if ((_tooltipHideTimer?.isActive ?? false) &&
        _currentVisibleTooltipRect == rect) return;
    _currentVisibleTooltipRect = rect;

    // Removes vibrations from the chart. Uncomment to enable.
    // HapticFeedback.vibrate();
    _removeEntry();

    _tooltipController.forward();
    _overlayEntry = OverlayEntry(
      builder: (_) => _buildOverlay(
        rect,
        position,
        barWidth,
        range: range, // JP -- Changed
        amount: amount,
        amountDate: amountDate, // JP -- Changed
      ),
    );

    Overlay.of(context)!.insert(_overlayEntry!);
    _tooltipHideTimer = Timer(widget.tooltipDuration, _removeEntry);
  }

  double get _tooltipPadding => kTooltipArrowWidth + 2.0;

  Widget _buildOverlay(
    Rect rect,
    ScrollPosition position,
    double barWidth, {
    // // JP -- Changed
    // double? range,
    DateTimeRange? range,
    double? amount,
    // JP -- Changed
    // double? amountDate,
    DateTime? amountDate,
  }) {
    var chartType = amount == null ? ChartType.time : ChartType.amount;
    // 현재 위젯의 위치를 얻는다.
    final widgetOffset = context.getRenderBoxOffset()!;
    final tooltipSize =
        chartType == ChartType.time ? kTimeTooltipSize : kAmountTooltipSize;

    ///
    /// JS -- Changed
    /// Not the cleanest code... needs a refactor
    /// But essentially adds control for the tooltip to appear at the bottom of
    /// negative bars.
    final candidateTop = (chartType == ChartType.time)
        ? rect.top +
            widgetOffset.dy -
            tooltipSize.height / 2 +
            kTimeChartTopPadding +
            (chartType == ChartType.time
                ? (rect.bottom - rect.top) / 2
                : kTooltipArrowHeight / 2)
        : (amount! > 0)
            ? rect.top +
                widgetOffset.dy -
                tooltipSize.height / 2 +
                kTimeChartTopPadding +
                (chartType == ChartType.time
                    ? (rect.bottom - rect.top) / 2
                    : kTooltipArrowHeight / 2)
            : rect.bottom +
                widgetOffset.dy -
                tooltipSize.height / 2 +
                kTimeChartTopPadding -
                (chartType == ChartType.time
                    ? (rect.bottom - rect.top) / 2
                    : kTooltipArrowHeight / 2);

    final scrollPixels = position.maxScrollExtent - position.pixels;
    final localLeft = rect.left + widgetOffset.dx - scrollPixels;
    final tooltipTop = max(candidateTop, 0.0);

    Direction direction = Direction.left;
    double tooltipLeft = localLeft - tooltipSize.width - _tooltipPadding;
    if (tooltipLeft < widgetOffset.dx) {
      direction = Direction.right;
      tooltipLeft = localLeft + barWidth + _tooltipPadding;
    }

    return Positioned(
      // 바 옆에 [tooltip]을 띄운다.
      top: tooltipTop,
      left: tooltipLeft,
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: _tooltipController,
          curve: Curves.fastOutSlowIn,
        ),
        child: TooltipOverlay(
          backgroundColor: widget.tooltipBackgroundColor,
          chartType: chartType,
          yAxisLabel: widget.yAxisLabel,
          toolTipLabel: widget.toolTipLabel,
          isDateTime: widget.isDateTime,
          useToday: widget.useToday,
          bottomHour: bottomHour,
          timeRange: range,
          amountHour: amount,
          amountDate: amountDate,
          direction: direction,
          start: widget.tooltipStart,
          end: widget.tooltipEnd,
        ),
      ),
    );
  }

  /// 현재 존재하는 툴팁을 제거한다.
  void _removeEntry() {
    _tooltipHideTimer?.cancel();
    _tooltipHideTimer = null;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _cancelTimer() {
    _pivotHourUpdatingTimer?.cancel();
  }

  double _getRightMargin(BuildContext context) {
    final translations = Translations(context);
    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: translations.formatHourOnly(12),
        style: Theme.of(context)
            .textTheme
            .bodyText2!
            .copyWith(color: Colors.white38),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    return widget.widgetMode ? tp.width - 10 : tp.width + kYLabelMargin;
  }

  void _handlePanDown(_) {
    _scrollPhysics!.setPanDownPixels(_barController.position.pixels);
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (widget.chartType == ChartType.amount) return false;

    if (notification is ScrollStartNotification) {
      _cancelTimer();
    } else if (notification is ScrollEndNotification) {
      _pivotHourUpdatingTimer =
          Timer(const Duration(milliseconds: 800), timerCallback);
    }
    return true;
  }

  void timerCallback() {
    final beforeIsFirstDataMovedNextDay = isFirstDataMovedNextDay;
    final beforeTopHour = topHour;
    final beforeBottomHour = bottomHour;

    final blockIndex =
        getCurrentBlockIndex(_barController.position, _blockWidth!).toInt();
    final needsToAdaptScrollPosition =
        blockIndex > 0 && isFirstDataMovedNextDay;
    final scrollPositionDuration = Duration(
      days: -blockIndex + (needsToAdaptScrollPosition ? 1 : 0),
    );

    processData(widget, getFirstItemDate(addition: scrollPositionDuration));

    if (topHour == beforeTopHour && bottomHour == beforeBottomHour) return;

    if (beforeIsFirstDataMovedNextDay != isFirstDataMovedNextDay) {
      final add = isFirstDataMovedNextDay ? _blockWidth! : -_blockWidth!;

      _barController.jumpTo(_barController.position.pixels + add);
      _scrollPhysics!.addPanDownPixels(add);
      _scrollPhysics!.setDayCount(dayCount!);
    }

    runHeightAnimation(beforeTopHour!, beforeBottomHour!);
  }

  double get heightWithoutLabel => widget.height - kXLabelHeight;

  void runHeightAnimation(int beforeTopHour, int beforeBottomHour) {
    final beforeDiff =
        hourDiffBetween(beforeTopHour, beforeBottomHour).toDouble();
    final currentDiff = hourDiffBetween(topHour, bottomHour).toDouble();

    final candidateUpward = diffBetween(beforeTopHour, topHour!);
    final candidateDownWard = -diffBetween(topHour!, beforeTopHour);

    final topDiff =
        isDirUpward(beforeTopHour, beforeBottomHour, topHour!, bottomHour!)
            ? candidateUpward
            : candidateDownWard;

    setState(() {
      _animationBeginHeight =
          (currentDiff / beforeDiff) * heightWithoutLabel + kXLabelHeight;
      _heightForAlignTop = (_animationBeginHeight - widget.height) / 2 +
          (topDiff / beforeDiff) * heightWithoutLabel;
    });
    _sizeController.reverse(from: 1.0);
  }

  @override
  Widget build(BuildContext context) {
    int viewModeLimitDay = widget.viewMode.dayCount;
    var key = ValueKey((topHour ?? 0) + (bottomHour ?? 1) * 100);

    double outerHeight = kTimeChartTopPadding + widget.height;
    double yLabelWidth = _getRightMargin(context);
    double totalWidth = widget.width;

    _blockWidth ??= (totalWidth - yLabelWidth) / viewModeLimitDay;

    final innerSize = Size(
      _blockWidth! * max(dayCount!, viewModeLimitDay),
      double.infinity,
    );
    _scrollPhysics ??= CustomScrollPhysics(
      blockWidth: _blockWidth!,
      viewMode: widget.viewMode,
      scrollPhysicsState: ScrollPhysicsState(dayCount: dayCount!),
    );
    return Stack(
      children: [
        GestureDetector(
          onPanDown: _handlePanDown,
          child: Stack(
            alignment: Alignment.topLeft,
            children: [
              SizedBox(
                width: totalWidth,
                height: outerHeight,
              ),
              _buildAnimatedBox(
                topPadding: kTimeChartTopPadding,
                width: totalWidth,
                builder: (context, topPosition) => CustomPaint(
                  key: key,
                  size: Size(totalWidth, double.infinity),
                  painter: buildYLabelPainter(context, topPosition),
                ),
              ),
              Positioned(
                top: kTimeChartTopPadding,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SizedBox(
                      width: totalWidth - yLabelWidth,
                      height: widget.height,
                    ),
                    Positioned.fill(
                      child: CustomPaint(
                          painter: BorderLinePainter(
                              widgetMode: widget
                                  .widgetMode)), // JP -- added this for simplified widgets
                    ),
                    Positioned.fill(
                      child: NotificationListener<ScrollNotification>(
                        onNotification: _handleScrollNotification,
                        child: _buildHorizontalScrollView(
                          key: key,
                          controller: _xLabelController,
                          child: CustomPaint(
                            size: innerSize,
                            painter: _buildXLabelPainter(context),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: kTimeChartTopPadding,
                child: Stack(
                  children: [
                    SizedBox(
                      width: totalWidth - yLabelWidth,
                      height: widget.height - kXLabelHeight,
                    ),
                    _buildAnimatedBox(
                      bottomPadding: kXLabelHeight,
                      width: totalWidth - yLabelWidth,
                      child: _buildHorizontalScrollView(
                        key: key,
                        controller: _barController,

                        //  THIS IS WHAT BUILDS THE GRAPHS
                        child: CanvasTouchDetector(
                          gesturesToOverride: const [
                            GestureType.onTapUp,
                            GestureType.onLongPressStart,
                            GestureType.onLongPressMoveUpdate,
                          ],
                          builder: (context) => CustomPaint(
                            size: innerSize,
                            painter: buildBarPainter(context),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (widget.toggleButton) ChartToggle(this),
      ],
    );
  }

  Widget _buildHorizontalScrollView({
    required Widget child,
    required Key key,
    required ScrollController? controller,
  }) {
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (OverscrollIndicatorNotification overScroll) {
        overScroll.disallowIndicator();
        return false;
      },
      child: MySingleChildScrollView(
        reverse: true,
        scrollDirection: Axis.horizontal,
        controller: controller,
        physics: _scrollPhysics,
        child: RepaintBoundary(
          key: key,
          child: child,
        ),
      ),
    );
  }

  Widget _buildAnimatedBox({
    Widget? child,
    required double width,
    double topPadding = 0.0,
    double bottomPadding = 0.0,
    Function(BuildContext, double)? builder,
  }) {
    assert(
        (child != null && builder == null) || child == null && builder != null);

    final heightAnimation = Tween<double>(
      begin: widget.height,
      end: _animationBeginHeight,
    ).animate(_sizeAnimation);
    final heightForAlignTopAnimation = Tween<double>(
      begin: 0,
      end: _heightForAlignTop,
    ).animate(_sizeAnimation);

    return AnimatedBuilder(
      animation: _sizeAnimation,
      builder: (context, child) {
        final topPosition = (widget.height - heightAnimation.value) / 2 +
            heightForAlignTopAnimation.value +
            topPadding;
        return Positioned(
          right: 0,
          top: topPosition,
          child: Container(
            height: heightAnimation.value - bottomPadding,
            width: width,
            alignment: Alignment.center,
            child: child ??
                builder!(
                  context,
                  topPosition - kTimeChartTopPadding,
                ),
          ),
        );
      },
      child: child,
    );
  }

  CustomPainter buildYLabelPainter(BuildContext context, double topPosition) {
    switch (widget.chartType) {
      case ChartType.time:
        return TimeYLabelPainter(
          xAxisWidth: widget.width,
          context: context,
          viewMode: widget.viewMode,
          topHour: topHour!,
          bottomHour: bottomHour!,
          chartHeight: widget.height,
          topPosition: topPosition,
          widgetMode: widget.widgetMode,
        );
      case ChartType.amount:
        return AmountYLabelPainter(
          xAxisWidth: widget.width,
          context: context,
          viewMode: widget.viewMode,
          topHour: topHour!,
          bottomHour: bottomHour!,
          yAxisLabel: widget.yAxisLabel,
          widgetMode:
              widget.widgetMode, // JP -- added this for simplified widgets
        );
    }
  }

  CustomPainter _buildXLabelPainter(BuildContext context) {
    final firstValueDateTime = widget.useToday
        ? DateTime.now()
        : DateTime.now().subtract(Duration(days: 1));
    switch (widget.chartType) {
      case ChartType.time:
        return TimeXLabelPainter(
          xAxisWidth: widget.width,
          widgetMode: widget.widgetMode,
          scrollController: _xLabelController,
          repaint: _scrollOffsetNotifier,
          context: context,
          viewMode: widget.viewMode,
          firstValueDateTime: firstValueDateTime,
          dayCount: dayCount,
          isFirstDataMovedNextDay: isFirstDataMovedNextDay,
        );
      case ChartType.amount:
        return AmountXLabelPainter(
          xAxisWidth: widget.width,
          scrollController: _xLabelController,
          repaint: _scrollOffsetNotifier,
          context: context,
          viewMode: widget.viewMode,
          firstValueDateTime: firstValueDateTime,
          dayCount: dayCount,
          widgetMode:
              widget.widgetMode, // JP -- added this for simplified widgets
        );
    }
  }

  CustomPainter buildBarPainter(BuildContext context) {
    // print(widget.chartType);
    // print(widget.data);
    if (widget.data is List<DateTimeRange>) {
      return TimeBarPainter(
        xAxisWidth: widget.width,
        scrollController: _barController,
        repaint: _scrollOffsetNotifier,
        context: context,
        tooltipCallback: _tooltipCallback,
        useToday: widget.useToday,
        dataList: processedDataTime,
        barColor: widget.barColor,
        topHour: topHour!,
        bottomHour: bottomHour!,
        dayCount: dayCount,
        widgetMode: widget.widgetMode,
        viewMode: widget.viewMode, // JP -- added this for simplified widgets
      );
    } else {
      return AmountBarPainter(
        xAxisWidth: widget.width,
        scrollController: _barController,
        repaint: _scrollOffsetNotifier,
        context: context,
        dataList: processedData,
        useToday: widget.useToday,
        barColor: widget.barColor,
        topHour: topHour!,
        bottomHour: bottomHour!,
        tooltipCallback: _tooltipCallback,
        dayCount: dayCount,
        viewMode: widget.viewMode,
        widgetMode:
            widget.widgetMode, // JP -- added this for simplified widgets
      );
    }
  }
}
