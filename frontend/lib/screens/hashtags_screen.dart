import 'package:flutter/material.dart';

import '../models/hashtag_model.dart';
import '../services/analysis_service.dart';

class HashtagsScreen extends StatefulWidget {
  const HashtagsScreen({super.key});

  @override
  State<HashtagsScreen> createState() => _HashtagsScreenState();
}

class _HashtagsScreenState extends State<HashtagsScreen> {
  final AnalysisService service = AnalysisService();

  late Future<List<HashtagModel>> hashtags;

  @override
  void initState() {
    super.initState();
    hashtags = service.getHashtags();
  }

  void refreshHashtags() {
    setState(() {
      hashtags = service.getHashtags();
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
                "Trending Hashtags",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: refreshHashtags,
                icon: const Icon(Icons.refresh),
                label: const Text("Refresh"),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Expanded(
            child: FutureBuilder<List<HashtagModel>>(
              future: hashtags,
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
                      "No hashtags found.",
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
                      headingRowColor: WidgetStatePropertyAll(
                        Colors.blueGrey.shade100,
                      ),
                      columns: const [
                        DataColumn(
                          label: Text(
                            "Rank",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            "Hashtag",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataColumn(
                          numeric: true,
                          label: Text(
                            "Frequency",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      rows: List.generate(
                        data.length,
                        (index) {
                          final tag = data[index];

                          return DataRow(
                            cells: [
                              DataCell(
                                Text("${index + 1}"),
                              ),
                              DataCell(
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.tag,
                                      color: Colors.blue,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(tag.hashtag),
                                  ],
                                ),
                              ),
                              DataCell(
                                Text(
                                  tag.count.toString(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
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