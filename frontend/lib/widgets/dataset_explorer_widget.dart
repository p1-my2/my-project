import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/research_theme.dart';
import '../providers/dashboard_provider.dart';

class DatasetExplorerWidget extends StatelessWidget {
  const DatasetExplorerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);
    final datasets = provider.datasets;
    final selectedId = provider.selectedDatasetId;
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
              Icon(Icons.folder_open_outlined, size: 18, color: Colors.amber),
              SizedBox(width: 8),
              Text(
                'Active Dataset Explorer',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (datasets.isEmpty)
            const Text('No datasets loaded. Upload a CSV to get started.', style: TextStyle(fontSize: 12, color: Colors.grey))
          else
            Column(
              children: datasets.take(4).map((d) {
                final isSelected = d.id == selectedId;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark ? ResearchTheme.darkPrimary.withValues(alpha: 0.12) : ResearchTheme.lightPrimary.withValues(alpha: 0.08))
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected
                        ? Border.all(color: isDark ? ResearchTheme.darkPrimary : ResearchTheme.lightPrimary)
                        : null,
                  ),
                  child: ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    leading: Icon(
                      Icons.insert_drive_file_outlined,
                      color: isSelected ? (isDark ? ResearchTheme.darkPrimary : ResearchTheme.lightPrimary) : Colors.grey,
                    ),
                    title: Text(
                      d.filename,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      'Status: ${d.status}',
                      style: const TextStyle(fontSize: 11),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: ResearchTheme.riskLow, size: 18)
                        : TextButton(
                            onPressed: () => provider.selectDataset(d.id),
                            child: const Text('Select', style: TextStyle(fontSize: 11)),
                          ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
