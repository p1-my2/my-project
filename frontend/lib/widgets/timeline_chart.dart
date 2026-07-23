import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/timeline_model.dart';

class TimelineChart extends StatelessWidget {
  final List<TimelineModel> data;

  const TimelineChart({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: LineChart(
        LineChartData(
          minY: 0,
          gridData: const FlGridData(show: true),

          borderData: FlBorderData(show: true),

          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 35,
              ),
            ),

            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),

            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),

            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();

                  if (index >= data.length) {
                    return const SizedBox();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      data[index].date.substring(5),
                      style: const TextStyle(fontSize: 11),
                    ),
                  );
                },
              ),
            ),
          ),

          lineBarsData: [
            LineChartBarData(
              isCurved: true,

              spots: List.generate(
                data.length,
                (index) => FlSpot(
                  index.toDouble(),
                  data[index].posts.toDouble(),
                ),
              ),

              barWidth: 4,

              dotData: const FlDotData(
                show: true,
              ),

              belowBarData: BarAreaData(
                show: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}