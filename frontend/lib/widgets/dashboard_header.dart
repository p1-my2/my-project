import 'package:flutter/material.dart';

import '../models/dataset_model.dart';

class DashboardHeader extends StatelessWidget {
  final String title;
  final List<DatasetModel> datasets;
  final int? selectedDatasetId;
  final ValueChanged<int?>? onDatasetChanged;

  const DashboardHeader({
    super.key,
    this.title = "Dashboard Overview",
    this.datasets = const [],
    this.selectedDatasetId,
    this.onDatasetChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasSelected = selectedDatasetId == null ||
        datasets.any((d) => d.id == selectedDatasetId);
    final int? activeValue = hasSelected ? selectedDatasetId : null;

    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int?>(
              value: activeValue,
              hint: const Text("All Datasets"),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text("All Datasets"),
                ),
                ...datasets.map((dataset) {
                  return DropdownMenuItem<int?>(
                    value: dataset.id,
                    child: Text(dataset.filename),
                  );
                }),
              ],
              onChanged: onDatasetChanged,
            ),
          ),
        ),
        const SizedBox(width: 15),
        const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(
            Icons.person,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}