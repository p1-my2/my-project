import 'package:flutter/material.dart';

import '../models/dashboard_summary.dart';
import '../models/dataset_model.dart';
import '../models/hashtag_model.dart';
import '../services/analysis_service.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/dashboard_header.dart';

class DashboardHome extends StatefulWidget {
  final int? datasetId;
  final List<DatasetModel> datasets;
  final ValueChanged<int?>? onDatasetChanged;

  const DashboardHome({
    super.key,
    this.datasetId,
    this.datasets = const [],
    this.onDatasetChanged,
  });

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  final AnalysisService analysisService = AnalysisService();

  late Future<DashboardSummary> dashboard;
  late Future<List<HashtagModel>> hashtags;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    dashboard = analysisService.getDashboardSummary(datasetId: widget.datasetId);
    hashtags = analysisService.getHashtags(datasetId: widget.datasetId);
  }

  @override
  void didUpdateWidget(covariant DashboardHome oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.datasetId != widget.datasetId) {
      setState(() {
        _loadData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DashboardSummary>(
      future: dashboard,
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

        final data = snapshot.data!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              DashboardHeader(
                datasets: widget.datasets,
                selectedDatasetId: widget.datasetId,
                onDatasetChanged: widget.onDatasetChanged,
              ),

              const SizedBox(height: 30),

              Wrap(
                spacing: 20,
                runSpacing: 20,
                children: [

                  SizedBox(
                    width: 250,
                    child: DashboardCard(
                      title: "Users",
                      value: data.totalUsers.toString(),
                      icon: Icons.people,
                      color: Colors.blue,
                    ),
                  ),

                  SizedBox(
                    width: 250,
                    child: DashboardCard(
                      title: "Datasets",
                      value: data.totalDatasets.toString(),
                      icon: Icons.folder,
                      color: Colors.orange,
                    ),
                  ),

                  SizedBox(
                    width: 250,
                    child: DashboardCard(
                      title: "Posts",
                      value: data.totalPosts.toString(),
                      icon: Icons.article,
                      color: Colors.green,
                    ),
                  ),

                  SizedBox(
                    width: 250,
                    child: DashboardCard(
                      title: "Hashtags",
                      value: data.totalHashtags.toString(),
                      icon: Icons.tag,
                      color: Colors.purple,
                    ),
                  ),

                  SizedBox(
                    width: 250,
                    child: DashboardCard(
                      title: "Reports",
                      value: data.totalReports.toString(),
                      icon: Icons.description,
                      color: Colors.red,
                    ),
                  ),

                  SizedBox(
                    width: 250,
                    child: DashboardCard(
                      title: "Misinformation",
                      value: data.misinformationPosts.toString(),
                      icon: Icons.warning,
                      color: Colors.deepOrange,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              const Text(
                "Recent Activity",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: const [

                      ListTile(
                        leading: Icon(Icons.upload_file,
                            color: Colors.blue),
                        title: Text("Dataset Uploaded"),
                        subtitle: Text("twitter_dataset.csv"),
                      ),

                      Divider(),

                      ListTile(
                        leading: Icon(Icons.analytics,
                            color: Colors.green),
                        title: Text("Analysis Completed"),
                        subtitle: Text("5 posts analysed successfully"),
                      ),

                      Divider(),

                      ListTile(
                        leading: Icon(Icons.tag,
                            color: Colors.orange),
                        title: Text("Hashtags Extracted"),
                        subtitle: Text("7 hashtags detected"),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 35),

              const Text(
                "Top Hashtags",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              FutureBuilder<List<HashtagModel>>(
                future: hashtags,
                builder: (context, tags) {
                  if (tags.hasError) return const Text("Unable to load hashtags.");
                  if (!tags.hasData) return const Center(child: CircularProgressIndicator());
                  if (tags.data!.isEmpty) return const Text("Upload a dataset to view trending hashtags.");
                  return Card(child: Column(children: tags.data!.take(5).map((tag) => ListTile(
                    leading: const Icon(Icons.tag, color: Colors.blue), title: Text(tag.hashtag),
                    trailing: Text(tag.count.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                  )).toList()));
                },
              ),

            ],
          ),
        );
      },
    );
  }
}
