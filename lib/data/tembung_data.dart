class TembungData {
  final String uid;
  final String indonesia;
  final String kramaAlus;
  final String ngoko;

  const TembungData({
    required this.uid,
    required this.indonesia,
    required this.kramaAlus,
    required this.ngoko,
  });

  factory TembungData.fromJson(Map<String, dynamic> json) {
    return TembungData(
      uid: json['uid']?.toString() ?? '',
      indonesia: json['indonesia']?.toString() ?? '',
      kramaAlus: json['kramaalus']?.toString() ?? '',
      ngoko: json['ngoko']?.toString() ?? '',
    );
  }
}

