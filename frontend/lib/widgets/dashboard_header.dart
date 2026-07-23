import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          "Dashboard Overview",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        CircleAvatar(
          backgroundColor: Colors.blue,
          child: const Icon(
            Icons.person,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}