class TimelinePost {
  final String author;
  final String content;
  final String createdAt;
  final bool isMisinformation;

  TimelinePost({
    required this.author,
    required this.content,
    required this.createdAt,
    required this.isMisinformation,
  });

  factory TimelinePost.fromJson(Map<String, dynamic> json) {
    return TimelinePost(
      author: json["author"],
      content: json["content"],
      createdAt: json["createdAt"],
      isMisinformation: json["isMisinformation"],
    );
  }
}