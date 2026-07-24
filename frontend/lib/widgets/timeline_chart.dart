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
    final theme = Theme.of(context);
    const totalPostsColor = Colors.blue;
    const misinfoPostsColor = Colors.deepOrange;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem(
              color: totalPostsColor,
              label: "Total Posts",
            ),
            const SizedBox(width: 24),
            _buildLegendItem(
              color: misinfoPostsColor,
              label: "Misinformation Posts",
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: LineChart(
            LineChartData(
              minY: 0,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: theme.dividerColor.withValues(alpha: 0.4),
                    strokeWidth: 1,
                  );
                },
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(color: theme.dividerColor, width: 1),
                  left: BorderSide(color: theme.dividerColor, width: 1),
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      );
                    },
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
                    reservedSize: 32,
                    getTitlesWidget: (value, meta) {
                      int index = value.toInt();
                      if (index < 0 || index >= data.length) {
                        return const SizedBox();
                      }

                      final dateStr = data[index].date;
                      final displayDate = dateStr.length >= 5
                          ? dateStr.substring(5)
                          : dateStr;

                      return SideTitleWidget(
                        meta: meta,
                        space: 8,
                        child: Text(
                          displayDate,
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final isTotal = spot.barIndex == 0;
                      final label = isTotal ? "Total" : "Misinfo";
                      final color = isTotal ? totalPostsColor : misinfoPostsColor;
                      return LineTooltipItem(
                        "$label: ${spot.y.toInt()}",
                        TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
              lineBarsData: [
                // Series 1: Total Posts
                LineChartBarData(
                  isCurved: true,
                  color: totalPostsColor,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: totalPostsColor.withValues(alpha: 0.1),
                  ),
                  spots: List.generate(
                    data.length,
                    (index) => FlSpot(
                      index.toDouble(),
                      data[index].posts.toDouble(),
                    ),
                  ),
                ),
                // Series 2: Misinformation Posts
                LineChartBarData(
                  isCurved: true,
                  color: misinfoPostsColor,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: misinfoPostsColor.withValues(alpha: 0.1),
                  ),
                  spots: List.generate(
                    data.length,
                    (index) => FlSpot(
                      index.toDouble(),
                      data[index].misinformationPosts.toDouble(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}