import '../data/tembung_data.dart';
import '../services/tembung_loader.dart';

class TembungRepository {
  TembungRepository._();

  static final TembungRepository instance =
      TembungRepository._();

  List<TembungData>? _cache;

  Future<List<TembungData>> getAll() async {
    if (_cache != null) {
      return _cache!;
    }

    _cache = await TembungLoader.loadDictionary();

    return _cache!;
  }

  Future<TembungData?> getByUid(String uid) async {
    final data = await getAll();

    for (final item in data) {
      if (item.uid == uid) {
        return item;
      }
    }

    return null;
  }

  void clearCache() {
    _cache = null;
  }
}

