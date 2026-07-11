import 'package:collection/collection.dart';
import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/core/models/boss_choice.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 런 전체 플레이어 상태. 불변 클래스.
/// core/models/ 배치 — HP/금화는 런 전체 자원이므로 combat/shop 전용이 아님.
class PlayerRunState {
  final int currentHp;
  final int maxHp;
  final int gold;
  final String? currentJobId;
  final List<String> ownedBlessingIds;
  final List<String> ownedRelicIds;
  final List<String> activeCurseIds;
  final int currentFloor;
  final List<BossChoice> bossChoices;
  final Set<int> completedFloors;
  final List<CardData> masterDeck;
  final Set<String> removedCardIds;

  /// NPC 보급품 "다음 전투" 일회성 보너스 (전투 시작 시 소비됨).
  final int tempStrengthBonus;
  final int tempBlockBonus;
  final int tempMomentumBonus;

  // 던전 맵 복원용 (이어하기)
  final int? dungeonSeed;
  final String? dungeonNodeId;
  final Set<String> dungeonVisitedNodeIds;

  // 현재 방 타입 복원용 (이어하기 — 비전투 방 재진입)
  final RoomType? currentRoomType;

  // 기세 복원용 (이어하기)
  final int? momentumValue;
  final int momentumConsecutiveCount;

  // 보스 처치 후 보상 선택 대기 중 (이어하기 — 보스 보상 화면 복원용)
  final bool bossVictoryPending;

  static const _listEquality = ListEquality<String>();
  static const _bossChoiceEquality = ListEquality<BossChoice>();
  static const _setEquality = SetEquality<int>();
  static const _cardListEquality = ListEquality<CardData>();
  static const _stringSetEquality = SetEquality<String>();
  static const _sentinel = Object();

  const PlayerRunState({
    required this.currentHp,
    required this.maxHp,
    this.gold = 0,
    this.currentJobId,
    this.ownedBlessingIds = const [],
    this.ownedRelicIds = const [],
    this.activeCurseIds = const [],
    this.currentFloor = 1,
    this.bossChoices = const [],
    this.completedFloors = const {},
    this.masterDeck = const [],
    this.removedCardIds = const {},
    this.tempStrengthBonus = 0,
    this.tempBlockBonus = 0,
    this.tempMomentumBonus = 0,
    this.dungeonSeed,
    this.dungeonNodeId,
    this.dungeonVisitedNodeIds = const {},
    this.currentRoomType,
    this.momentumValue,
    this.momentumConsecutiveCount = 0,
    this.bossVictoryPending = false,
  })  : assert(maxHp > 0, 'maxHp must be positive'),
        assert(currentHp >= 0, 'currentHp cannot be negative'),
        assert(currentHp <= maxHp, 'currentHp cannot exceed maxHp'),
        assert(gold >= 0, 'gold cannot be negative'),
        assert(currentFloor >= 1, 'currentFloor must be >= 1');

  factory PlayerRunState.initial({
    required int maxHp,
    List<CardData> masterDeck = const [],
  }) {
    return PlayerRunState(
      currentHp: maxHp,
      maxHp: maxHp,
      gold: 0,
      currentJobId: null,
      ownedBlessingIds: const [],
      ownedRelicIds: const [],
      activeCurseIds: const [],
      currentFloor: 1,
      bossChoices: const [],
      completedFloors: const {},
      masterDeck: masterDeck,
      removedCardIds: const {},
      tempStrengthBonus: 0,
      tempBlockBonus: 0,
      tempMomentumBonus: 0,
      dungeonSeed: null,
      dungeonNodeId: null,
      dungeonVisitedNodeIds: const {},
      currentRoomType: null,
      momentumValue: null,
      momentumConsecutiveCount: 0,
      bossVictoryPending: false,
    );
  }

  bool get isAlive => currentHp > 0;

  double get hpPercent => maxHp > 0 ? currentHp / maxHp : 0.0;

  /// 실제 전투에 사용할 덱 (removedCardIds 제외).
  List<CardData> get effectiveDeck =>
      masterDeck.where((c) => !removedCardIds.contains(c.id)).toList();

  PlayerRunState copyWith({
    int? currentHp,
    int? maxHp,
    int? gold,
    Object? currentJobId = _sentinel,
    List<String>? ownedBlessingIds,
    List<String>? ownedRelicIds,
    List<String>? activeCurseIds,
    int? currentFloor,
    List<BossChoice>? bossChoices,
    Set<int>? completedFloors,
    List<CardData>? masterDeck,
    Set<String>? removedCardIds,
    int? tempStrengthBonus,
    int? tempBlockBonus,
    int? tempMomentumBonus,
    Object? dungeonSeed = _sentinel,
    Object? dungeonNodeId = _sentinel,
    Set<String>? dungeonVisitedNodeIds,
    Object? currentRoomType = _sentinel,
    Object? momentumValue = _sentinel,
    int? momentumConsecutiveCount,
    bool? bossVictoryPending,
  }) {
    return PlayerRunState(
      currentHp: currentHp ?? this.currentHp,
      maxHp: maxHp ?? this.maxHp,
      gold: gold ?? this.gold,
      currentJobId: currentJobId == _sentinel
          ? this.currentJobId
          : currentJobId as String?,
      ownedBlessingIds: ownedBlessingIds ?? this.ownedBlessingIds,
      ownedRelicIds: ownedRelicIds ?? this.ownedRelicIds,
      activeCurseIds: activeCurseIds ?? this.activeCurseIds,
      currentFloor: currentFloor ?? this.currentFloor,
      bossChoices: bossChoices ?? this.bossChoices,
      completedFloors: completedFloors ?? this.completedFloors,
      masterDeck: masterDeck ?? this.masterDeck,
      removedCardIds: removedCardIds ?? this.removedCardIds,
      tempStrengthBonus: tempStrengthBonus ?? this.tempStrengthBonus,
      tempBlockBonus: tempBlockBonus ?? this.tempBlockBonus,
      tempMomentumBonus: tempMomentumBonus ?? this.tempMomentumBonus,
      dungeonSeed: dungeonSeed == _sentinel
          ? this.dungeonSeed
          : dungeonSeed as int?,
      dungeonNodeId: dungeonNodeId == _sentinel
          ? this.dungeonNodeId
          : dungeonNodeId as String?,
      dungeonVisitedNodeIds:
          dungeonVisitedNodeIds ?? this.dungeonVisitedNodeIds,
      currentRoomType: currentRoomType == _sentinel
          ? this.currentRoomType
          : currentRoomType as RoomType?,
      momentumValue: momentumValue == _sentinel
          ? this.momentumValue
          : momentumValue as int?,
      momentumConsecutiveCount:
          momentumConsecutiveCount ?? this.momentumConsecutiveCount,
      bossVictoryPending: bossVictoryPending ?? this.bossVictoryPending,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerRunState &&
          currentHp == other.currentHp &&
          maxHp == other.maxHp &&
          gold == other.gold &&
          currentJobId == other.currentJobId &&
          currentFloor == other.currentFloor &&
          dungeonSeed == other.dungeonSeed &&
          dungeonNodeId == other.dungeonNodeId &&
          _listEquality.equals(ownedBlessingIds, other.ownedBlessingIds) &&
          _listEquality.equals(ownedRelicIds, other.ownedRelicIds) &&
          _listEquality.equals(activeCurseIds, other.activeCurseIds) &&
          _bossChoiceEquality.equals(bossChoices, other.bossChoices) &&
          _setEquality.equals(completedFloors, other.completedFloors) &&
          _cardListEquality.equals(masterDeck, other.masterDeck) &&
          _stringSetEquality.equals(removedCardIds, other.removedCardIds) &&
          tempStrengthBonus == other.tempStrengthBonus &&
          tempBlockBonus == other.tempBlockBonus &&
          tempMomentumBonus == other.tempMomentumBonus &&
          _stringSetEquality.equals(
              dungeonVisitedNodeIds, other.dungeonVisitedNodeIds) &&
          currentRoomType == other.currentRoomType &&
          momentumValue == other.momentumValue &&
          momentumConsecutiveCount == other.momentumConsecutiveCount &&
          bossVictoryPending == other.bossVictoryPending;

  @override
  int get hashCode => Object.hash(
        currentHp,
        maxHp,
        gold,
        currentJobId,
        currentFloor,
        dungeonSeed,
        dungeonNodeId,
        _listEquality.hash(ownedBlessingIds),
        _listEquality.hash(ownedRelicIds),
        _listEquality.hash(activeCurseIds),
        _bossChoiceEquality.hash(bossChoices),
        _setEquality.hash(completedFloors),
        _cardListEquality.hash(masterDeck),
        _stringSetEquality.hash(removedCardIds),
        Object.hash(tempStrengthBonus, tempBlockBonus, tempMomentumBonus),
        _stringSetEquality.hash(dungeonVisitedNodeIds),
        currentRoomType,
        momentumValue,
        Object.hash(momentumConsecutiveCount, bossVictoryPending),
      );

  @override
  String toString() =>
      'PlayerRunState($currentHp/$maxHp, gold: $gold, floor: $currentFloor, '
      'job: $currentJobId, blessings: ${ownedBlessingIds.length}, '
      'relics: ${ownedRelicIds.length}, curses: ${activeCurseIds.length}, '
      'bossChoices: ${bossChoices.length}, '
      'deck: ${masterDeck.length}, removed: ${removedCardIds.length}, '
      'tempStr: $tempStrengthBonus, tempBlk: $tempBlockBonus, tempMom: $tempMomentumBonus, '
      'dungeonSeed: $dungeonSeed, dungeonNode: $dungeonNodeId, '
      'dungeonVisited: ${dungeonVisitedNodeIds.length}, '
      'currentRoomType: $currentRoomType, '
      'momentum: $momentumValue, consecutiveCount: $momentumConsecutiveCount, '
      'bossVictoryPending: $bossVictoryPending)';
}
