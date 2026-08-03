import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/research_theme.dart';
import '../providers/dashboard_provider.dart';

class MetricKpiCards extends StatelessWidget {
  const MetricKpiCards({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);
    final summary = provider.summary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (summary == null) return const SizedBox.shrink();

    final metrics = [
      _KpiItem('Total Users', summary.totalUsers.toString(), Icons.people_outline, ResearchTheme.darkPrimary),
      _KpiItem('Datasets Uploaded', summary.totalDatasets.toString(), Icons.folder_open_outlined, Colors.amber),
      _KpiItem('Analyzed Posts', summary.totalPosts.toString(), Icons.article_outlined, Colors.teal),
      _KpiItem('Extracted Hashtags', summary.totalHashtags.toString(), Icons.numbers_outlined, Colors.purpleAccent),
      _KpiItem('Generated Reports', summary.totalReports.toString(), Icons.picture_as_pdf_outlined, Colors.blueAccent),
      _KpiItem('Misinformation Posts', summary.misinformationPosts.toString(), Icons.warning_amber_rounded, ResearchTheme.riskHigh),
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: metrics.map((item) {
        return SizedBox(
          width: 220,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isDark ? ResearchTheme.darkSurface : ResearchTheme.lightSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? ResearchTheme.darkBorder : ResearchTheme.lightBorder,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, color: item.color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isDark ? ResearchTheme.darkTextSecondary : ResearchTheme.lightTextSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.value,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? ResearchTheme.darkTextPrimary : ResearchTheme.lightTextPrimary,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _KpiItem {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  _KpiItem(this.title, this.value, this.icon, this.color);
}
