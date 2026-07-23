import 'package:flutter/material.dart';

import '../models/dataset_model.dart';
import '../services/analysis_service.dart';
import '../services/upload_service.dart';

class DatasetsScreen extends StatefulWidget {
  const DatasetsScreen({super.key});

  @override
  State<DatasetsScreen> createState() => _DatasetsScreenState();
}

class _DatasetsScreenState extends State<DatasetsScreen> {
  final AnalysisService service = AnalysisService();
  final UploadService uploadService = UploadService();

  bool isUploading = false;

  late Future<List<DatasetModel>> datasets;

  @override
  void initState() {
    super.initState();
    datasets = service.getDatasets();
  }

  void refreshDatasets() {
    setState(() {
      datasets = service.getDatasets();
    });
  }

  Future<void> uploadCsv() async {
    setState(() {
      isUploading = true;
    });

    try {
      final result = await uploadService.uploadDataset();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result["message"]),
          backgroundColor: Colors.green,
        ),
      );

      refreshDatasets();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (!mounted) return;

    setState(() {
      isUploading = false;
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
                "Datasets",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: isUploading ? null : uploadCsv,
                icon: isUploading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.upload_file),
                label: Text(
                  isUploading ? "Uploading..." : "Upload CSV",
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Expanded(
            child: FutureBuilder<List<DatasetModel>>(
              future: datasets,
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

                if (data.isEmpty) {
                  return const Center(
                    child: Text(
                      "No datasets available.",
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStatePropertyAll(
                      Colors.blueGrey.shade100,
                    ),
                    columns: const [
                      DataColumn(label: Text("ID")),
                      DataColumn(label: Text("Filename")),
                      DataColumn(label: Text("Uploaded By")),
                      DataColumn(label: Text("Status")),
                      DataColumn(label: Text("Upload Date")),
                    ],
                    rows: data.map((dataset) {
                      return DataRow(
                        cells: [
                          DataCell(Text(dataset.id.toString())),
                          DataCell(Text(dataset.filename)),
                          DataCell(Text(dataset.uploadedBy)),
                          DataCell(Text(dataset.status)),
                          DataCell(
                            Text(dataset.uploadDate.substring(0, 10)),
                          ),
                        ],
                      );
                    }).toList(),
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