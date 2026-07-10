import 'package:shared_preferences/shared_preferences.dart';

/// 길들인 몬스터 영속 저장소 (도감).
///
/// 세이브 직렬화와 독립적으로 SharedPreferences에 포획한 몬스터 id를 기록한다.
/// [GameHintManager]와 동일한 캐시-prefs 패턴 — `init(prefs)`를 main에서 호출.
class TamedMonsterStore {
  TamedMonsterStore._();

  static const _key = 'tamed_monster_ids';
  static SharedPreferences? _prefs;

  /// 앱 시작 시 초기화 (main.dart).
  static void init(SharedPreferences prefs) => _prefs = prefs;

  /// 지금까지 길들인 몬스터 id 집합.
  static Set<String> get tamedIds =>
      (_prefs?.getStringList(_key) ?? const <String>[]).toSet();

  /// 특정 몬스터를 길들였는지.
  static bool isTamed(String id) => tamedIds.contains(id);

  /// 몬스터를 길들인 것으로 기록 (신규면 true 반환 — 최초 포획).
  static bool markTamed(String id) {
    final prefs = _prefs;
    if (prefs == null) return false;
    final set = tamedIds;
    if (set.contains(id)) return false;
    set.add(id);
    prefs.setStringList(_key, set.toList());
    return true;
  }

  /// 전체 초기화 (디버그/설정 리셋용).
  static void clear() => _prefs?.remove(_key);
}
