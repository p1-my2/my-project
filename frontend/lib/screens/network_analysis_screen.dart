import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/research_theme.dart';
import '../models/dataset_model.dart';
import '../models/network_model.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/network_analytics_widget.dart';
import '../widgets/network_filter_widget.dart';
import '../widgets/network_graph_widget.dart';
import '../widgets/network_legend_widget.dart';
import '../widgets/node_details_sheet.dart';

class NetworkAnalysisScreen extends StatefulWidget {
  final int? datasetId;

  const NetworkAnalysisScreen({
    super.key,
    this.datasetId,
  });

  @override
  State<NetworkAnalysisScreen> createState() => _NetworkAnalysisScreenState();
}

class _NetworkAnalysisScreenState extends State<NetworkAnalysisScreen> {
  NetworkNodeModel? _selectedNode;
  NetworkFilterModel _filter = NetworkFilterModel();

  List<NetworkNodeModel> _getFilteredNodes(NetworkDataModel? networkData) {
    if (networkData == null) return [];
    return networkData.nodes.where((node) {
      if (node.degree < _filter.minDegree) return false;
      if (_filter.showOnlyMisinformation && !node.isMisinformationHub && node.rank > 5) return false;
      if (_filter.searchQuery.isNotEmpty &&
          !node.id.toLowerCase().contains(_filter.searchQuery.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
  }

  List<NetworkEdgeModel> _getFilteredEdges(NetworkDataModel? networkData, List<NetworkNodeModel> filteredNodes) {
    if (networkData == null) return [];
    final validNodeIds = filteredNodes.map((n) => n.id).toSet();
    return networkData.edges.where((edge) {
      if (!validNodeIds.contains(edge.source) || !validNodeIds.contains(edge.target)) {
        return false;
      }
      if (_filter.interactionType != 'All' &&
          edge.type.toLowerCase() != _filter.interactionType.toLowerCase()) {
        return false;
      }
      return true;
    }).toList();
  }

  void _showFilterBottomSheet(List<DatasetModel> datasets, int? selectedId, Function(int?) onDatasetChanged) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: NetworkFilterWidget(
            filter: _filter,
            datasets: datasets,
            selectedDatasetId: selectedId,
            onDatasetChanged: (id) {
              onDatasetChanged(id);
              Navigator.pop(ctx);
            },
            onFilterChanged: (newFilter) {
              setState(() {
                _filter = newFilter;
              });
            },
            onReset: () {
              setState(() {
                _filter = NetworkFilterModel();
              });
              Navigator.pop(ctx);
            },
          ),
        );
      },
    );
  }

  void _showNodeDetailsBottomSheet(NetworkNodeModel node, List<NetworkEdgeModel> edges) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return NodeDetailsWidget(
          node: node,
          edges: edges,
          onClose: () => Navigator.pop(ctx),
        );
      },
    );
  }

  void _handleNodeSelect(NetworkNodeModel node, bool isMobile, List<NetworkEdgeModel> edges) {
    setState(() {
      _selectedNode = node;
    });

    if (isMobile) {
      _showNodeDetailsBottomSheet(node, edges);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 1024;

    final networkData = provider.networkData;
    final filteredNodes = _getFilteredNodes(networkData);
    final filteredEdges = _getFilteredEdges(networkData, filteredNodes);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Header Bar
            DashboardHeader(
              title: "Social Network Analysis & Diffusion Engine",
              selectedDatasetId: provider.selectedDatasetId,
              datasets: provider.datasets,
              onDatasetChanged: (id) => provider.selectDataset(id),
            ),

            // Main Canvas & Inspector Area
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : provider.errorMessage != null
                      ? _buildErrorWidget(provider.errorMessage!, provider.initialize)
                      : networkData == null || filteredNodes.isEmpty
                          ? _buildEmptyState()
                          : isMobile
                              ? _buildMobileLayout(networkData, filteredNodes, filteredEdges)
                              : isTablet
                                  ? _buildTabletLayout(networkData, filteredNodes, filteredEdges, isDark)
                                  : _buildDesktopLayout(networkData, filteredNodes, filteredEdges, isDark),
            ),
          ],
        ),
      ),
      floatingActionButton: isMobile && !provider.isLoading && networkData != null
          ? FloatingActionButton.extended(
              heroTag: 'fabFilterSna',
              onPressed: () => _showFilterBottomSheet(provider.datasets, provider.selectedDatasetId, provider.selectDataset),
              icon: const Icon(Icons.filter_list),
              label: const Text('Filters'),
              backgroundColor: isDark ? ResearchTheme.darkPrimary : ResearchTheme.lightPrimary,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }

  Widget _buildMobileLayout(NetworkDataModel networkData, List<NetworkNodeModel> nodes, List<NetworkEdgeModel> edges) {
    return Stack(
      children: [
        Positioned.fill(
          child: NetworkGraphWidget(
            nodes: nodes,
            edges: edges,
            selectedNode: _selectedNode,
            searchQuery: _filter.searchQuery,
            onNodeSelected: (node) => _handleNodeSelect(node, true, edges),
          ),
        ),
        Positioned(
          top: 8,
          left: 0,
          right: 0,
          child: NetworkAnalyticsWidget(
            data: networkData,
            isMobile: true,
          ),
        ),
        const Positioned(
          left: 8,
          bottom: 16,
          child: NetworkLegendWidget(isCollapsible: true),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(NetworkDataModel networkData, List<NetworkNodeModel> nodes, List<NetworkEdgeModel> edges, bool isDark) {
    return Row(
      children: [
        Expanded(
          flex: 7,
          child: Stack(
            children: [
              NetworkGraphWidget(
                nodes: nodes,
                edges: edges,
                selectedNode: _selectedNode,
                searchQuery: _filter.searchQuery,
                onNodeSelected: (node) => _handleNodeSelect(node, false, edges),
              ),
              const Positioned(
                left: 12,
                bottom: 16,
                child: NetworkLegendWidget(isCollapsible: true),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
            color: isDark ? ResearchTheme.darkSurface : ResearchTheme.lightSurface,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  if (_selectedNode != null)
                    NodeDetailsWidget(
                      node: _selectedNode!,
                      edges: edges,
                      onClose: () => setState(() => _selectedNode = null),
                    ),
                  const SizedBox(height: 12),
                  NetworkAnalyticsWidget(data: networkData, isMobile: false),
                  const SizedBox(height: 12),
                  NetworkFilterWidget(
                    filter: _filter,
                    datasets: Provider.of<DashboardProvider>(context, listen: false).datasets,
                    selectedDatasetId: Provider.of<DashboardProvider>(context, listen: false).selectedDatasetId,
                    onDatasetChanged: (id) => Provider.of<DashboardProvider>(context, listen: false).selectDataset(id),
                    onFilterChanged: (f) => setState(() => _filter = f),
                    onReset: () => setState(() => _filter = NetworkFilterModel()),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(NetworkDataModel networkData, List<NetworkNodeModel> nodes, List<NetworkEdgeModel> edges, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Stack(
            children: [
              NetworkGraphWidget(
                nodes: nodes,
                edges: edges,
                selectedNode: _selectedNode,
                searchQuery: _filter.searchQuery,
                onNodeSelected: (node) => _handleNodeSelect(node, false, edges),
              ),
              const Positioned(
                left: 16,
                bottom: 24,
                child: NetworkLegendWidget(isCollapsible: false),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 360,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? ResearchTheme.darkSurface : ResearchTheme.lightSurface,
              border: Border(
                left: BorderSide(
                  color: isDark ? ResearchTheme.darkBorder : ResearchTheme.lightBorder,
                ),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (_selectedNode != null)
                    NodeDetailsWidget(
                      node: _selectedNode!,
                      edges: edges,
                      onClose: () => setState(() => _selectedNode = null),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? ResearchTheme.darkBg : ResearchTheme.lightBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? ResearchTheme.darkBorder : ResearchTheme.lightBorder,
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.touch_app, color: Colors.amber, size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Tap any node in the graph to inspect centrality & Reach Score metrics.',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  NetworkAnalyticsWidget(data: networkData, isMobile: false),
                  const SizedBox(height: 16),
                  NetworkFilterWidget(
                    filter: _filter,
                    datasets: Provider.of<DashboardProvider>(context, listen: false).datasets,
                    selectedDatasetId: Provider.of<DashboardProvider>(context, listen: false).selectedDatasetId,
                    onDatasetChanged: (id) => Provider.of<DashboardProvider>(context, listen: false).selectDataset(id),
                    onFilterChanged: (f) => setState(() => _filter = f),
                    onReset: () => setState(() => _filter = NetworkFilterModel()),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget(String error, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          Text(error, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text("Retry")),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.hub_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text("No network interactions found in this dataset.", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Try selecting a different dataset or resetting graph filters.", style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _filter = NetworkFilterModel();
              });
            },
            child: const Text("Reset Filters"),
          ),
        ],
      ),
    );
  }
}
