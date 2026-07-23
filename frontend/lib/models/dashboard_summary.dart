class DashboardSummary {
  final int totalUsers;
  final int totalDatasets;
  final int totalPosts;
  final int totalHashtags;
  final int totalReports;
  final int misinformationPosts;

  DashboardSummary({
    required this.totalUsers,
    required this.totalDatasets,
    required this.totalPosts,
    required this.totalHashtags,
    required this.totalReports,
    required this.misinformationPosts,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalUsers: json["totalUsers"],
      totalDatasets: json["totalDatasets"],
      totalPosts: json["totalPosts"],
      totalHashtags: json["totalHashtags"],
      totalReports: json["totalReports"],
      misinformationPosts: json["misinformationPosts"],
    );
  }
}