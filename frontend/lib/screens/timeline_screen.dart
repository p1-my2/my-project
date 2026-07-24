import 'package:flutter/material.dart';

import '../models/timeline_model.dart';
import '../services/analysis_service.dart';
import '../widgets/timeline_chart.dart';

class TimelineScreen extends StatefulWidget {
  final int? datasetId;

  const TimelineScreen({super.key, this.datasetId});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  final AnalysisService service = AnalysisService();

  late Future<List<TimelineModel>> timeline;

  @override
  void initState() {
    super.initState();
    timeline = service.getTimeline(datasetId: widget.datasetId);
  }

  @override
  void didUpdateWidget(covariant TimelineScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.datasetId != widget.datasetId) {
      refreshTimeline();
    }
  }

  void refreshTimeline() {
    setState(() {
      timeline = service.getTimeline(datasetId: widget.datasetId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Timeline Analysis",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: refreshTimeline,
                icon: const Icon(Icons.refresh),
                label: const Text("Refresh"),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: FutureBuilder<List<TimelineModel>>(
              future: timeline,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      "No timeline data available.",
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                final data = snapshot.data!;

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: TimelineChart(data: data),
                        ),
                      ),
                      const SizedBox(height: 25),
                      Card(
                        elevation: 2,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: WidgetStatePropertyAll(
                              theme.colorScheme.surfaceContainerHighest,
                            ),
                            columns: const [
                              DataColumn(label: Text("Date")),
                              DataColumn(label: Text("Total Posts")),
                              DataColumn(label: Text("Misinformation Posts")),
                            ],
                            rows: data.map((item) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(item.date)),
                                  DataCell(Text(item.posts.toString())),
                                  DataCell(Text(item.misinformationPosts.toString())),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}