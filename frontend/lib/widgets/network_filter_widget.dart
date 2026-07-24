import 'package:flutter/material.dart';
import '../models/dataset_model.dart';
import '../models/network_model.dart';

class NetworkFilterWidget extends StatefulWidget {
  final NetworkFilterModel filter;
  final List<DatasetModel> datasets;
  final int? selectedDatasetId;
  final Function(int? datasetId) onDatasetChanged;
  final Function(NetworkFilterModel filter) onFilterChanged;
  final VoidCallback onReset;

  const NetworkFilterWidget({
    super.key,
    required this.filter,
    required this.datasets,
    required this.selectedDatasetId,
    required this.onDatasetChanged,
    required this.onFilterChanged,
    required this.onReset,
  });

  @override
  State<NetworkFilterWidget> createState() => _NetworkFilterWidgetState();
}

class _NetworkFilterWidgetState extends State<NetworkFilterWidget> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.filter.searchQuery);
  }

  @override
  void didUpdateWidget(covariant NetworkFilterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filter.searchQuery != widget.filter.searchQuery) {
      _searchController.text = widget.filter.searchQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Network Filters',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: widget.onReset,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Reset'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Dataset Selector
            const Text('Dataset', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int?>(
                  value: widget.selectedDatasetId,
                  isExpanded: true,
                  hint: const Text('All Datasets'),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('All Datasets'),
                    ),
                    ...widget.datasets.map((d) => DropdownMenuItem<int?>(
                          value: d.id,
                          child: Text(d.filename, overflow: TextOverflow.ellipsis),
                        )),
                  ],
                  onChanged: widget.onDatasetChanged,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Search Username
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Username',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                isDense: true,
              ),
              onChanged: (val) {
                widget.onFilterChanged(widget.filter.copyWith(searchQuery: val));
              },
            ),
            const SizedBox(height: 16),

            // Min Degree Slider
            Text('Minimum Degree (${widget.filter.minDegree})', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            Slider(
              value: widget.filter.minDegree.toDouble(),
              min: 0,
              max: 50,
              divisions: 50,
              label: widget.filter.minDegree.toString(),
              onChanged: (val) {
                widget.onFilterChanged(widget.filter.copyWith(minDegree: val.toInt()));
              },
            ),

            // Interaction Type Filter
            const Text('Interaction Type', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: ['All', 'retweet', 'mention', 'reply'].map((type) {
                final isSelected = widget.filter.interactionType == type;
                return ChoiceChip(
                  label: Text(type),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      widget.onFilterChanged(widget.filter.copyWith(interactionType: type));
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Show Only Misinformation Toggle
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Show Only Misinformation Hubs', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              value: widget.filter.showOnlyMisinformation,
              onChanged: (val) {
                widget.onFilterChanged(widget.filter.copyWith(showOnlyMisinformation: val));
              },
            ),
          ],
        ),
      ),
    );
  }
}
