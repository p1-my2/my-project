class ReportModel {
  final int id;
  final String title;
  final String generatedAt;
  final int datasetId;
  final String datasetName;

  ReportModel({
    required this.id,
    required this.title,
    required this.generatedAt,
    required this.datasetId,
    required this.datasetName,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    final datasetId = json['datasetId'] != null
        ? (json['datasetId'] is int
            ? json['datasetId'] as int
            : int.tryParse(json['datasetId'].toString()) ?? 0)
        : (json['dataset'] != null && json['dataset'] is Map && json['dataset']['id'] != null
            ? (json['dataset']['id'] is int
                ? json['dataset']['id'] as int
                : int.tryParse(json['dataset']['id'].toString()) ?? 0)
            : 0);

    String? datasetName;
    if (json['dataset'] != null && json['dataset'] is Map && json['dataset']['filename'] != null) {
      datasetName = json['dataset']['filename'].toString();
    }
    if (datasetName == null || datasetName.trim().isEmpty) {
      datasetName = 'Dataset #$datasetId';
    }

    return ReportModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? 'Untitled Report',
      generatedAt: json['generatedAt']?.toString() ??
          json['createdAt']?.toString() ??
          '',
      datasetId: datasetId,
      datasetName: datasetName,
    );
  }
}
