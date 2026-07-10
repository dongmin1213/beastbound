import 'package:soul_dungeon/core/models/curse_modifier_pool.dart';
import 'package:soul_dungeon/domain/combat/content/card_pool.dart';
import 'package:soul_dungeon/domain/combat/content/curse_cards.dart';
import 'package:soul_dungeon/domain/combat/content/starter_cards.dart';
import 'package:soul_dungeon/domain/combat/logic/card_upgrade_registry.dart';
import 'package:soul_dungeon/domain/combat/logic/curse_modifier_resolver.dart';
import 'package:soul_dungeon/core/models/card_data.dart';

/// 시작 덱 생성 — jobId → 12장 (공통 7 + 직업 시작 5) + 저주 카드.
class StartingDeckBuilder {
  StartingDeckBuilder._();

  /// 직업별 시작 덱 생성.
  ///
  /// [purchasedUpgradeIds]에 'soul_starting_deck_upgrade' 포함 시
  /// 타격 카드를 업그레이드 버전으로 교체.
  /// [activeCurseIds]가 있으면 저주 카드 추가.
  static List<CardData> build(
    String jobId, {
    Set<String> purchasedUpgradeIds = const {},
    List<String> activeCurseIds = const [],
  }) {
    final jobStarter = CardPool.jobStarter(jobId);
    var deck = [...StarterCards.all, ...jobStarter];

    // 소울 업그레이드: 시작 덱 업그레이드 (타격 카드 → 타격+)
    if (purchasedUpgradeIds.contains('soul_starting_deck_upgrade')) {
      deck = deck.map((card) {
        if (card.id.startsWith('starter_strike')) {
          return CardUpgradeRegistry.upgrade(card.id) ?? card;
        }
        return card;
      }).toList();
    }

    // 저주 카드 추가
    if (activeCurseIds.isNotEmpty) {
      final curses = CurseModifierPool.resolveIds(activeCurseIds);
      final curseCardCount = CurseModifierResolver.resolveCurseCardCount(curses);
      if (curseCardCount > 0) {
        deck.addAll(CurseCards.forCount(curseCardCount));
      }
    }

    return deck;
  }

  /// 공통 시작 카드만 빌드 (직업 분화 전 사용).
  static List<CardData> buildCommon({
    Set<String> purchasedUpgradeIds = const {},
  }) {
    var deck = [...StarterCards.all];
    if (purchasedUpgradeIds.contains('soul_starting_deck_upgrade')) {
      deck = deck.map((card) {
        if (card.id.startsWith('starter_strike')) {
          return CardUpgradeRegistry.upgrade(card.id) ?? card;
        }
        return card;
      }).toList();
    }
    return deck;
  }

  /// 2차 전직 시 기존 덱에 새 직업 카드 5장 추가.
  ///
  /// 기존 덱은 유지하고 2차 전직 직업의 시작 카드 5장만 추가한다.
  static List<CardData> addSecondClassCards(
    List<CardData> existingDeck,
    String secondJobId,
  ) {
    final secondJobStarter = CardPool.jobStarter(secondJobId);
    return [...existingDeck, ...secondJobStarter];
  }

  /// 시작 덱 크기 (공통 7 + 직업 5 = 12).
  static const int deckSize = 12;

  /// 2차 전직 추가 카드 수.
  static const int secondClassCardCount = 5;
}
