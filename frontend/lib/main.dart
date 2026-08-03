import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/research_theme.dart';
import 'providers/dashboard_provider.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MisinformationDashboardApp());
}

class MisinformationDashboardApp extends StatelessWidget {
  const MisinformationDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => DashboardProvider()..initialize(),
        ),
      ],
      child: MaterialApp(
        title: 'Research Intelligence Dashboard',
        debugShowCheckedModeBanner: false,
        theme: ResearchTheme.lightThemeData,
        darkTheme: ResearchTheme.darkThemeData,
        themeMode: ThemeMode.system,
        home: const LoginScreen(),
      ),
    );
  }
}