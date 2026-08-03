import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/research_theme.dart';
import '../providers/dashboard_provider.dart';
import 'timeline_chart.dart';

class TimelineChartWidget extends StatelessWidget {
  const TimelineChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);
    final timelineData = provider.timelineData;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? ResearchTheme.darkSurface : ResearchTheme.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? ResearchTheme.darkBorder : ResearchTheme.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.show_chart_outlined, size: 18, color: ResearchTheme.darkPrimary),
                  SizedBox(width: 8),
                  Text(
                    'Propagation Temporal Velocity',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (timelineData.isEmpty)
            const SizedBox(
              height: 220,
              child: Center(
                child: Text('No timeline data available for dataset.', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ),
            )
          else
            TimelineChart(data: timelineData),
        ],
      ),
    );
  }
}
