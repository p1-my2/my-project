import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/influencer_model.dart';

class InfluencerChart extends StatelessWidget {
  final List<InfluencerModel> data;

  const InfluencerChart({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,

          borderData: FlBorderData(show: false),

          gridData: const FlGridData(show: true),

          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),

            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),

            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 35,
              ),
            ),

            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();

                  if (index >= data.length) {
                    return const SizedBox();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: RotatedBox(
                      quarterTurns: 1,
                      child: Text(
                        data[index].sourceUser,
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          barGroups: List.generate(
            data.length,
            (index) => BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: data[index].interactions.toDouble(),
                  width: 22,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}