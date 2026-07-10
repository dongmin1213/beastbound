import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/combat/content/card_pool.dart';
import 'package:soul_dungeon/domain/combat/content/starter_cards.dart';
import 'package:soul_dungeon/domain/combat/content/warrior_cards.dart';
import 'package:soul_dungeon/domain/combat/logic/card_upgrade_registry.dart';

void main() {
  group('CardUpgradeRegistry', () {
    test('전체 241종 모두 업그레이드 등록', () {
      expect(CardUpgradeRegistry.count, 241);
    });

    test('모든 base 카드가 업그레이드 가능', () {
      for (final card in CardPool.allCards) {
        expect(
          CardUpgradeRegistry.canUpgrade(card.id),
          isTrue,
          reason: '${card.name}(${card.id})은 업그레이드 가능해야 함',
        );
      }
    });

    test('업그레이드 결과는 upgraded=true', () {
      for (final card in CardPool.allCards) {
        final upgraded = CardUpgradeRegistry.upgrade(card.id);
        expect(
          upgraded!.upgraded,
          isTrue,
          reason: '${card.name} 업그레이드는 upgraded=true여야 함',
        );
      }
    });

    test('starter 타격 → 타격+ (8d)', () {
      final upgraded = CardUpgradeRegistry.upgrade(StarterCards.strike1.id);
      expect(upgraded!.name, '타격+');
      expect(upgraded.damage, 8);
    });

    test('warrior 강타 → 강타+ (24d)', () {
      final upgraded = CardUpgradeRegistry.upgrade(WarriorCards.heavyStrike.id);
      expect(upgraded!.name, '강타+');
      expect(upgraded.damage, 24);
    });

    test('존재하지 않는 ID → null', () {
      expect(CardUpgradeRegistry.upgrade('nonexistent'), isNull);
      expect(CardUpgradeRegistry.canUpgrade('nonexistent'), isFalse);
    });
  });
}
