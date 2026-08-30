import 'dart:convert';
import 'package:flutter/services.dart';
import '../data/materi_data.dart';

class MateriLoader {
  MateriLoader._();

  static Future<List<MateriData>>? _future;

  static Future<List<MateriData>> load({bool forceReload = false}) {
    if (forceReload) {
      _future = null;
    }

    return _future ??= _loadFromAsset();
  }

  static Future<List<MateriData>> _loadFromAsset() async {
    final raw = await rootBundle.loadString(
      'assets/materi/dictionary.json',
    );

    final List<dynamic> decoded = jsonDecode(raw);

    return decoded
        .map((item) => MateriData.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }
}
