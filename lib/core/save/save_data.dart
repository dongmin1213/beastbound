import 'package:soul_dungeon/core/models/player_run_state.dart';

/// 런 세이브 데이터 — 런 한정 (HP, 기세, 인벤, 층, 보스 선택).
class RunSaveData {
  final PlayerRunState playerRunState;
  final int schemaVersion;
  final DateTime savedAt;

  /// 전투 중 저장된 카드 전투 상태 (raw JSON).
  /// null = 전투 중이 아님. domain 레이어에서 직렬화/역직렬화.
  final Map<String, dynamic>? cardCombatStateRaw;

  const RunSaveData({
    required this.playerRunState,
    this.schemaVersion = 1,
    required this.savedAt,
    this.cardCombatStateRaw,
  });
}

/// 메타 세이브 데이터 — 영구 (소울, 런 기록, 엔딩 달성, 소울 업그레이드).
class MetaSaveData {
  final int totalRuns;
  final int deathCount;
  final Set<String> endingsReached;
  final int soulCount;
  final int schemaVersion;

  /// 구매한 소울 업그레이드 ID (maxLevel 도달한 것).
  final Set<String> purchasedUpgradeIds;

  /// 업그레이드별 현재 레벨 (0 = 미구매, maxLevel > 1인 경우 추적).
  final Map<String, int> upgradeLevels;

  /// 소울 업그레이드로 해금된 카드 ID.
  final Set<String> unlockedCardIds;

  /// 유령 NPC 풀 (사망 기록) — raw JSON 형태.
  /// core는 domain(GhostNpcData)에 의존할 수 없으므로 Map으로 저장.
  final List<Map<String, dynamic>> ghostNpcPoolRaw;

  /// 해금된 기억 조각 ID 목록.
  final Set<String> unlockedMemoryIds;

  /// 클리어 횟수 — 저주 레벨 결정에 사용.
  final int clearCount;

  /// 해금된 히든 직업 ID 목록.
  final Set<String> unlockedHiddenJobIds;

  /// 직업별 클리어 횟수 (key: jobId, value: 클리어 수).
  final Map<String, int> winsByJob;

  const MetaSaveData({
    this.totalRuns = 0,
    this.deathCount = 0,
    this.endingsReached = const {},
    this.soulCount = 0,
    this.schemaVersion = 1,
    this.purchasedUpgradeIds = const {},
    this.upgradeLevels = const {},
    this.unlockedCardIds = const {},
    this.ghostNpcPoolRaw = const [],
    this.unlockedMemoryIds = const {},
    this.clearCount = 0,
    this.unlockedHiddenJobIds = const {},
    this.winsByJob = const {},
  });

  MetaSaveData copyWith({
    int? totalRuns,
    int? deathCount,
    Set<String>? endingsReached,
    int? soulCount,
    Set<String>? purchasedUpgradeIds,
    Map<String, int>? upgradeLevels,
    Set<String>? unlockedCardIds,
    List<Map<String, dynamic>>? ghostNpcPoolRaw,
    Set<String>? unlockedMemoryIds,
    int? clearCount,
    Set<String>? unlockedHiddenJobIds,
    Map<String, int>? winsByJob,
  }) {
    return MetaSaveData(
      totalRuns: totalRuns ?? this.totalRuns,
      deathCount: deathCount ?? this.deathCount,
      endingsReached: endingsReached ?? this.endingsReached,
      soulCount: soulCount ?? this.soulCount,
      purchasedUpgradeIds: purchasedUpgradeIds ?? this.purchasedUpgradeIds,
      upgradeLevels: upgradeLevels ?? this.upgradeLevels,
      unlockedCardIds: unlockedCardIds ?? this.unlockedCardIds,
      ghostNpcPoolRaw: ghostNpcPoolRaw ?? this.ghostNpcPoolRaw,
      unlockedMemoryIds: unlockedMemoryIds ?? this.unlockedMemoryIds,
      clearCount: clearCount ?? this.clearCount,
      unlockedHiddenJobIds: unlockedHiddenJobIds ?? this.unlockedHiddenJobIds,
      winsByJob: winsByJob ?? this.winsByJob,
    );
  }
}
