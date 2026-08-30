class VideoProgressService {
  VideoProgressService._();

  static final VideoProgressService instance = VideoProgressService._();

  final Map<String, Duration> _positions = <String, Duration>{};

  Duration getPosition(String videoId) {
    return _positions[videoId] ?? Duration.zero;
  }

  void savePosition(String videoId, Duration position) {
    _positions[videoId] = position;
  }

  void clearPosition(String videoId) {
    _positions.remove(videoId);
  }
}
