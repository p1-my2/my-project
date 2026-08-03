import 'package:flutter/material.dart';
import '../config/research_theme.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        color: isDark ? ResearchTheme.darkSurface : ResearchTheme.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(
          color: isDark ? ResearchTheme.darkBorder : ResearchTheme.lightBorder,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: _getRankColor(node.rank),
                child: Text(
                  '#${node.rank}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '@${node.id}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? ResearchTheme.darkTextPrimary : ResearchTheme.lightTextPrimary,
                      ),
                    ),
                    Text(
                      'Influence Rank #${node.rank} • Centrality: ${node.degreeCentrality.toStringAsFixed(3)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? ResearchTheme.darkTextSecondary : ResearchTheme.lightTextSecondary,
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
          const Divider(height: 24),
          Row(
            children: [
              _metricTile('Degree', node.degree.toString(), Colors.blue, isDark),
              _metricTile('In-Degree', node.inDegree.toString(), Colors.teal, isDark),
              _metricTile('Out-Degree', node.outDegree.toString(), Colors.indigo, isDark),
              _metricTile('Reach Score', '${node.reachScore.round()}', ResearchTheme.riskHigh, isDark),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Connected Diffusion Network (${connectedUsers.length} users, $totalInteractions interactions)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isDark ? ResearchTheme.darkTextPrimary : ResearchTheme.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: connectedUsers.take(8).map((u) => Chip(
              avatar: const Icon(Icons.person_outline, size: 14),
              label: Text(u, style: const TextStyle(fontSize: 11)),
              visualDensity: VisualDensity.compact,
              backgroundColor: isDark ? ResearchTheme.darkBg : ResearchTheme.lightBg,
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _metricTile(String label, String value, Color color, bool isDark) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? ResearchTheme.darkTextSecondary : ResearchTheme.lightTextSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    if (rank <= 3) return ResearchTheme.riskHigh;
    if (rank <= 10) return ResearchTheme.riskModerate;
    if (rank <= 25) return ResearchTheme.darkPrimary;
    return ResearchTheme.riskNeutral;
  }
}
