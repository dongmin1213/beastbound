import 'package:shared_preferences/shared_preferences.dart';

/// 일회성 게임 힌트 관리 — SharedPreferences로 표시 여부 추적.
///
/// 각 힌트는 고유 키를 가지며, 한 번 표시되면 다시 표시되지 않는다.
class GameHintManager {
  GameHintManager._();

  // ── 힌트 키 ──
  static const hintGoal = 'hint_goal_shown';
  static const hintDisposition = 'hint_disposition_shown';
  static const hintMomentum = 'hint_momentum_shown';
  static const hintSoul = 'hint_soul_shown';
  static const hintElite = 'hint_elite_shown';

  // ── 힌트 텍스트 ──
  static const goalText =
      '💡 던전 깊은 곳에 잠든 5층의 보스를 쓰러뜨리는 것이 목표다.';

  static const dispositionText =
      '💡 성향은 보스 선택에 따라 변하며, 직업 분화와 엔딩에 영향을 준다.';

  static const momentumText =
      '💡 기세는 다양한 행동을 할수록 올라간다. 높을수록 턴당 AP가 증가한다.';

  static const soulText =
      '💡 소울은 소울 상점에서 영구 강화에 사용된다. 깊은 층까지 갈수록 더 많이 획득한다.';

  static const eliteText =
      '💡 정예는 일반 전투보다 훨씬 강하지만, 좋은 보상을 준다.';

  /// 힌트가 아직 표시되지 않았으면 true 반환 후 표시 완료로 마킹.
  static Future<bool> shouldShow(String key) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(key) ?? false) return false;
    await prefs.setBool(key, true);
    return true;
  }

  /// 동기 체크용 — prefs 인스턴스를 직접 전달.
  static bool shouldShowSync(SharedPreferences prefs, String key) {
    if (prefs.getBool(key) ?? false) return false;
    prefs.setBool(key, true);
    return true;
  }

  // ── 캐시 기반 동기 체크 ──
  static SharedPreferences? _cachedPrefs;

  /// 앱 시작 시 초기화 (main.dart에서 호출).
  static void init(SharedPreferences prefs) {
    _cachedPrefs = prefs;
  }

  /// 캐시된 prefs로 동기 체크 — init 후에만 사용.
  static bool checkAndMark(String key) {
    final prefs = _cachedPrefs;
    if (prefs == null) return false;
    if (prefs.getBool(key) ?? false) return false;
    prefs.setBool(key, true);
    return true;
  }
}
