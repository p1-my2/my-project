import 'package:flutter/material.dart';
import '../models/dataset_model.dart';
import '../models/network_model.dart';
import '../services/analysis_service.dart';
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
  int? _selectedDatasetId;
  List<DatasetModel> _datasets = [];
  NetworkDataModel? _networkData;
  NetworkNodeModel? _selectedNode;

  bool _isLoading = true;
  String? _errorMessage;

  NetworkFilterModel _filter = NetworkFilterModel();

  @override
  void initState() {
    super.initState();
    _selectedDatasetId = widget.datasetId;
    _loadData();
  }

  @override
  void didUpdateWidget(covariant NetworkAnalysisScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.datasetId != widget.datasetId) {
      setState(() {
        _selectedDatasetId = widget.datasetId;
      });
      _loadNetworkData();
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final datasetList = await AnalysisService().getDatasets();
      final network = await AnalysisService().getNetworkData(datasetId: _selectedDatasetId);

      if (mounted) {
        setState(() {
          _datasets = datasetList;
          _networkData = network;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadNetworkData() async {
    try {
      final network = await AnalysisService().getNetworkData(datasetId: _selectedDatasetId);
      if (mounted) {
        setState(() {
          _networkData = network;
          _selectedNode = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }

  List<NetworkNodeModel> get _filteredNodes {
    if (_networkData == null) return [];
    return _networkData!.nodes.where((node) {
      if (node.degree < _filter.minDegree) return false;
      if (_filter.showOnlyMisinformation && !node.isMisinformationHub && node.rank > 5) return false;
      if (_filter.searchQuery.isNotEmpty &&
          !node.id.toLowerCase().contains(_filter.searchQuery.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
  }

  List<NetworkEdgeModel> get _filteredEdges {
    if (_networkData == null) return [];
    final validNodeIds = _filteredNodes.map((n) => n.id).toSet();
    return _networkData!.edges.where((edge) {
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

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: NetworkFilterWidget(
            filter: _filter,
            datasets: _datasets,
            selectedDatasetId: _selectedDatasetId,
            onDatasetChanged: (id) {
              setState(() {
                _selectedDatasetId = id;
              });
              Navigator.pop(ctx);
              _loadNetworkData();
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

  void _showNodeDetailsBottomSheet(NetworkNodeModel node) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return NodeDetailsWidget(
          node: node,
          edges: _filteredEdges,
          onClose: () => Navigator.pop(ctx),
        );
      },
    );
  }

  void _handleNodeSelect(NetworkNodeModel node, bool isMobile) {
    setState(() {
      _selectedNode = node;
    });

    if (isMobile) {
      _showNodeDetailsBottomSheet(node);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    final isTablet = width >= 600 && width < 1024;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          children: [
            // Header Bar
            DashboardHeader(
              title: "Social Network Analysis (SNA)",
              selectedDatasetId: _selectedDatasetId,
              datasets: _datasets,
              onDatasetChanged: (id) {
                setState(() {
                  _selectedDatasetId = id;
                });
                _loadNetworkData();
              },
            ),

            // Main Body Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? _buildErrorWidget()
                      : _networkData == null || _filteredNodes.isEmpty
                          ? _buildEmptyState()
                          : isMobile
                              ? _buildMobileLayout()
                              : isTablet
                                  ? _buildTabletLayout()
                                  : _buildDesktopLayout(),
            ),
          ],
        ),
      ),
      floatingActionButton: isMobile && !_isLoading && _networkData != null
          ? FloatingActionButton.extended(
              heroTag: 'fabFilter',
              onPressed: _showFilterBottomSheet,
              icon: const Icon(Icons.filter_list),
              label: const Text('Filters'),
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }

  Widget _buildMobileLayout() {
    return Stack(
      children: [
        // Main Network Graph Canvas
        Positioned.fill(
          child: NetworkGraphWidget(
            nodes: _filteredNodes,
            edges: _filteredEdges,
            selectedNode: _selectedNode,
            searchQuery: _filter.searchQuery,
            onNodeSelected: (node) => _handleNodeSelect(node, true),
          ),
        ),

        // Swipeable Horizontally Cards at Top
        Positioned(
          top: 8,
          left: 0,
          right: 0,
          child: NetworkAnalyticsWidget(
            data: _networkData!,
            isMobile: true,
          ),
        ),

        // Collapsible Educational Legend at Bottom Left
        const Positioned(
          left: 8,
          bottom: 16,
          child: NetworkLegendWidget(isCollapsible: true),
        ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        // Graph Canvas (70%)
        Expanded(
          flex: 7,
          child: Stack(
            children: [
              NetworkGraphWidget(
                nodes: _filteredNodes,
                edges: _filteredEdges,
                selectedNode: _selectedNode,
                searchQuery: _filter.searchQuery,
                onNodeSelected: (node) => _handleNodeSelect(node, false),
              ),
              const Positioned(
                left: 12,
                bottom: 16,
                child: NetworkLegendWidget(isCollapsible: true),
              ),
            ],
          ),
        ),

        // Analytics & Filter Panel (30%)
        Expanded(
          flex: 3,
          child: Container(
            color: const Color(0xFF1E293B),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  if (_selectedNode != null)
                    NodeDetailsWidget(
                      node: _selectedNode!,
                      edges: _filteredEdges,
                      onClose: () => setState(() => _selectedNode = null),
                    ),
                  const SizedBox(height: 12),
                  NetworkAnalyticsWidget(data: _networkData!, isMobile: false),
                  const SizedBox(height: 12),
                  NetworkFilterWidget(
                    filter: _filter,
                    datasets: _datasets,
                    selectedDatasetId: _selectedDatasetId,
                    onDatasetChanged: (id) {
                      setState(() {
                        _selectedDatasetId = id;
                      });
                      _loadNetworkData();
                    },
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

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Graph Canvas
        Expanded(
          child: Stack(
            children: [
              NetworkGraphWidget(
                nodes: _filteredNodes,
                edges: _filteredEdges,
                selectedNode: _selectedNode,
                searchQuery: _filter.searchQuery,
                onNodeSelected: (node) => _handleNodeSelect(node, false),
              ),
              const Positioned(
                left: 16,
                bottom: 24,
                child: NetworkLegendWidget(isCollapsible: false),
              ),
            ],
          ),
        ),

        // Side Analytics & Filter Inspector Panel
        SizedBox(
          width: 360,
          child: Container(
            color: const Color(0xFF1E293B),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (_selectedNode != null)
                    NodeDetailsWidget(
                      node: _selectedNode!,
                      edges: _filteredEdges,
                      onClose: () => setState(() => _selectedNode = null),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.touch_app, color: Colors.amber),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Tap any node in the graph to inspect centrality & metrics.',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  NetworkAnalyticsWidget(data: _networkData!, isMobile: false),
                  const SizedBox(height: 16),
                  NetworkFilterWidget(
                    filter: _filter,
                    datasets: _datasets,
                    selectedDatasetId: _selectedDatasetId,
                    onDatasetChanged: (id) {
                      setState(() {
                        _selectedDatasetId = id;
                      });
                      _loadNetworkData();
                    },
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

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          Text(_errorMessage ?? "Error loading graph data", style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadData, child: const Text("Retry")),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.hub_outlined, size: 64, color: Colors.white38),
          const SizedBox(height: 16),
          const Text("No network interactions found in this dataset.", style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 8),
          const Text("Try selecting a different dataset or resetting graph filters.", style: TextStyle(color: Colors.white38, fontSize: 12)),
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
