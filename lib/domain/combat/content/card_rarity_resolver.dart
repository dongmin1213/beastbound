import 'package:soul_dungeon/domain/combat/content/card_pool.dart';
import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 카드 희귀도 판정 — CardData에 rarity 필드가 없으므로 규칙 기반 추론.
///
/// - 공통 시작 카드, 직업 시작 카드 → common
/// - 직업 보상 카드 → rare
/// - 무색 카드: apCost ≥ 2 또는 power 타입 → rare, 나머지 → common
class CardRarityResolver {
  CardRarityResolver._();

  static final Set<String> _starterIds = {
    for (final c in CardPool.starter) c.id,
  };

  /// 카드 희귀도 판정.
  static Rarity resolve(CardData card) {
    // 공통 시작 카드
    if (_starterIds.contains(card.id)) return Rarity.common;

    // 무색 카드 (jobId == null, 시작 카드 제외)
    if (card.jobId == null) {
      if (card.apCost >= 2 || card.type == CardType.power) {
        return Rarity.rare;
      }
      return Rarity.common;
    }

    // 직업 카드: 시작 카드 여부 확인
    final jobStarter = CardPool.jobStarter(card.jobId!);
    if (jobStarter.any((c) => c.id == card.id)) return Rarity.common;

    // 직업 보상 카드
    return Rarity.rare;
  }

  /// 희귀도 라벨 텍스트.
  static String label(Rarity rarity) {
    return switch (rarity) {
      Rarity.common => '일반',
      Rarity.rare => '희귀',
      Rarity.legendary => '전설',
      Rarity.cursed => '저주',
    };
  }
}
