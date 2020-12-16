import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/transaction.dart';

class TransactionChart extends StatefulWidget {
  final List<Transaction> recentTransaction;

  TransactionChart(this.recentTransaction);

  @override
  _TransactionChartState createState() => _TransactionChartState();
}

class _TransactionChartState extends State<TransactionChart> {
  double maxTotal = 0.0;
  List<Map<String, Object>> get groupedTransactions {
    return List.generate(7, (index) {
      final weekDay = DateTime.now().subtract(Duration(days: index));
      double totalSum = 0.0;
      for (var i = 0; i < widget.recentTransaction.length; i++) {
        bool sameDay = widget.recentTransaction[i].date.day == weekDay.day;
        bool sameMonth =
            widget.recentTransaction[i].date.month == weekDay.month;
        bool sameYear = widget.recentTransaction[i].date.year == weekDay.year;
        if (sameDay && sameMonth && sameYear) {
          totalSum += widget.recentTransaction[i].value;
        }
      }
      if (totalSum > maxTotal) {
        maxTotal = totalSum + ((totalSum * 20) / 100);
      }
      return {
        'day': DateFormat.E().format(weekDay),
        'value': totalSum,
      };
    });
  }

  double get weekTotalValue {
    return groupedTransactions.fold(0.0, (sum, t) {
      return sum + t['value'];
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, Object>> groups = groupedTransactions.toList();
    List<BarChartGroupData> barGroupsData =
        groups.asMap().keys.toList().map((index) {
      return BarChartGroupData(x: index, barRods: [
        BarChartRodData(
            y: groups[index]['value'],
            colors: [Colors.lightBlueAccent, Colors.greenAccent])
      ], showingTooltipIndicators: [
        0
      ]);
    }).toList();

    return AspectRatio(
      aspectRatio: 2,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxTotal,
            gridData: FlGridData(
              checkToShowHorizontalLine: (value) => value % 10 == 0,
              getDrawingHorizontalLine: (value) => FlLine(
                color: const Color(0xffe7e8ec),
                strokeWidth: 1,
              ),
            ),
            barTouchData: BarTouchData(
              enabled: false,
              touchTooltipData: BarTouchTooltipData(
                tooltipBgColor: Colors.transparent,
                tooltipPadding: const EdgeInsets.all(0),
                tooltipBottomMargin: 1,
                getTooltipItem: (
                  BarChartGroupData group,
                  int groupIndex,
                  BarChartRodData rod,
                  int rodIndex,
                ) {
                  return BarTooltipItem(
                    rod.y.round().toString(),
                    TextStyle(
                      color: Colors.purple,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: SideTitles(
                showTitles: true,
                getTextStyles: (value) => const TextStyle(
                    color: Color(0xff7589a2),
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
                margin: 10,
                getTitles: (double value) {
                  return groups.elementAt(value.toInt())['day'].toString();
                },
              ),
              leftTitles: SideTitles(showTitles: true),
            ),
            borderData: FlBorderData(
              show: true,
            ),
            barGroups: barGroupsData,
          ),
        ),
      ),
    );
  }
}
