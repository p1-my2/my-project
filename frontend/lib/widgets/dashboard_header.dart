import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/research_theme.dart';
import '../models/dataset_model.dart';
import '../providers/dashboard_provider.dart';

class DashboardHeader extends StatelessWidget {
  final String title;
  final List<DatasetModel>? datasets;
  final int? selectedDatasetId;
  final ValueChanged<int?>? onDatasetChanged;

  const DashboardHeader({
    super.key,
    this.title = "Misinformation Diffusion Analysis",
    this.datasets,
    this.selectedDatasetId,
    this.onDatasetChanged,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);
    final activeDatasets = datasets ?? provider.datasets;
    final activeSelectedId = selectedDatasetId ?? provider.selectedDatasetId;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bool hasSelected = activeSelectedId == null ||
        activeDatasets.any((d) => d.id == activeSelectedId);
    final int? activeValue = hasSelected ? activeSelectedId : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? ResearchTheme.darkSurface : ResearchTheme.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? ResearchTheme.darkBorder : ResearchTheme.lightBorder,
        ),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 12,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? ResearchTheme.darkTextPrimary : ResearchTheme.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: ResearchTheme.riskLow,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Research Pipeline Active',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? ResearchTheme.darkTextSecondary : ResearchTheme.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark ? ResearchTheme.darkBg : ResearchTheme.lightBg,
                  border: Border.all(
                    color: isDark ? ResearchTheme.darkBorder : ResearchTheme.lightBorder,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int?>(
                    value: activeValue,
                    hint: const Text("All Datasets", style: TextStyle(fontSize: 13)),
                    dropdownColor: isDark ? ResearchTheme.darkSurface : ResearchTheme.lightSurface,
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text("All Datasets", style: TextStyle(fontSize: 13)),
                      ),
                      ...activeDatasets.map((dataset) {
                        return DropdownMenuItem<int?>(
                          value: dataset.id,
                          child: Text(dataset.filename, style: const TextStyle(fontSize: 13)),
                        );
                      }),
                    ],
                    onChanged: (id) {
                      if (onDatasetChanged != null) {
                        onDatasetChanged!(id);
                      } else {
                        provider.selectDataset(id);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 18,
                backgroundColor: isDark ? ResearchTheme.darkPrimary.withValues(alpha: 0.2) : ResearchTheme.lightPrimary.withValues(alpha: 0.1),
                child: Icon(
                  Icons.science_outlined,
                  size: 20,
                  color: isDark ? ResearchTheme.darkPrimary : ResearchTheme.lightPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}