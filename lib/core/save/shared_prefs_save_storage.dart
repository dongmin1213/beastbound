import 'package:shared_preferences/shared_preferences.dart';
import 'package:soul_dungeon/core/save/save_storage.dart';

/// SharedPreferences 기반 저장소 — 프로덕션용.
class SharedPrefsSaveStorage implements SaveStorage {
  final SharedPreferences _prefs;

  SharedPrefsSaveStorage(this._prefs);

  @override
  Future<String?> read(String key) async => _prefs.getString(key);

  @override
  Future<void> write(String key, String value) async {
    await _prefs.setString(key, value);
  }

  @override
  Future<void> delete(String key) async {
    await _prefs.remove(key);
  }
}
