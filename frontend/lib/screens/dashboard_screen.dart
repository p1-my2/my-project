import 'package:flutter/material.dart';

import 'dashboard_home.dart';
import 'datasets_screen.dart';
import 'hashtags_screen.dart';
import 'influencers_screen.dart';
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

  final List<Widget> pages = [
  const DashboardHome(),
  const DatasetsScreen(),
  const InfluencersScreen(),
  const HashtagsScreen(),
  const TimelineScreen(),
  const ReportsScreen(),
];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [

          SideMenu(
            selectedIndex: selectedIndex,
            onItemSelected: (index) {
              if (index == 6) {
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
            child: pages[selectedIndex],
          ),
        ],
      ),
    );
  }
}

