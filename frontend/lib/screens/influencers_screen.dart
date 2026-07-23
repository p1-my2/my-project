import 'package:flutter/material.dart';

import '../models/influencer_model.dart';
import '../services/analysis_service.dart';

class InfluencersScreen extends StatefulWidget {
  const InfluencersScreen({super.key});

  @override
  State<InfluencersScreen> createState() => _InfluencersScreenState();
}

class _InfluencersScreenState extends State<InfluencersScreen> {
  final AnalysisService service = AnalysisService();

  late Future<List<InfluencerModel>> influencers;

  @override
  void initState() {
    super.initState();
    influencers = service.getInfluencers();
  }

  void refreshInfluencers() {
    setState(() {
      influencers = service.getInfluencers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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

          Expanded(
            child: FutureBuilder<List<InfluencerModel>>(
              future: influencers,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                }

                if (!snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      "No influencers found.",
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                final data = snapshot.data!;

                return Card(
                  elevation: 2,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor:
                          WidgetStatePropertyAll(
                        Colors.blueGrey.shade100,
                      ),
                      columns: const [
                        DataColumn(label: Text("Rank")),
                        DataColumn(label: Text("User")),
                        DataColumn(
                            label:
                                Text("Interactions")),
                      ],
                      rows: List.generate(
                        data.length,
                        (index) {
                          final user = data[index];

                          return DataRow(
                            cells: [
                              DataCell(
                                  Text("${index + 1}")),
                              DataCell(
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.person,
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(
                                        width: 8),
                                    Text(user.sourceUser),
                                  ],
                                ),
                              ),
                              DataCell(Text(
                                  user.interactions
                                      .toString())),
                            ],
                          );
                        },
                      ),
                    ),
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