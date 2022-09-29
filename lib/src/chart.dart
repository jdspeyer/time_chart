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

class Chart extends StatefulWidget {
  const Chart({
    Key? key,
    required this.chartType,
    required this.yAxisLabel,
    required this.toolTipLabel,
    required this.useToday,
    required this.width,
    required this.height,
    required this.barColor,
    required this.data,
    required this.timeChartSizeAnimationDuration,
    required this.tooltipDuration,
    required this.tooltipBackgroundColor,
    required this.tooltipStart,
    required this.tooltipEnd,
    required this.activeTooltip,
    required this.viewMode,
    required this.defaultPivotHour,
  }) : super(key: key);

  final ChartType chartType;
  final String yAxisLabel;
  final String toolTipLabel;
  final bool useToday;
  final double width;
  final double height;
  final Color? barColor;
  final List<double> data;
  final Duration timeChartSizeAnimationDuration;
  final Duration tooltipDuration;
  final Color? tooltipBackgroundColor;
  final String tooltipStart;
  final String tooltipEnd;
  final bool activeTooltip;
  final ViewMode viewMode;
  final int defaultPivotHour;

  @override
  ChartState createState() => ChartState();
}

class ChartState extends State<Chart> with TickerProviderStateMixin {
  static const Duration _tooltipFadeInDuration = Duration(milliseconds: 150);
  static const Duration _tooltipFadeOutDuration = Duration(milliseconds: 75);

  CustomScrollPhysics? _scrollPhysics;
  final _scrollControllerGroup = LinkedScrollControllerGroup();
  late final ScrollController _barController;
  late final ScrollController _xLabelController;
  late final AnimationController _sizeController;
  late final Animation<double> _sizeAnimation;

  Timer? _pivotHourUpdatingTimer;

  /// 툴팁을 띄우기 위해 사용한다.
  OverlayEntry? _overlayEntry;

  /// 툴팁이 떠있는 시간을 정한다.
  Timer? _tooltipHideTimer;

  Rect? _currentVisibleTooltipRect;

  /// 툴팁의 fadeIn out 애니메이션을 다룬다.
  late final AnimationController _tooltipController;

  /// 바와 그 양 옆의 여백의 너비를 더한 값이다.
  double? _blockWidth;

  /// 에니메이션 시작시 전체 그래프의 높이
  late double _animationBeginHeight = widget.height;

  /// 에니메이션 시작시 올바른 위치에서 시작하기 위한 높이 값
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

    //processData(widget, _getFirstItemDate());
  }

  @override
  void didUpdateWidget(covariant Chart oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.data != widget.data) {
      //processData(widget, _getFirstItemDate());
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

  DateTime _getFirstItemDate({Duration addition = Duration.zero}) {
    return DateTime.now();
  }
  // DateTime _getFirstItemDate({Duration addition = Duration.zero}) {
  //   return widget.data.isEmpty
  //       ? DateTime.now()
  //       : widget.data.first.end.dateWithoutTime().add(addition);
  // }

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

  /// 해당 바(bar)를 눌렀을 경우 툴팁을 띄운다.
  ///
  /// 위치는 x축 방향 left, y축 방향 top 만큼 떨어진 위치이다.
  ///
  /// 오버레이 엔트리를 이곳에서 관리하기 위해 콜백하여 이용한다.
  void _tooltipCallback({
    DateTimeRange? range,
    double? amount,
    DateTime? amountDate,
    required Rect rect,
    required ScrollPosition position,
    required double barWidth,
  }) {
    assert(range != null || amount != null);

    if (!widget.activeTooltip) return;

    // 현재 보이는 그래프의 범위를 벗어난 바의 툴팁은 무시한다.
    final viewRange = _blockWidth! * widget.viewMode.dayCount;
    final actualPosition = position.maxScrollExtent - position.pixels;
    if (rect.left < actualPosition || actualPosition + viewRange < rect.left) {
      return;
    }

    // 현재 보이는 툴팁이 다시 호출되면 무시한다.
    if ((_tooltipHideTimer?.isActive ?? false) &&
        _currentVisibleTooltipRect == rect) return;
    _currentVisibleTooltipRect = rect;

    HapticFeedback.vibrate();
    _removeEntry();

    _tooltipController.forward();
    _overlayEntry = OverlayEntry(
      builder: (_) => _buildOverlay(
        rect,
        position,
        barWidth,
        range: range,
        amount: amount,
        amountDate: amountDate,
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
    DateTimeRange? range,
    double? amount,
    DateTime? amountDate,
  }) {
    final chartType = amount == null ? ChartType.time : ChartType.amount;
    // 현재 위젯의 위치를 얻는다.
    final widgetOffset = context.getRenderBoxOffset()!;
    final tooltipSize =
        chartType == ChartType.time ? kTimeTooltipSize : kAmountTooltipSize;

    final candidateTop = rect.top +
        widgetOffset.dy -
        tooltipSize.height / 2 +
        kTimeChartTopPadding +
        (chartType == ChartType.time
            ? (rect.bottom - rect.top) / 2
            : kTooltipArrowHeight / 2);

    final scrollPixels = position.maxScrollExtent - position.pixels;
    final localLeft = rect.left + widgetOffset.dx - scrollPixels;
    final tooltipTop = max(candidateTop, 0.0);

    Direction direction = Direction.left;
    double tooltipLeft = localLeft - tooltipSize.width - _tooltipPadding;
    // 툴팁을 바의 오른쪽에 배치해야 하는 경우
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
          bottomHour: 0,
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
    return tp.width + kYLabelMargin;
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
          Timer(const Duration(milliseconds: 800), _timerCallback);
    }
    return true;
  }

  void _timerCallback() {
    final beforeIsFirstDataMovedNextDay = false;
    final beforeTopHour = widget.data.reduce(max).toInt();
    final beforeBottomHour = 0;

    final blockIndex =
        getCurrentBlockIndex(_barController.position, _blockWidth!).toInt();
    final needsToAdaptScrollPosition = blockIndex > 0 && false;
    final scrollPositionDuration = Duration(
      days: -blockIndex + (needsToAdaptScrollPosition ? 1 : 0),
    );

    //processData(widget, _getFirstItemDate(addition: scrollPositionDuration));

    if (widget.data.reduce(max).toInt() == beforeTopHour &&
        0 == beforeBottomHour) return;

    if (beforeIsFirstDataMovedNextDay != false) {
      // 하루가 추가 혹은 삭제되는 경우 x축 방향으로 발생하는 차이를 해결할 값이다.
      final add = false ? _blockWidth! : -_blockWidth!;

      _barController.jumpTo(_barController.position.pixels + add);
      _scrollPhysics!.addPanDownPixels(add);
      _scrollPhysics!.setDayCount(widget.data.length);
    }

    _runHeightAnimation(widget.data.reduce(max).toInt(), beforeBottomHour!);
  }

  double get heightWithoutLabel => widget.height - kXLabelHeight;

  void _runHeightAnimation(int beforeTopHour, int beforeBottomHour) {
    final beforeDiff =
        hourDiffBetween(beforeTopHour, beforeBottomHour).toDouble();
    final currentDiff =
        hourDiffBetween(widget.data.reduce(max).toInt(), 0).toDouble();

    final candidateUpward =
        diffBetween(beforeTopHour, widget.data.reduce(max).toInt());
    final candidateDownWard =
        -diffBetween(widget.data.reduce(max).toInt(), beforeTopHour);

    // (candidate)중에서 current top-bottom hour 범위에 들어오는 것을 선택한다.
    final topDiff = isDirUpward(
            beforeTopHour, beforeBottomHour, widget.data.reduce(max).toInt(), 0)
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
    final int viewModeLimitDay = widget.viewMode.dayCount;
    final key =
        ValueKey((widget.data.reduce(max).toInt() ?? 0) + (0 ?? 1) * 100);

    final double outerHeight = kTimeChartTopPadding + widget.height;
    final double yLabelWidth = _getRightMargin(context);
    final double totalWidth = widget.width;

    _blockWidth ??= (totalWidth - yLabelWidth) / viewModeLimitDay;

    final innerSize = Size(
      _blockWidth! * max(widget.data.length, viewModeLimitDay),
      double.infinity,
    );
    _scrollPhysics ??= CustomScrollPhysics(
      blockWidth: _blockWidth!,
      viewMode: widget.viewMode,
      scrollPhysicsState: ScrollPhysicsState(dayCount: widget.data.length),
    );
    return GestureDetector(
      onPanDown: _handlePanDown,
      child: Stack(
        alignment: Alignment.topLeft,
        children: [
          // # #
          // # #
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
              painter: _buildYLabelPainter(context, topPosition),
            ),
          ),
          //-----
          // # .
          // # .
          Positioned(
            top: kTimeChartTopPadding,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                SizedBox(
                  width: totalWidth - yLabelWidth,
                  height: widget.height,
                ),
                const Positioned.fill(
                  child: CustomPaint(painter: BorderLinePainter()),
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
          //-----
          // # .
          // . .
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
                    child: CanvasTouchDetector(
                      gesturesToOverride: const [
                        GestureType.onTapUp,
                        GestureType.onLongPressStart,
                        GestureType.onLongPressMoveUpdate,
                      ],
                      builder: (context) => CustomPaint(
                        size: innerSize,
                        painter: _buildBarPainter(context),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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

  CustomPainter _buildYLabelPainter(BuildContext context, double topPosition) {
    switch (widget.chartType) {
      case ChartType.time:
        return TimeYLabelPainter(
          context: context,
          viewMode: widget.viewMode,
          topHour: widget.data.reduce(max).toInt(),
          bottomHour: 0,
          chartHeight: widget.height,
          topPosition: topPosition,
        );
      case ChartType.amount:
        return AmountYLabelPainter(
            context: context,
            viewMode: widget.viewMode,
            topHour: widget.data.reduce(max).toInt(),
            bottomHour: 0,
            yAxisLabel: widget.yAxisLabel);
    }
  }

  CustomPainter _buildXLabelPainter(BuildContext context) {
    final firstValueDateTime = widget.useToday
        ? DateTime.now()
        : DateTime.now().subtract(Duration(days: 1));
    switch (widget.chartType) {
      case ChartType.time:
        return TimeXLabelPainter(
          scrollController: _xLabelController,
          repaint: _scrollOffsetNotifier,
          context: context,
          viewMode: widget.viewMode,
          firstValueDateTime: firstValueDateTime,
          dayCount: widget.data.length,
          //TODO JDS
          isFirstDataMovedNextDay: false,
        );
      case ChartType.amount:
        return AmountXLabelPainter(
          scrollController: _xLabelController,
          repaint: _scrollOffsetNotifier,
          context: context,
          viewMode: widget.viewMode,
          firstValueDateTime: firstValueDateTime,
          dayCount: widget.data.length,
        );
    }
  }

  CustomPainter _buildBarPainter(BuildContext context) {
    switch (widget.chartType) {
      case ChartType.time:
        return TimeBarPainter(
          scrollController: _barController,
          repaint: _scrollOffsetNotifier,
          context: context,
          tooltipCallback: _tooltipCallback,
          dataList: widget.data,
          barColor: widget.barColor,
          topHour: widget.data.reduce(max).toInt(),
          bottomHour: 0,
          dayCount: widget.data.length,
          viewMode: widget.viewMode,
        );
      case ChartType.amount:
        return AmountBarPainter(
          scrollController: _barController,
          repaint: _scrollOffsetNotifier,
          context: context,
          dataList: widget.data,
          barColor: widget.barColor,
          topHour: widget.data.reduce(max).toInt(),
          bottomHour: 0,
          tooltipCallback: _tooltipCallback,
          dayCount: widget.data.length,
          viewMode: widget.viewMode,
        );
    }
  }
  // CustomPainter _buildBarPainter(BuildContext context) {
  //   switch (widget.chartType) {
  //     case ChartType.time:
  //       return TimeBarPainter(
  //         scrollController: _barController,
  //         repaint: _scrollOffsetNotifier,
  //         context: context,
  //         tooltipCallback: _tooltipCallback,
  //         dataList: processedData,
  //         barColor: widget.barColor,
  //         topHour: widget.data.reduce(max).toInt(),
  //         bottomHour: bottomHour!,
  //         dayCount: dayCount,
  //         viewMode: widget.viewMode,
  //       );
  //     case ChartType.amount:
  //       return AmountBarPainter(
  //         scrollController: _barController,
  //         repaint: _scrollOffsetNotifier,
  //         context: context,
  //         dataList: processedData,
  //         barColor: widget.barColor,
  //         topHour: widget.data.reduce(max).toInt(),
  //         bottomHour: bottomHour!,
  //         tooltipCallback: _tooltipCallback,
  //         dayCount: dayCount,
  //         viewMode: widget.viewMode,
  //       );
  //   }
  // }
}
