import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MisinformationDashboardApp());
}

class MisinformationDashboardApp extends StatelessWidget {
  const MisinformationDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Misinformation Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}