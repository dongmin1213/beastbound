import 'package:flutter/foundation.dart' show listEquals;

import 'package:soul_dungeon/domain/dungeon/shop/shop_item.dart';

/// NPC 유형 — 방랑 상인(대화+거래), 현자(대화+골드보상), 방랑자(대화+골드보상).
enum NpcType { trader, sage, wanderer }

/// NPC 불변 모델 — Equatable 미사용, 수동 ==/hashCode (ShopItem 패턴).
class NpcData {
  final String id;
  final NpcType npcType;
  final String name;
  final String greetingText;
  final String dialogueText;
  final List<ShopItem> tradeItems;
  final int goldReward;

  /// 대화 보상 카드 강화 — 드문 확률로 true.
  final bool upgradeRandomCard;

  const NpcData({
    required this.id,
    required this.npcType,
    required this.name,
    required this.greetingText,
    required this.dialogueText,
    required this.tradeItems,
    required this.goldReward,
    this.upgradeRandomCard = false,
  });

  bool get hasTradeItems => tradeItems.isNotEmpty;

  /// 대화 보상이 하나라도 있는지 (골드/카드강화).
  bool get hasDialogueReward =>
      goldReward > 0 ||
      upgradeRandomCard;

  NpcData copyWith({List<ShopItem>? tradeItems}) {
    return NpcData(
      id: id,
      npcType: npcType,
      name: name,
      greetingText: greetingText,
      dialogueText: dialogueText,
      tradeItems: tradeItems ?? this.tradeItems,
      goldReward: goldReward,
      upgradeRandomCard: upgradeRandomCard,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NpcData &&
          id == other.id &&
          npcType == other.npcType &&
          name == other.name &&
          greetingText == other.greetingText &&
          dialogueText == other.dialogueText &&
          listEquals(tradeItems, other.tradeItems) &&
          goldReward == other.goldReward &&
          upgradeRandomCard == other.upgradeRandomCard;

  @override
  int get hashCode =>
      Object.hash(id, npcType, name, greetingText, dialogueText,
          Object.hashAll(tradeItems), goldReward,
          upgradeRandomCard);

  @override
  String toString() =>
      'NpcData($id, $npcType, $name, items: ${tradeItems.length}, reward: $goldReward, '
      'upgrade: $upgradeRandomCard)';
}
