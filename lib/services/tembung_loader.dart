import 'dart:convert';
import 'package:flutter/services.dart';
import '../data/tembung_data.dart';

class TembungLoader {
  static const String dictionaryPath = 'assets/sounds/dictionary.json';
  static Future<List<TembungData>>? _future;

  static Future<List<TembungData>> loadDictionary({
    bool forceReload = false,
  }) {
    if (forceReload) {
      _future = null;
    }
    return _future ??= _loadFromAsset();
  }

  static void clearCache() {
    _future = null;
  }

  static Future<List<TembungData>> _loadFromAsset() async {
    try {
      final String rawJson = await rootBundle.loadString(dictionaryPath);
      final dynamic decoded = jsonDecode(rawJson);

      if (decoded is! List) {
        throw const FormatException(
          'dictionary.json harus berupa JSON array.',
        );
      }

      return decoded
          .map((item) {
            if (item is! Map<String, dynamic>) {
              throw const FormatException(
                'Format item dictionary tidak valid.',
              );
            }

            return TembungData.fromJson(item);
          })
          .toList(growable: false);
    } catch (e) {
      throw Exception('Gagal membaca dictionary: $e');
    }
  }

  static Future<TembungData?> findByUid(String uid) async {
    final data = await loadDictionary();

    for (final item in data) {
      if (item.uid == uid) {
        return item;
      }
    }

    return null;
  }

  static String soundPath(String uid) {
    return 'sounds/$uid.wav';
  }
}
