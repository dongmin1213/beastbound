import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 저주 카드 — 덱에 추가되는 방해 카드.
///
/// Exhaust 불가 → 덱에서 영구적으로 순환.
/// 카드 제거(상점)로만 제거 가능.
class CurseCards {
  CurseCards._();

  /// 나약함 — 아무 효과 없는 손패 낭비 카드.
  static const weakness = CardData(
    id: 'curse_weakness',
    name: '나약함',
    type: CardType.skill,
    apCost: 0,
    description: '아무 효과가 없다. 이 카드는 소진되지 않는다.',
    effects: [CardEffect(type: CardEffectType.nothing, value: 0)],
  );

  /// 쇠퇴 — 사용 시 HP -1.
  static const decay = CardData(
    id: 'curse_decay',
    name: '쇠퇴',
    type: CardType.skill,
    apCost: 0,
    description: '사용 시 HP -1. 이 카드는 소진되지 않는다.',
    effects: [CardEffect(type: CardEffectType.selfDamage, value: 1)],
  );

  /// 저주 카드 목록.
  static const List<CardData> all = [weakness, decay];

  /// 레벨별 저주 카드 배분.
  /// 레벨 1~2: 나약함만, 레벨 3+: 나약함 + 쇠퇴 혼합.
  static List<CardData> forCount(int count) {
    if (count <= 0) return const [];
    final cards = <CardData>[];
    for (int i = 0; i < count; i++) {
      cards.add(i.isEven ? weakness : decay);
    }
    return cards;
  }
}
