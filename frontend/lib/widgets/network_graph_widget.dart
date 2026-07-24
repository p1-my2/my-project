import 'dart:math';
import 'package:flutter/material.dart';
import '../models/network_model.dart';
import 'network_graph_painter.dart';

class NetworkGraphWidget extends StatefulWidget {
  final List<NetworkNodeModel> nodes;
  final List<NetworkEdgeModel> edges;
  final NetworkNodeModel? selectedNode;
  final String searchQuery;
  final Function(NetworkNodeModel node) onNodeSelected;

  const NetworkGraphWidget({
    super.key,
    required this.nodes,
    required this.edges,
    this.selectedNode,
    this.searchQuery = '',
    required this.onNodeSelected,
  });

  @override
  State<NetworkGraphWidget> createState() => _NetworkGraphWidgetState();
}

class _NetworkGraphWidgetState extends State<NetworkGraphWidget> {
  final TransformationController _transformationController = TransformationController();
  final Map<String, Offset> _positions = {};
  final Size _canvasSize = const Size(2000, 2000);

  @override
  void initState() {
    super.initState();
    _computeGraphLayout();
  }

  @override
  void didUpdateWidget(covariant NetworkGraphWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.nodes != widget.nodes || oldWidget.edges != widget.edges) {
      _computeGraphLayout();
    }
  }

  void _computeGraphLayout() {
    _positions.clear();
    if (widget.nodes.isEmpty) return;

    final center = Offset(_canvasSize.width / 2, _canvasSize.height / 2);
    final count = widget.nodes.length;

    // Organic Force-Directed Concentric Circular Layout
    final baseRadius = min(_canvasSize.width, _canvasSize.height) * 0.38;

    for (int i = 0; i < count; i++) {
      final node = widget.nodes[i];
      // Higher degree centrality nodes positioned closer to central hub
      final tierFactor = 1.0 - (node.degreeCentrality * 0.45).clamp(0.0, 0.65);
      final angle = (2 * pi * i) / count;
      final radius = baseRadius * tierFactor;

      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);

      _positions[node.id] = Offset(x, y);
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.nodes.isEmpty) return;

    // Transform tap position relative to canvas
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final localOffset = renderBox.globalToLocal(details.globalPosition);
    final Matrix4 transform = _transformationController.value;
    final Matrix4 inverted = Matrix4.inverted(transform);
    final Offset canvasOffset = MatrixUtils.transformPoint(inverted, localOffset);

    // Hit test nodes
    NetworkNodeModel? tappedNode;
    double minDistance = double.infinity;

    for (final node in widget.nodes) {
      final pos = _positions[node.id];
      if (pos == null) continue;

      final radius = 24.0 + (node.degreeCentrality * 24.0);
      final dist = (canvasOffset - pos).distance;

      if (dist <= radius && dist < minDistance) {
        minDistance = dist;
        tappedNode = node;
      }
    }

    if (tappedNode != null) {
      widget.onNodeSelected(tappedNode);
    }
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity();
  }

  void _zoomIn() {
    // ignore: deprecated_member_use
    _transformationController.value = _transformationController.value.clone()..scale(1.25, 1.25, 1.0);
  }

  void _zoomOut() {
    // ignore: deprecated_member_use
    _transformationController.value = _transformationController.value.clone()..scale(0.8, 0.8, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF101827), // Sleek Dark Canvas
      child: Stack(
        children: [
          GestureDetector(
            onTapUp: _handleTapUp,
            child: InteractiveViewer(
              transformationController: _transformationController,
              boundaryMargin: const EdgeInsets.all(500),
              minScale: 0.15,
              maxScale: 4.5,
              constrained: false,
              child: CustomPaint(
                size: _canvasSize,
                painter: NetworkGraphPainter(
                  nodes: widget.nodes,
                  edges: widget.edges,
                  nodePositions: _positions,
                  selectedNode: widget.selectedNode,
                  searchQuery: widget.searchQuery,
                ),
              ),
            ),
          ),

          // Floating Controls: Zoom In / Zoom Out / Reset View
          Positioned(
            right: 16,
            bottom: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  heroTag: 'btnZoomIn',
                  backgroundColor: const Color(0xFF1F2937),
                  foregroundColor: Colors.white,
                  onPressed: _zoomIn,
                  tooltip: 'Zoom In',
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'btnZoomOut',
                  backgroundColor: const Color(0xFF1F2937),
                  foregroundColor: Colors.white,
                  onPressed: _zoomOut,
                  tooltip: 'Zoom Out',
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'btnResetZoom',
                  backgroundColor: const Color(0xFF1F2937),
                  foregroundColor: Colors.white,
                  onPressed: _resetZoom,
                  tooltip: 'Reset View',
                  child: const Icon(Icons.center_focus_strong),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
