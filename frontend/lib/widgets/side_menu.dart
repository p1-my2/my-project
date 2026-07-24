import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/login_screen.dart';

class SideMenu extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const SideMenu({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  Future<void> _handleLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    await prefs.remove("name");
    await prefs.remove("email");
    await prefs.remove("role");
    await prefs.clear();

    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: Colors.blueGrey.shade900,
      child: Column(
        children: [
          const SizedBox(height: 40),

          const Icon(
            Icons.analytics,
            color: Colors.white,
            size: 60,
          ),

          const SizedBox(height: 10),

          const Text(
            "MISINFORMATION\nDASHBOARD",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          const Divider(color: Colors.white24),

          _menuItem(context, Icons.dashboard, "Dashboard", 0),
          _menuItem(context, Icons.folder, "Datasets", 1),
          _menuItem(context, Icons.people, "Influencers", 2),
          _menuItem(context, Icons.tag, "Hashtags", 3),
          _menuItem(context, Icons.timeline, "Timeline", 4),
          _menuItem(context, Icons.hub, "Network Analysis", 5),
          _menuItem(context, Icons.description, "Reports", 6),

          const Spacer(),

          _menuItem(context, Icons.logout, "Logout", 7),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _menuItem(BuildContext context, IconData icon, String title, int index) {
    final selected = selectedIndex == index;

    return InkWell(
      onTap: () {
        if (index == 7) {
          _handleLogout(context);
        } else {
          onItemSelected(index);
        }
      },
      child: Container(
        color: selected ? Colors.blue : Colors.transparent,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 15),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}