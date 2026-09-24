import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Persists a list of JSON objects under one [SharedPreferences] key.
///
/// This is the on-device storage every local datasource uses so the clinic
/// keeps working with no internet. Records are small (a clinic has hundreds
/// to low thousands of patients), so a single JSON string per collection is
/// simple and fast enough. A future Supabase datasource replaces the
/// datasource, not this class.
class JsonListStore {
  final SharedPreferences _prefs;
  final String key;

  const JsonListStore(this._prefs, this.key);

  List<Map<String, dynamic>> readAll() {
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.cast<Map<String, dynamic>>();
  }

  Future<void> writeAll(List<Map<String, dynamic>> items) async {
    await _prefs.setString(key, jsonEncode(items));
  }

  /// Inserts or replaces the item whose `id` matches [item]'s `id`.
  Future<void> upsert(Map<String, dynamic> item) async {
    final items = readAll();
    final index = items.indexWhere((e) => e['id'] == item['id']);
    if (index == -1) {
      items.add(item);
    } else {
      items[index] = item;
    }
    await writeAll(items);
  }

  Future<void> removeWhere(
    bool Function(Map<String, dynamic> item) test,
  ) async {
    final items = readAll()..removeWhere(test);
    await writeAll(items);
  }
}
