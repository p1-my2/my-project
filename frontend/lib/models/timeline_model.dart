class TimelineModel {
  final String date;
  final int posts;
  final int misinformationPosts;

  TimelineModel({
    required this.date,
    required this.posts,
    required this.misinformationPosts,
  });

  factory TimelineModel.fromJson(Map<String, dynamic> json) {
    return TimelineModel(
      date: json["date"] ?? "",
      posts: json["posts"] ?? 0,
      misinformationPosts: json["misinformationPosts"] ?? 0,
    );
  }
}