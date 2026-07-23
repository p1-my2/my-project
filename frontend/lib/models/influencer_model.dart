class InfluencerModel {
  final String sourceUser;
  final int interactions;

  InfluencerModel({
    required this.sourceUser,
    required this.interactions,
  });

  factory InfluencerModel.fromJson(Map<String, dynamic> json) {
    return InfluencerModel(
      sourceUser: json["sourceUser"] ?? "Unknown",
      interactions: json["_count"]["sourceUser"] ?? 0,
    );
  }
}