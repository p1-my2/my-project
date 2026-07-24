import 'package:flutter/material.dart';
import '../models/network_model.dart';

class NetworkAnalyticsWidget extends StatelessWidget {
  final NetworkDataModel data;
  final bool isMobile;

  const NetworkAnalyticsWidget({
    super.key,
    required this.data,
    this.isMobile = false,
  });

  @override
  Widget build(BuildContext context) {
    final topUser = data.topInfluencer?.id ?? 'N/A';

    final cards = [
      _analyticsCard('Total Nodes', data.totalNodes.toString(), Icons.hub, Colors.blue),
      _analyticsCard('Total Edges', data.totalEdges.toString(), Icons.share, Colors.teal),
      _analyticsCard('Network Density', '${(data.density * 100).toStringAsFixed(2)}%', Icons.blur_on, Colors.purple),
      _analyticsCard('Avg Degree', data.averageDegree.toStringAsFixed(2), Icons.auto_graph, Colors.orange),
      _analyticsCard('Top Hub User', topUser, Icons.workspace_premium, Colors.red),
      _analyticsCard('Total Posts', data.totalPosts.toString(), Icons.article, Colors.indigo),
    ];

    if (isMobile) {
      return SizedBox(
        height: 100,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          itemCount: cards.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) => SizedBox(
            width: 150,
            child: cards[index],
          ),
        ),
      );
    }

    return Column(
      children: cards.map((c) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: SizedBox(width: double.infinity, child: c),
      )).toList(),
    );
  }

  Widget _analyticsCard(String title, String value, IconData icon, MaterialColor color) {
    return Card(
      elevation: 0,
      color: color.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color.shade900,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
