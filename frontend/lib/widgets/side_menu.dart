import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/research_theme.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: isDark ? ResearchTheme.darkSurface : ResearchTheme.lightSurface,
        border: Border(
          right: BorderSide(
            color: isDark ? ResearchTheme.darkBorder : ResearchTheme.lightBorder,
          ),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 30),

          CircleAvatar(
            radius: 28,
            backgroundColor: isDark ? ResearchTheme.darkPrimary.withValues(alpha: 0.2) : ResearchTheme.lightPrimary.withValues(alpha: 0.1),
            child: Icon(
              Icons.hub_outlined,
              color: isDark ? ResearchTheme.darkPrimary : ResearchTheme.lightPrimary,
              size: 32,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            "RESEARCH INTELLIGENCE\nDASHBOARD",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.6,
              color: isDark ? ResearchTheme.darkTextPrimary : ResearchTheme.lightTextPrimary,
            ),
          ),

          const SizedBox(height: 16),
          Divider(color: isDark ? ResearchTheme.darkBorder : ResearchTheme.lightBorder),

          Expanded(
            child: ListView(
              children: [
                _menuItem(context, Icons.dashboard_outlined, "Dashboard", 0, isDark),
                _menuItem(context, Icons.folder_open_outlined, "Datasets", 1, isDark),
                _menuItem(context, Icons.people_outline, "Top Spreaders", 2, isDark),
                _menuItem(context, Icons.numbers_outlined, "Hashtags", 3, isDark),
                _menuItem(context, Icons.show_chart_outlined, "Timeline", 4, isDark),
                _menuItem(context, Icons.hub_outlined, "SNA Propagation", 5, isDark),
                _menuItem(context, Icons.assessment_outlined, "Reports", 6, isDark),
              ],
            ),
          ),

          Divider(color: isDark ? ResearchTheme.darkBorder : ResearchTheme.lightBorder),
          _menuItem(context, Icons.logout_outlined, "Logout", 7, isDark),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _menuItem(BuildContext context, IconData icon, String title, int index, bool isDark) {
    final selected = selectedIndex == index;
    final primaryColor = isDark ? ResearchTheme.darkPrimary : ResearchTheme.lightPrimary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: selected
            ? (isDark ? primaryColor.withValues(alpha: 0.18) : primaryColor.withValues(alpha: 0.1))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        onTap: () {
          if (index == 7) {
            _handleLogout(context);
          } else {
            onItemSelected(index);
          }
        },
        leading: Icon(
          icon,
          color: selected
              ? primaryColor
              : (isDark ? ResearchTheme.darkTextSecondary : ResearchTheme.lightTextSecondary),
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.bold : FontWeight.w500,
            color: selected
                ? primaryColor
                : (isDark ? ResearchTheme.darkTextPrimary : ResearchTheme.lightTextPrimary),
          ),
        ),
      ),
    );
  }
}