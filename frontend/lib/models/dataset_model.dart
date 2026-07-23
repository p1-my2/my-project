class DatasetModel {
  final int id;
  final String filename;
  final String uploadDate;
  final String status;
  final String uploadedBy;

  DatasetModel({
    required this.id,
    required this.filename,
    required this.uploadDate,
    required this.status,
    required this.uploadedBy,
  });

  factory DatasetModel.fromJson(Map<String, dynamic> json) {
  return DatasetModel(
    id: json["id"] ?? 0,
    filename: json["filename"] ?? "Unknown",
    uploadDate: json["uploadDate"] ?? "",
    status: json["status"] ?? "Unknown",
    uploadedBy: json["uploadedBy"]?["name"] ?? "Unknown",
  );

  }
}