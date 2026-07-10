import 'dart:math';
import 'package:soul_dungeon/domain/combat/content/card_pool.dart';
import 'package:soul_dungeon/domain/combat/content/monster_cards.dart';
import 'package:soul_dungeon/core/models/card_data.dart';

/// 카드 보상 생성 — 승리 후 3장 선택지 제공.
///
/// 기본 구성: 직업 카드 2장 + 무색 카드 1장.
/// 풀이 부족하면 나머지 풀에서 보충.
class CardRewardGenerator {
  CardRewardGenerator._();

  /// 보상 카드 [count]장 생성 (기본 3).
  ///
  /// 직업 보상 2장 + 무색 1장 구성을 우선.
  /// [ownedCardIds]에 포함된 카드는 제외 (이미 보유).
  /// [unlockedCardIds]에 포함된 카드는 소울 업그레이드로 해금된 카드로 풀에 추가.
  static List<CardData> generate({
    required String jobId,
    required int count,
    Set<String> ownedCardIds = const {},
    Set<String> unlockedCardIds = const {},
    Random? random,
  }) {
    final rng = random ?? Random();

    // 직업 보상 풀
    final jobPool = <CardData>[...CardPool.jobRewards(jobId)];
    // 무색 풀
    final colorlessPool = <CardData>[...CardPool.colorless];

    // 소울 업그레이드로 해금된 카드 추가
    for (final cardId in unlockedCardIds) {
      final card = CardPool.findById(cardId);
      if (card != null) {
        if (card.jobId != null && !jobPool.any((c) => c.id == cardId)) {
          jobPool.add(card);
        } else if (card.jobId == null &&
            !colorlessPool.any((c) => c.id == cardId)) {
          colorlessPool.add(card);
        }
      }
    }

    // 이미 보유한 카드 제외
    final availableJob =
        jobPool.where((c) => !ownedCardIds.contains(c.id)).toList();
    final availableColorless =
        colorlessPool.where((c) => !ownedCardIds.contains(c.id)).toList();

    availableJob.shuffle(rng);
    availableColorless.shuffle(rng);

    final result = <CardData>[];
    final usedIds = <String>{};

    // 직업 카드 2장 우선 선택
    final jobCount = count > 1 ? 2 : count;
    for (final card in availableJob) {
      if (result.length >= jobCount) break;
      if (!usedIds.contains(card.id)) {
        result.add(card);
        usedIds.add(card.id);
      }
    }

    // 무색 카드 1장 선택
    if (result.length < count) {
      for (final card in availableColorless) {
        if (result.length >= count) break;
        if (!usedIds.contains(card.id)) {
          result.add(card);
          usedIds.add(card.id);
        }
      }
    }

    // 부족분 보충 (직업 풀에서)
    if (result.length < count) {
      for (final card in availableJob) {
        if (result.length >= count) break;
        if (!usedIds.contains(card.id)) {
          result.add(card);
          usedIds.add(card.id);
        }
      }
    }

    // 그래도 부족하면 무색에서 추가 보충
    if (result.length < count) {
      for (final card in availableColorless) {
        if (result.length >= count) break;
        if (!usedIds.contains(card.id)) {
          result.add(card);
          usedIds.add(card.id);
        }
      }
    }

    return result;
  }

  /// 로스터 몬스터들의 무브풀에서 보상 카드 [count]장 생성.
  ///
  /// 몬스터 테이밍 컨셉: 이번 런에 데려온 몬스터(스타터+길들인)들의 카드에서
  /// 보상이 나온다. 몬스터 카드 우선, 부족분은 무색으로 보충.
  /// [ownedCardIds]에 포함된 카드는 제외 (이미 보유).
  static List<CardData> generateFromMonsters({
    required List<String> monsterIds,
    required int count,
    Set<String> ownedCardIds = const {},
    Random? random,
  }) {
    final rng = random ?? Random();

    // 로스터 몬스터 무브풀 union (중복 제거).
    final monsterPool = <CardData>[];
    final seen = <String>{};
    for (final id in monsterIds) {
      for (final card in MonsterCards.movepool(id)) {
        if (seen.add(card.id)) monsterPool.add(card);
      }
    }

    final availableMonster =
        monsterPool.where((c) => !ownedCardIds.contains(c.id)).toList()
          ..shuffle(rng);
    final availableColorless = <CardData>[
      ...CardPool.colorless.where((c) => !ownedCardIds.contains(c.id)),
    ]..shuffle(rng);

    final result = <CardData>[];
    final usedIds = <String>{};

    // 몬스터 카드 우선.
    for (final card in availableMonster) {
      if (result.length >= count) break;
      if (usedIds.add(card.id)) result.add(card);
    }
    // 부족분은 무색으로 보충.
    for (final card in availableColorless) {
      if (result.length >= count) break;
      if (usedIds.add(card.id)) result.add(card);
    }

    return result;
  }
}
