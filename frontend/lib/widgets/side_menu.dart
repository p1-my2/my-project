import 'package:flutter/material.dart';

class SideMenu extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const SideMenu({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

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

          _menuItem(Icons.dashboard, "Dashboard", 0),
          _menuItem(Icons.folder, "Datasets", 1),
          _menuItem(Icons.people, "Influencers", 2),
          _menuItem(Icons.tag, "Hashtags", 3),
          _menuItem(Icons.timeline, "Timeline", 4),
          _menuItem(Icons.description, "Reports", 5),

          const Spacer(),

          _menuItem(Icons.logout, "Logout", 6),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, int index) {
    final selected = selectedIndex == index;

    return InkWell(
      onTap: () => onItemSelected(index),
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