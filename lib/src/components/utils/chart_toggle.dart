import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:time_chart/src/components/utils/time_converter.dart';
import 'package:time_chart/src/components/utils/time_data_processor.dart';

import '../../../time_chart.dart';
import '../../chart.dart';

class ChartToggle extends StatefulWidget {
  ChartState chart;

  ChartToggle(this.chart) {
    var dataType = chart.widget.chartType;
    timeData = chart.widget.dataTime;
    doubleData = chart.widget.dataDouble;
  }
  late List<DateTimeRange> timeData;
  late List<double> doubleData;
  late bool type = (chart.widget.chartType) == ChartType.time ? true : false;

  @override
  State<ChartToggle> createState() => _ChartToggle();
}

class _ChartToggle extends State<ChartToggle> {
  bool light = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: InkWell(
          radius: 50,
          // borderRadius: BorderRadius.circular(1.0),
          onTap: () {
            if (widget.type) {
              widget.chart.widget.data = widget.doubleData;
              widget.chart.widget.chartType = ChartType.amount;
            } else {
              widget.chart.widget.data = widget.timeData;
              widget.chart.widget.chartType = ChartType.time;
            }

            widget.chart.setState(() {
              widget.chart.timerCallback();
            });
          },
          child: Container(
            padding:
                EdgeInsets.only(right: 3.0, left: 3.0, bottom: 3.0, top: 1.0),
            decoration: BoxDecoration(
              color: widget.chart.widget.tooltipBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: (widget.type)
                ? Icon(CupertinoIcons.clock,
                    color: widget.chart.widget.detailColor)
                : Icon(CupertinoIcons.chart_bar_circle,
                    color: widget.chart.widget.detailColor),
          )),
    );

    // return TextButton(
    //   style: TextButton.styleFrom(
    //     backgroundColor: Colors.purple,
    //     shape: CircleBorder(),
    //   ),
    //   child: (widget.type)
    //       ? Icon(CupertinoIcons.clock, color: widget.chart.widget.tooltipBackgroundColor)
    //       : Icon(CupertinoIcons.chart_bar_circle,
    //           color: widget.chart.widget.tooltipBackgroundColor),
    //   onPressed: () {
    //         if (widget.type) {
    //           widget.chart.widget.data = widget.doubleData;
    //           widget.chart.widget.chartType = ChartType.amount;
    //         } else {
    //           widget.chart.widget.data = widget.timeData;
    //           widget.chart.widget.chartType = ChartType.time;
    //         }

    //         widget.chart.setState(() {
    //           widget.chart.timerCallback();
    //         });
    //       },,
    // );

    // return IconButton(
    //   onPressed: () {
    //     if (widget.type) {
    //       widget.chart.widget.data = widget.doubleData;
    //       widget.chart.widget.chartType = ChartType.amount;
    //     } else {
    //       widget.chart.widget.data = widget.timeData;
    //       widget.chart.widget.chartType = ChartType.time;
    //     }

    //     widget.chart.setState(() {
    //       widget.chart.timerCallback();
    //     });
    //   },
    //   icon: (widget.type)
    //       ? Icon(CupertinoIcons.clock)
    //       : Icon(CupertinoIcons.chart_bar),
    //   color: widget.chart.widget.tooltipBackgroundColor,
    // );

    // return Switch(
    //   // This bool value toggles the switch.
    //   value: light,
    //   activeColor: Colors.red,
    //   onChanged: (bool value) {
    //     if (value) {
    //       widget.chart.widget.data = widget.timeData;
    //       widget.chart.widget.chartType = ChartType.time;

    //       widget.chart.setState(() {
    //         widget.chart.timerCallback();
    //       });
    //     } else {
    //       widget.chart.widget.data = widget.doubleData;
    //       widget.chart.widget.chartType = ChartType.amount;

    //       widget.chart.setState(() {
    //         widget.chart.timerCallback();
    //       });
    //     }
    //     // This is called when the user toggles the switch.

    //     setState(() {
    //       light = value;
    //     });
    //   },
    // );
  }
}
