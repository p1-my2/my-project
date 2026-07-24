import 'package:flutter/material.dart';

class NetworkLegendWidget extends StatefulWidget {
  final bool isCollapsible;

  const NetworkLegendWidget({
    super.key,
    this.isCollapsible = true,
  });

  @override
  State<NetworkLegendWidget> createState() => _NetworkLegendWidgetState();
}

class _NetworkLegendWidgetState extends State<NetworkLegendWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.isCollapsible) {
      return _buildContent(context);
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFF1E293B).withValues(alpha: 0.92),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.info_outline, color: Colors.amber, size: 18),
                  const SizedBox(width: 8),
                  const Text(
                    'Network Legend & SNA Guide',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white70,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: _buildContent(context),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Node Visual Encoding:',
            style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 6),
          _legendRow(Colors.red.shade600, 'Top 3 Hubs / Misinformation Superspreaders'),
          _legendRow(Colors.orange.shade600, 'Top 10 High Influence Users'),
          _legendRow(Colors.blue.shade600, 'Top 25 Active Network Participants'),
          _legendRow(Colors.blueGrey, 'Standard Network Account'),
          const Divider(color: Colors.white24, height: 16),
          const Text(
            'SNA Metrics Reference:',
            style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 4),
          _infoText('• Node Size: Scaled by Degree Centrality (total connections).'),
          _infoText('• Arrow Edges: Direction of interaction (Source -> Target).'),
          _infoText('• Network Density: Ratio of actual connections to total possible connections.'),
          _infoText('• In/Out Degree: Inbound retweets vs Outbound shares.'),
        ],
      ),
    );
  }

  Widget _legendRow(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white60, fontSize: 10.5),
      ),
    );
  }
}
