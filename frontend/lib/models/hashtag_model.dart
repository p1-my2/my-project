class HashtagModel {
  final String hashtag;
  final int count;

  HashtagModel({
    required this.hashtag,
    required this.count,
  });

  factory HashtagModel.fromJson(Map<String, dynamic> json) {
    return HashtagModel(
      hashtag: json["hashtag"],
      count: json["_count"]["hashtag"],
    );
  }
}