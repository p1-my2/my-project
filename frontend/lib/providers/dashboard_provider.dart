import 'package:flutter/material.dart';
import '../models/dashboard_summary.dart';
import '../models/dataset_model.dart';
import '../models/hashtag_model.dart';
import '../models/influencer_model.dart';
import '../models/network_model.dart';
import '../models/timeline_model.dart';
import '../services/analysis_service.dart';

class DashboardProvider extends ChangeNotifier {
  final AnalysisService _analysisService = AnalysisService();

  int? _selectedDatasetId;
  List<DatasetModel> _datasets = [];
  DashboardSummary? _summary;
  NetworkDataModel? _networkData;
  List<TimelineModel> _timelineData = [];
  List<HashtagModel> _hashtags = [];
  List<InfluencerModel> _influencers = [];
  NetworkFilterModel _filter = NetworkFilterModel();

  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  int? get selectedDatasetId => _selectedDatasetId;
  List<DatasetModel> get datasets => _datasets;
  DashboardSummary? get summary => _summary;
  NetworkDataModel? get networkData => _networkData;
  List<TimelineModel> get timelineData => _timelineData;
  List<HashtagModel> get hashtags => _hashtags;
  List<InfluencerModel> get influencers => _influencers;
  NetworkFilterModel get filter => _filter;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _datasets = await _analysisService.getDatasets();
      if (_datasets.isNotEmpty && _selectedDatasetId == null) {
        _selectedDatasetId = _datasets.first.id;
      }
      await loadDatasetData();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectDataset(int? datasetId) async {
    if (_selectedDatasetId == datasetId) return;
    _selectedDatasetId = datasetId;
    await loadDatasetData();
  }

  Future<void> loadDatasetData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _analysisService.getDashboardSummary(datasetId: _selectedDatasetId),
        _analysisService.getNetworkData(datasetId: _selectedDatasetId),
        _analysisService.getTimeline(datasetId: _selectedDatasetId),
        _analysisService.getHashtags(datasetId: _selectedDatasetId),
        _analysisService.getInfluencers(datasetId: _selectedDatasetId),
      ]);

      _summary = results[0] as DashboardSummary;
      _networkData = results[1] as NetworkDataModel;
      _timelineData = results[2] as List<TimelineModel>;
      _hashtags = results[3] as List<HashtagModel>;
      _influencers = results[4] as List<InfluencerModel>;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateFilter(NetworkFilterModel newFilter) {
    _filter = newFilter;
    notifyListeners();
  }
}
