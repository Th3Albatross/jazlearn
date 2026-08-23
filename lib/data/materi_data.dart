class MateriData {
  final String uid;
  final String title;
  final String description;
  final String videoAsset;
  final String summaryAsset;

  const MateriData({
    required this.uid,
    required this.title,
    required this.description,
    required this.videoAsset,
    required this.summaryAsset,
  });

  factory MateriData.fromJson(Map<String, dynamic> json) {
    return MateriData(
      uid: json['uid'],
      title: json['title'],
      description: json['description'],
      videoAsset: json['video'],
      summaryAsset: json['summary'],
    );
  }
}

