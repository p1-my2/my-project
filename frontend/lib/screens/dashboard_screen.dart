import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/side_menu.dart';
import 'dashboard_home.dart';
import 'datasets_screen.dart';
import 'hashtags_screen.dart';
import 'influencers_screen.dart';
import 'network_analysis_screen.dart';
import 'reports_screen.dart';
import 'timeline_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;

  Widget _buildPage(int index, int? datasetId) {
    switch (index) {
      case 0:
        return const DashboardHome();
      case 1:
        return const DatasetsScreen();
      case 2:
        return InfluencersScreen(datasetId: datasetId);
      case 3:
        return HashtagsScreen(datasetId: datasetId);
      case 4:
        return TimelineScreen(datasetId: datasetId);
      case 5:
        return NetworkAnalysisScreen(datasetId: datasetId);
      case 6:
        return ReportsScreen(datasetId: datasetId);
      default:
        return const DashboardHome();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              title: const Text('Misinformation Diffusion Analysis'),
              centerTitle: false,
            )
          : null,
      drawer: isMobile
          ? Drawer(
              child: SideMenu(
                selectedIndex: selectedIndex,
                onItemSelected: (index) {
                  Navigator.pop(context);
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
            child: _buildPage(selectedIndex, provider.selectedDatasetId),
          ),
        ],
      ),
    );
  }
}
