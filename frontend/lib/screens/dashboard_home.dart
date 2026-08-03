import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dataset_model.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/metric_kpi_cards.dart';
import '../widgets/network_graph_widget.dart';
import '../widgets/timeline_chart_widget.dart';
import '../widgets/top_spreaders_widget.dart';
import '../widgets/dataset_explorer_widget.dart';
import '../widgets/reports_summary_widget.dart';
import '../widgets/shimmer_loading_widget.dart';

class DashboardHome extends StatelessWidget {
  final int? datasetId;
  final List<DatasetModel> datasets;
  final ValueChanged<int?>? onDatasetChanged;

  const DashboardHome({
    super.key,
    this.datasetId,
    this.datasets = const [],
    this.onDatasetChanged,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);

    if (provider.isLoading && provider.summary == null) {
      return const ShimmerDashboardLoading();
    }

    if (provider.errorMessage != null && provider.summary == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(provider.errorMessage!, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.initialize(),
              child: const Text('Retry Connection'),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1024;

        return SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop ? 20 : 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Workflow Toolbar & Active Dataset Selector
              DashboardHeader(
                datasets: datasets.isNotEmpty ? datasets : provider.datasets,
                selectedDatasetId: datasetId ?? provider.selectedDatasetId,
                onDatasetChanged: onDatasetChanged ?? (id) => provider.selectDataset(id),
              ),

              const SizedBox(height: 18),

              // 2. Summary Research KPI Metric Cards
              const MetricKpiCards(),

              const SizedBox(height: 20),

              // 3. Central Research Canvas Layout
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Network Graph (Primary Artifact - 60% Width)
                    Expanded(
                      flex: 6,
                      child: SizedBox(
                        height: 580,
                        child: NetworkGraphWidget(
                          nodes: provider.networkData?.nodes ?? [],
                          edges: provider.networkData?.edges ?? [],
                        ),
                      ),
                    ),
                    const SizedBox(width: 18),
                    // Supporting Analytics Column (40% Width)
                    const Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          TimelineChartWidget(),
                          SizedBox(height: 18),
                          TopSpreadersWidget(),
                        ],
                      ),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    SizedBox(
                      height: 420,
                      child: NetworkGraphWidget(
                        nodes: provider.networkData?.nodes ?? [],
                        edges: provider.networkData?.edges ?? [],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const TimelineChartWidget(),
                    const SizedBox(height: 18),
                    const TopSpreadersWidget(),
                  ],
                ),

              const SizedBox(height: 20),

              // 4. Bottom Section: Dataset Explorer & Reports
              if (isDesktop)
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: DatasetExplorerWidget()),
                    SizedBox(width: 18),
                    Expanded(child: ReportsSummaryWidget()),
                  ],
                )
              else ...[
                const DatasetExplorerWidget(),
                const SizedBox(height: 18),
                const ReportsSummaryWidget(),
              ],
            ],
          ),
        );
      },
    );
  }
}
