import 'package:flutter/material.dart';

import '../models/influencer_model.dart';
import '../services/analysis_service.dart';
import '../widgets/influencer_chart.dart';

class InfluencersScreen extends StatefulWidget {
  final int? datasetId;

  const InfluencersScreen({super.key, this.datasetId});

  @override
  State<InfluencersScreen> createState() => _InfluencersScreenState();
}

class _InfluencersScreenState extends State<InfluencersScreen> {
  final AnalysisService service = AnalysisService();

  late Future<List<InfluencerModel>> influencers;

  @override
  void initState() {
    super.initState();
    influencers = service.getInfluencers(datasetId: widget.datasetId);
  }

  @override
  void didUpdateWidget(covariant InfluencersScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.datasetId != widget.datasetId) {
      refreshInfluencers();
    }
  }

  void refreshInfluencers() {
    setState(() {
      influencers = service.getInfluencers(datasetId: widget.datasetId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Top Influencers",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: refreshInfluencers,
                icon: const Icon(Icons.refresh),
                label: const Text("Refresh"),
              ),
            ],
          ),

          const SizedBox(height: 20),

          FutureBuilder<List<InfluencerModel>>(
            future: influencers,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 50),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 50),
                  child: Center(
                    child: Text(
                      "No influencers found.",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                );
              }

              final data = snapshot.data!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: InfluencerChart(data: data),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Card(
                    elevation: 2,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStatePropertyAll(
                          Colors.blueGrey.shade100,
                        ),
                        columns: const [
                          DataColumn(label: Text("Rank")),
                          DataColumn(label: Text("User")),
                          DataColumn(label: Text("Interactions")),
                        ],
                        rows: List.generate(
                          data.length,
                          (index) {
                            final user = data[index];

                            return DataRow(
                              cells: [
                                DataCell(Text("${index + 1}")),
                                DataCell(
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.person,
                                        color: Colors.blue,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(user.sourceUser),
                                    ],
                                  ),
                                ),
                                DataCell(
                                  Text(user.interactions.toString()),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}