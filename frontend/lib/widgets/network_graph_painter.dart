import 'dart:math';
import 'package:flutter/material.dart';
import '../models/network_model.dart';

class NetworkGraphPainter extends CustomPainter {
  final List<NetworkNodeModel> nodes;
  final List<NetworkEdgeModel> edges;
  final Map<String, Offset> nodePositions;
  final NetworkNodeModel? selectedNode;
  final String searchQuery;

  NetworkGraphPainter({
    required this.nodes,
    required this.edges,
    required this.nodePositions,
    this.selectedNode,
    this.searchQuery = '',
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (nodes.isEmpty) return;

    final edgePaint = Paint()
      ..color = Colors.blueGrey.withValues(alpha: 0.35)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final selectedEdgePaint = Paint()
      ..color = Colors.amber.shade700
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    // Draw Edges with Directional Arrows
    for (final edge in edges) {
      final start = nodePositions[edge.source];
      final end = nodePositions[edge.target];
      if (start == null || end == null) continue;

      final isEdgeSelected = selectedNode != null &&
          (edge.source == selectedNode!.id || edge.target == selectedNode!.id);

      final currentEdgePaint = isEdgeSelected ? selectedEdgePaint : edgePaint;
      canvas.drawLine(start, end, currentEdgePaint);

      // Draw direction arrowhead near target node
      _drawArrowHead(canvas, start, end, currentEdgePaint.color, isSelected: isEdgeSelected);
    }

    // Draw Nodes
    for (final node in nodes) {
      final pos = nodePositions[node.id];
      if (pos == null) continue;

      final radius = _getNodeRadius(node);
      final isSelected = selectedNode?.id == node.id;
      final isHighlighted = searchQuery.isNotEmpty &&
          node.id.toLowerCase().contains(searchQuery.toLowerCase());

      final nodeColor = _getNodeColor(node, isSelected: isSelected);

      // Node Outer Pulse / Glow for Selected / Highlighted
      if (isSelected || isHighlighted) {
        final glowPaint = Paint()
          ..color = (isSelected ? Colors.amber : Colors.blue).withValues(alpha: 0.4)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pos, radius + 8.0, glowPaint);
      }

      // Main Node Fill
      final fillPaint = Paint()
        ..color = nodeColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, radius, fillPaint);

      // Node Border
      final borderPaint = Paint()
        ..color = isSelected ? Colors.amber.shade400 : Colors.white
        ..strokeWidth = isSelected ? 3.0 : 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(pos, radius, borderPaint);

      // Node Label
      final textSpan = TextSpan(
        text: node.id.length > 10 ? '${node.id.substring(0, 8)}..' : node.id,
        style: TextStyle(
          color: isSelected ? Colors.black : Colors.white,
          fontSize: (radius * 0.55).clamp(9.0, 13.0),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(pos.dx - (textPainter.width / 2), pos.dy - (textPainter.height / 2)),
      );
    }
  }

  void _drawArrowHead(Canvas canvas, Offset start, Offset end, Color color, {required bool isSelected}) {
    final double arrowSize = isSelected ? 10.0 : 7.0;
    final double angle = atan2(end.dy - start.dy, end.dx - start.dx);

    // Stop arrow slightly before node center
    final double offsetDist = 22.0;
    final Offset arrowTip = Offset(
      end.dx - offsetDist * cos(angle),
      end.dy - offsetDist * sin(angle),
    );

    final Path path = Path();
    path.moveTo(arrowTip.dx, arrowTip.dy);
    path.lineTo(
      arrowTip.dx - arrowSize * cos(angle - pi / 6),
      arrowTip.dy - arrowSize * sin(angle - pi / 6),
    );
    path.lineTo(
      arrowTip.dx - arrowSize * cos(angle + pi / 6),
      arrowTip.dy - arrowSize * sin(angle + pi / 6),
    );
    path.close();

    final Paint arrowPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, arrowPaint);
  }

  static double _getNodeRadius(NetworkNodeModel node) {
    return (16.0 + (node.degreeCentrality * 32.0)).clamp(16.0, 44.0);
  }

  static Color _getNodeColor(NetworkNodeModel node, {bool isSelected = false}) {
    if (isSelected) return Colors.amber.shade600;
    if (node.rank <= 3 || node.isMisinformationHub) return const Color(0xFFE53935); // Crimson High Risk
    if (node.rank <= 10) return const Color(0xFFFB8C00); // Orange Moderate
    if (node.rank <= 25) return const Color(0xFF1E88E5); // Blue Active
    return const Color(0xFF546E7A); // Slate Standard
  }

  @override
  bool shouldRepaint(covariant NetworkGraphPainter oldDelegate) {
    return oldDelegate.nodes != nodes ||
        oldDelegate.edges != edges ||
        oldDelegate.selectedNode != selectedNode ||
        oldDelegate.searchQuery != searchQuery ||
        oldDelegate.nodePositions != nodePositions;
  }
}
