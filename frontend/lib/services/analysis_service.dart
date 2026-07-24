import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../models/dashboard_summary.dart';
import '../models/dataset_model.dart';
import '../models/hashtag_model.dart';
import '../models/influencer_model.dart';
import '../models/network_model.dart';
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
  Future<DashboardSummary> getDashboardSummary({int? datasetId}) async {
    final String url = datasetId != null
        ? "${ApiConfig.baseUrl}/analysis/dashboard?datasetId=$datasetId"
        : "${ApiConfig.baseUrl}/analysis/dashboard";

    final response = await http.get(
      Uri.parse(url),
      headers: await _getHeaders(),
    );

    final json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return DashboardSummary.fromJson(json["data"]);
    }

    throw Exception(json["message"] ?? "Failed to load dashboard.");
  }

  /// Top Hashtags
  Future<List<HashtagModel>> getHashtags({int? datasetId}) async {
    final String url = datasetId != null
        ? "${ApiConfig.baseUrl}/analysis/hashtags?datasetId=$datasetId"
        : "${ApiConfig.baseUrl}/analysis/hashtags";

    final response = await http.get(
      Uri.parse(url),
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
  Future<List<InfluencerModel>> getInfluencers({int? datasetId}) async {
    final String url = datasetId != null
        ? "${ApiConfig.baseUrl}/analysis/influencers?datasetId=$datasetId"
        : "${ApiConfig.baseUrl}/analysis/influencers";

    final response = await http.get(
      Uri.parse(url),
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
  Future<List<TimelineModel>> getTimeline({int? datasetId}) async {
    final String url = datasetId != null
        ? "${ApiConfig.baseUrl}/analysis/timeline?datasetId=$datasetId"
        : "${ApiConfig.baseUrl}/analysis/timeline";

    final response = await http.get(
      Uri.parse(url),
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

  /// Network Statistics & Graph Data
  Future<NetworkDataModel> getNetworkData({int? datasetId}) async {
    final String url = datasetId != null
        ? "${ApiConfig.baseUrl}/analysis/network?datasetId=$datasetId"
        : "${ApiConfig.baseUrl}/analysis/network";

    final response = await http.get(
      Uri.parse(url),
      headers: await _getHeaders(),
    );

    final json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return NetworkDataModel.fromJson(json["data"]);
    }

    throw Exception(json["message"] ?? "Failed to load network graph data.");
  }
}