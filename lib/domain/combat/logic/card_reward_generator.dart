import 'dart:math';
import 'package:soul_dungeon/domain/combat/content/card_pool.dart';
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
}
