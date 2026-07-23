class TimelineModel {
  final String date;
  final int posts;

  TimelineModel({
    required this.date,
    required this.posts,
  });

  factory TimelineModel.fromJson(Map<String, dynamic> json) {
    return TimelineModel(
      date: json["date"],
      posts: json["posts"],
    );
  }
}