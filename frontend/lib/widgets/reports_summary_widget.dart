import 'package:flutter/material.dart';
import '../config/research_theme.dart';

class ReportsSummaryWidget extends StatelessWidget {
  const ReportsSummaryWidget({super.key});

  @override
  Widget build(BuildContext context) {
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
            children: [
              Icon(Icons.assessment_outlined, size: 18, color: Colors.blueAccent),
              SizedBox(width: 8),
              Text(
                'Automated Research Reports',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Generate formal academic export reports in PDF and CSV format containing network centrality metrics, peak velocity hours, and misinformation hub rankings.',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? ResearchTheme.darkTextSecondary : ResearchTheme.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Generating PDF Report... Navigating to Reports Screen.')),
                    );
                  },
                  icon: const Icon(Icons.picture_as_pdf, size: 16),
                  label: const Text('Export PDF', style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? ResearchTheme.darkPrimary : ResearchTheme.lightPrimary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Generating CSV Metrics Summary...')),
                    );
                  },
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('Export CSV', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
