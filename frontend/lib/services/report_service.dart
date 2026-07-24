import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../models/report_model.dart';
import 'download_helper.dart';

class ReportService {
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    return {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    };
  }

  static Future<List<ReportModel>> getReports() async {
    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/reports"),
      headers: await _getHeaders(),
    );

    final json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final List rawData =
          json is List ? json : (json["data"] ?? json["reports"] ?? []);
      return rawData.map((e) => ReportModel.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      final msg = (json is Map && json["message"] != null)
          ? json["message"].toString()
          : "Failed to fetch reports.";
      throw Exception(msg);
    }
  }

  static Future<void> downloadPdf(int datasetId, String filename) async {
    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/reports/pdf/$datasetId"),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      await downloadFile(response.bodyBytes, filename);
    } else {
      String message = "Failed to download PDF report.";
      try {
        final json = jsonDecode(response.body);
        if (json is Map && json["message"] != null) {
          message = json["message"].toString();
        }
      } catch (_) {}
      throw Exception(message);
    }
  }

  static Future<void> downloadCsv(int datasetId, String filename) async {
    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/reports/csv/$datasetId"),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      await downloadFile(response.bodyBytes, filename);
    } else {
      String message = "Failed to download CSV report.";
      try {
        final json = jsonDecode(response.body);
        if (json is Map && json["message"] != null) {
          message = json["message"].toString();
        }
      } catch (_) {}
      throw Exception(message);
    }
  }
}
