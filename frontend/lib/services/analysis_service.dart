import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../models/dashboard_summary.dart';
import '../models/dataset_model.dart';
import '../models/hashtag_model.dart';
import '../models/influencer_model.dart';
import '../models/timeline_model.dart';

class AnalysisService {
  /// Returns authentication headers with JWT token
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    return {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    };
  }

  /// Dashboard Summary
  Future<DashboardSummary> getDashboardSummary() async {
    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/analysis/dashboard"),
      headers: await _getHeaders(),
    );

    final json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return DashboardSummary.fromJson(json["data"]);
    }

    throw Exception(json["message"] ?? "Failed to load dashboard.");
  }

  /// Top Hashtags
  Future<List<HashtagModel>> getHashtags() async {
    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/analysis/hashtags"),
      headers: await _getHeaders(),
    );

    final json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return (json["data"] as List)
          .map((e) => HashtagModel.fromJson(e))
          .toList();
    }

    throw Exception(json["message"] ?? "Unable to load hashtags.");
  }

  /// Uploaded Datasets
  Future<List<DatasetModel>> getDatasets() async {
    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/datasets"),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      return (json["data"] as List)
          .map((e) => DatasetModel.fromJson(e))
          .toList();
    }

    throw Exception("Failed to load datasets.");
  }

  /// Top Influencers
  Future<List<InfluencerModel>> getInfluencers() async {
    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/analysis/influencers"),
      headers: await _getHeaders(),
    );

    final json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return (json["data"] as List)
          .map((e) => InfluencerModel.fromJson(e))
          .toList();
    }

    throw Exception(json["message"] ?? "Failed to load influencers.");
  }

  /// Timeline Analysis
  Future<List<TimelineModel>> getTimeline() async {
    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/analysis/timeline"),
      headers: await _getHeaders(),
    );

    final json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return (json["data"] as List)
          .map((e) => TimelineModel.fromJson(e))
          .toList();
    }

    throw Exception(json["message"] ?? "Failed to load timeline.");
  }
}