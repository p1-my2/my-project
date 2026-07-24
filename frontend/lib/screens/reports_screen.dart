import 'package:flutter/material.dart';

import '../models/report_model.dart';
import '../services/report_service.dart';

class ReportsScreen extends StatefulWidget {
  final int? datasetId;

  const ReportsScreen({super.key, this.datasetId});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _isLoading = true;
  List<ReportModel> _reports = [];

  final Set<int> _downloadingPdfIds = {};
  final Set<int> _downloadingCsvIds = {};

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  @override
  void didUpdateWidget(covariant ReportsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.datasetId != widget.datasetId) {
      _fetchReports();
    }
  }

  Future<void> _fetchReports() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final reports = await ReportService.getReports();
      if (mounted) {
        setState(() {
          _reports = reports;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load reports: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _handleDownloadPdf(ReportModel report) async {
    if (_downloadingPdfIds.contains(report.id)) return;

    setState(() {
      _downloadingPdfIds.add(report.id);
    });

    final safeFilename = '${report.title.replaceAll(RegExp(r'[^\w\.-]'), '_')}_${report.id}.pdf';

    try {
      await ReportService.downloadPdf(report.datasetId, safeFilename);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF report downloaded for "${report.title}"'),
            backgroundColor: Colors.green.shade700,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF Download failed: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _downloadingPdfIds.remove(report.id);
        });
      }
    }
  }

  Future<void> _handleDownloadCsv(ReportModel report) async {
    if (_downloadingCsvIds.contains(report.id)) return;

    setState(() {
      _downloadingCsvIds.add(report.id);
    });

    final safeFilename = '${report.title.replaceAll(RegExp(r'[^\w\.-]'), '_')}_${report.id}.csv';

    try {
      await ReportService.downloadCsv(report.datasetId, safeFilename);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('CSV report exported for "${report.title}"'),
            backgroundColor: Colors.green.shade700,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('CSV Export failed: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _downloadingCsvIds.remove(report.id);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayedReports = widget.datasetId != null
        ? _reports.where((r) => r.datasetId == widget.datasetId).toList()
        : _reports;

    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Reports",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "View and export generated intelligence reports",
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              IconButton.filledTonal(
                onPressed: _isLoading ? null : _fetchReports,
                icon: const Icon(Icons.refresh),
                tooltip: "Refresh Reports",
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : displayedReports.isEmpty
                    ? Card(
                        elevation: 2,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(30.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.description_outlined,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  "No reports available",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  "Generate an analysis report after uploading and analysing a dataset.",
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),
                                OutlinedButton.icon(
                                  onPressed: _fetchReports,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text("Refresh"),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: displayedReports.length,
                        itemBuilder: (context, index) {
                          final report = displayedReports[index];
                          final isDownloadingPdf =
                              _downloadingPdfIds.contains(report.id);
                          final isDownloadingCsv =
                              _downloadingCsvIds.contains(report.id);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primaryContainer,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          "#${report.id}",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.onPrimaryContainer,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          report.title,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 20,
                                    runSpacing: 8,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.storage_outlined,
                                            size: 18,
                                            color: theme.colorScheme.secondary,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            "Dataset: ${report.datasetName}",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: theme.colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.access_time_outlined,
                                            size: 18,
                                            color: theme.colorScheme.secondary,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            "Generated: ${report.generatedAt.isNotEmpty ? report.generatedAt : 'N/A'}",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: theme.colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  const Divider(),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 8,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: (isDownloadingPdf || isDownloadingCsv)
                                            ? null
                                            : () => _handleDownloadPdf(report),
                                        icon: isDownloadingPdf
                                            ? const SizedBox(
                                                width: 18,
                                                height: 18,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.redAccent,
                                                ),
                                              )
                                            : const Icon(
                                                Icons.picture_as_pdf,
                                                color: Colors.redAccent,
                                              ),
                                        label: Text(
                                          isDownloadingPdf
                                              ? "Downloading PDF..."
                                              : "Generate PDF",
                                          style: const TextStyle(
                                            color: Colors.redAccent,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red.shade50,
                                          elevation: 0,
                                        ),
                                      ),
                                      ElevatedButton.icon(
                                        onPressed: (isDownloadingPdf || isDownloadingCsv)
                                            ? null
                                            : () => _handleDownloadCsv(report),
                                        icon: isDownloadingCsv
                                            ? const SizedBox(
                                                width: 18,
                                                height: 18,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.green,
                                                ),
                                              )
                                            : const Icon(
                                                Icons.table_chart,
                                                color: Colors.green,
                                              ),
                                        label: Text(
                                          isDownloadingCsv
                                              ? "Exporting CSV..."
                                              : "Export CSV",
                                          style: const TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green.shade50,
                                          elevation: 0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
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