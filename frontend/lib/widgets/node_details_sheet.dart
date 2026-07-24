import 'package:flutter/material.dart';
import '../models/network_model.dart';

class NodeDetailsWidget extends StatelessWidget {
  final NetworkNodeModel node;
  final List<NetworkEdgeModel> edges;
  final VoidCallback? onClose;

  const NodeDetailsWidget({
    super.key,
    required this.node,
    required this.edges,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    // Collect connected users
    final connectedUsers = <String>{};
    int totalInteractions = 0;

    for (final edge in edges) {
      if (edge.source == node.id) {
        connectedUsers.add(edge.target);
        totalInteractions++;
      } else if (edge.target == node.id) {
        connectedUsers.add(edge.source);
        totalInteractions++;
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: _getRankColor(node.rank),
                child: Text(
                  '#${node.rank}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      node.id,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Influence Rank #${node.rank} • Centrality: ${node.degreeCentrality.toStringAsFixed(3)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (onClose != null)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                ),
            ],
          ),
          const Divider(height: 28),
          Row(
            children: [
              _metricTile('Degree', node.degree.toString(), Colors.blue),
              _metricTile('In-Degree', node.inDegree.toString(), Colors.teal),
              _metricTile('Out-Degree', node.outDegree.toString(), Colors.indigo),
              _metricTile('Score', '${node.influenceScore.toStringAsFixed(1)}%', Colors.amber.shade800),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Connected Network (${connectedUsers.length} users, $totalInteractions interactions)',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: connectedUsers.take(8).map((u) => Chip(
              avatar: const Icon(Icons.person, size: 16),
              label: Text(u, style: const TextStyle(fontSize: 12)),
              visualDensity: VisualDensity.compact,
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _metricTile(String label, String value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    if (rank <= 3) return Colors.red.shade700;
    if (rank <= 10) return Colors.orange.shade700;
    if (rank <= 25) return Colors.blue.shade700;
    return Colors.blueGrey;
  }
}
