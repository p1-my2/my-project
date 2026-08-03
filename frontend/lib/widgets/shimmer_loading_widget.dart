import 'package:flutter/material.dart';

class ShimmerDashboardLoading extends StatelessWidget {
  const ShimmerDashboardLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final highlightColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Shimmer
          Container(
            height: 60,
            decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(12)),
          ),
          const SizedBox(height: 20),

          // KPI Cards Shimmer Grid
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: List.generate(
              6,
              (index) => SizedBox(
                width: 220,
                child: Container(
                  height: 90,
                  decoration: BoxDecoration(color: baseColor, borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Main Graph Canvas Shimmer
          Container(
            height: 480,
            decoration: BoxDecoration(color: highlightColor, borderRadius: BorderRadius.circular(12)),
          ),
        ],
      ),
    );
  }
}
