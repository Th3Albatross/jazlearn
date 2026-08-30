import '../data/tembung_data.dart';
import '../services/tembung_loader.dart';

class TembungRepository {
  TembungRepository._();

  static final TembungRepository instance = TembungRepository._();

  Future<List<TembungData>> getAll() {
    return TembungLoader.loadDictionary();
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
    TembungLoader.clearCache();
  }

  Future<List<TembungData>> reload() {
    return TembungLoader.loadDictionary(forceReload: true);
  }
}
