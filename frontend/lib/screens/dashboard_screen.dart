import 'package:flutter/material.dart';

import '../models/dataset_model.dart';
import '../services/analysis_service.dart';
import 'dashboard_home.dart';
import 'datasets_screen.dart';
import 'hashtags_screen.dart';
import 'influencers_screen.dart';
import 'network_analysis_screen.dart';
import 'reports_screen.dart';
import 'timeline_screen.dart';
import 'login_screen.dart';

import '../widgets/side_menu.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;
  int? selectedDatasetId;
  List<DatasetModel> datasets = [];

  @override
  void initState() {
    super.initState();
    _fetchDatasets();
  }

  Future<void> _fetchDatasets() async {
    try {
      final result = await AnalysisService().getDatasets();
      if (mounted) {
        setState(() {
          datasets = result;
        });
      }
    } catch (e) {
      // Failed to load datasets
    }
  }

  void _onDatasetChanged(int? id) {
    setState(() {
      selectedDatasetId = id;
    });
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return DashboardHome(
          datasetId: selectedDatasetId,
          datasets: datasets,
          onDatasetChanged: _onDatasetChanged,
        );
      case 1:
        return const DatasetsScreen();
      case 2:
        return InfluencersScreen(datasetId: selectedDatasetId);
      case 3:
        return HashtagsScreen(datasetId: selectedDatasetId);
      case 4:
        return TimelineScreen(datasetId: selectedDatasetId);
      case 5:
        return NetworkAnalysisScreen(datasetId: selectedDatasetId);
      case 6:
        return ReportsScreen(datasetId: selectedDatasetId);
      default:
        return DashboardHome(
          datasetId: selectedDatasetId,
          datasets: datasets,
          onDatasetChanged: _onDatasetChanged,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: const Text('Misinformation Dashboard'),
              backgroundColor: Colors.blueGrey.shade900,
              foregroundColor: Colors.white,
            )
          : null,
      drawer: isMobile
          ? Drawer(
              child: SideMenu(
                selectedIndex: selectedIndex,
                onItemSelected: (index) {
                  Navigator.pop(context); // Close drawer
                  if (index == 7) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                    return;
                  }

                  setState(() {
                    selectedIndex = index;
                  });
                },
              ),
            )
          : null,
      body: Row(
        children: [
          if (!isMobile)
            SideMenu(
              selectedIndex: selectedIndex,
              onItemSelected: (index) {
                if (index == 7) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                  return;
                }

                setState(() {
                  selectedIndex = index;
                });
              },
            ),
          Expanded(
            child: _buildPage(selectedIndex),
          ),
        ],
      ),
    );
  }
}
