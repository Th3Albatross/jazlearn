import 'dart:convert';
import 'package:flutter/services.dart';
import '../data/tembung_data.dart';

class TembungLoader {
  static const String dictionaryPath =
      'assets/sounds/dictionary.json';

  static Future<List<TembungData>> loadDictionary() async {
    try {
      final String rawJson = await rootBundle.loadString(
        dictionaryPath,
      );

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
          .toList();
    } catch (e) {
      throw Exception(
        'Gagal membaca dictionary: $e',
      );
    }
  }

  static Future<TembungData?> findByUid(String uid) async {
    final data = await loadDictionary();

    try {
      return data.firstWhere(
        (item) => item.uid == uid,
      );
    } catch (_) {
      return null;
    }
  }

  static String soundPath(String uid) {
    return 'sounds/$uid.wav';
  }
}

