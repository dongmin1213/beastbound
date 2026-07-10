import 'package:soul_dungeon/domain/combat/content/arbiter_cards.dart';
import 'package:soul_dungeon/domain/combat/content/archmage_cards.dart';
import 'package:soul_dungeon/domain/combat/content/assassin_cards.dart';
import 'package:soul_dungeon/domain/combat/content/colorless_cards.dart';
import 'package:soul_dungeon/domain/combat/content/dark_knight_cards.dart';
import 'package:soul_dungeon/domain/combat/content/dark_mage_cards.dart';
import 'package:soul_dungeon/domain/combat/content/dimension_mage_cards.dart';
import 'package:soul_dungeon/domain/combat/content/fate_traveler_cards.dart';
import 'package:soul_dungeon/domain/combat/content/guardian_cards.dart';
import 'package:soul_dungeon/domain/combat/content/harmonist_cards.dart';
import 'package:soul_dungeon/domain/combat/content/high_priest_cards.dart';
import 'package:soul_dungeon/domain/combat/content/holy_knight_cards.dart';
import 'package:soul_dungeon/domain/combat/content/illusionist_cards.dart';
import 'package:soul_dungeon/domain/combat/content/iron_fortress_cards.dart';
import 'package:soul_dungeon/domain/combat/content/nether_king_cards.dart';
import 'package:soul_dungeon/domain/combat/content/one_with_all_cards.dart';
import 'package:soul_dungeon/domain/combat/content/reaper_cards.dart';
import 'package:soul_dungeon/domain/combat/content/sage_cards.dart';
import 'package:soul_dungeon/domain/combat/content/saint_cards.dart';
import 'package:soul_dungeon/domain/combat/content/shadow_lord_cards.dart';
import 'package:soul_dungeon/domain/combat/content/spell_blade_cards.dart';
import 'package:soul_dungeon/domain/combat/content/starter_cards.dart';
import 'package:soul_dungeon/domain/combat/content/sword_saint_cards.dart';
import 'package:soul_dungeon/domain/combat/content/wanderer_cards.dart';
import 'package:soul_dungeon/domain/combat/content/warrior_cards.dart';
import 'package:soul_dungeon/domain/combat/logic/card_upgrade_registry.dart';
import 'package:soul_dungeon/core/models/card_data.dart';

/// 전체 카드 풀 — 231종 중앙 레지스트리.
/// (기존 161 + 상위직 45 + 조합직 25 = 231)
class CardPool {
  CardPool._();

  /// 공통 시작 카드 7장.
  static const List<CardData> starter = StarterCards.all;

  /// 직업별 카드.
  static List<CardData> jobCards(String jobId) {
    switch (jobId) {
      case 'warrior':
        return WarriorCards.all;
      case 'sage':
        return SageCards.all;
      case 'assassin':
        return AssassinCards.all;
      case 'saint':
        return SaintCards.all;
      case 'guardian':
        return GuardianCards.all;
      case 'wanderer':
        return WandererCards.all;
      case 'reaper':
        return ReaperCards.all;
      case 'illusionist':
        return IllusionistCards.all;
      case 'harmonist':
        return HarmonistCards.all;
      // 2차 전직 — 상위직
      case 'swordSaint':
        return SwordSaintCards.all;
      case 'highPriest':
        return HighPriestCards.all;
      case 'archmage':
        return ArchmageCards.all;
      case 'shadowLord':
        return ShadowLordCards.all;
      case 'ironFortress':
        return IronFortressCards.all;
      case 'fateTraveler':
        return FateTravelerCards.all;
      case 'netherKing':
        return NetherKingCards.all;
      case 'dimensionMage':
        return DimensionMageCards.all;
      case 'oneWithAll':
        return OneWithAllCards.all;
      // 2차 전직 — 조합직
      case 'spellBlade':
        return SpellBladeCards.all;
      case 'holyKnight':
        return HolyKnightCards.all;
      case 'darkMage':
        return DarkMageCards.all;
      case 'darkKnight':
        return DarkKnightCards.all;
      case 'arbiter':
        return ArbiterCards.all;
      default:
        return [];
    }
  }

  /// 직업별 시작 카드 (공통 제외).
  static List<CardData> jobStarter(String jobId) {
    switch (jobId) {
      case 'warrior':
        return WarriorCards.starter;
      case 'sage':
        return SageCards.starter;
      case 'assassin':
        return AssassinCards.starter;
      case 'saint':
        return SaintCards.starter;
      case 'guardian':
        return GuardianCards.starter;
      case 'wanderer':
        return WandererCards.starter;
      case 'reaper':
        return ReaperCards.starter;
      case 'illusionist':
        return IllusionistCards.starter;
      case 'harmonist':
        return HarmonistCards.starter;
      // 2차 전직 — 상위직
      case 'swordSaint':
        return SwordSaintCards.starter;
      case 'highPriest':
        return HighPriestCards.starter;
      case 'archmage':
        return ArchmageCards.starter;
      case 'shadowLord':
        return ShadowLordCards.starter;
      case 'ironFortress':
        return IronFortressCards.starter;
      case 'fateTraveler':
        return FateTravelerCards.starter;
      case 'netherKing':
        return NetherKingCards.starter;
      case 'dimensionMage':
        return DimensionMageCards.starter;
      case 'oneWithAll':
        return OneWithAllCards.starter;
      // 2차 전직 — 조합직
      case 'spellBlade':
        return SpellBladeCards.starter;
      case 'holyKnight':
        return HolyKnightCards.starter;
      case 'darkMage':
        return DarkMageCards.starter;
      case 'darkKnight':
        return DarkKnightCards.starter;
      case 'arbiter':
        return ArbiterCards.starter;
      default:
        return [];
    }
  }

  /// 직업별 보상 카드.
  static List<CardData> jobRewards(String jobId) {
    switch (jobId) {
      case 'warrior':
        return WarriorCards.rewards;
      case 'sage':
        return SageCards.rewards;
      case 'assassin':
        return AssassinCards.rewards;
      case 'saint':
        return SaintCards.rewards;
      case 'guardian':
        return GuardianCards.rewards;
      case 'wanderer':
        return WandererCards.rewards;
      case 'reaper':
        return ReaperCards.rewards;
      case 'illusionist':
        return IllusionistCards.rewards;
      case 'harmonist':
        return HarmonistCards.rewards;
      // 2차 전직 직업은 보상 카드 없음 (시작 카드만)
      default:
        return [];
    }
  }

  /// 무색 카드 기본 풀 (소울 해금 카드 미포함).
  static const List<CardData> colorless = ColorlessCards.base;

  /// 전체 231종 (기존 161 + 상위직 9×5=45 + 조합직 5×5=25).
  static final List<CardData> allCards = List.unmodifiable([
    ...StarterCards.all,
    ...WarriorCards.all,
    ...SageCards.all,
    ...AssassinCards.all,
    ...SaintCards.all,
    ...GuardianCards.all,
    ...WandererCards.all,
    ...ColorlessCards.all,
    ...ReaperCards.all,
    ...IllusionistCards.all,
    ...HarmonistCards.all,
    // 2차 전직 — 상위직
    ...SwordSaintCards.all,
    ...HighPriestCards.all,
    ...ArchmageCards.all,
    ...ShadowLordCards.all,
    ...IronFortressCards.all,
    ...FateTravelerCards.all,
    ...NetherKingCards.all,
    ...DimensionMageCards.all,
    ...OneWithAllCards.all,
    // 2차 전직 — 조합직
    ...SpellBladeCards.all,
    ...HolyKnightCards.all,
    ...DarkMageCards.all,
    ...DarkKnightCards.all,
    ...ArbiterCards.all,
  ]);

  /// ID → CardData 인덱스 (O(1) 조회, 업그레이드 카드 포함).
  static final Map<String, CardData> _idIndex = {
    for (final card in allCards) card.id: card,
    for (final entry in CardUpgradeRegistry.allUpgrades.entries)
      entry.value.id: entry.value,
  };

  /// ID로 카드 검색 (O(1)).
  static CardData? findById(String id) => _idIndex[id];
}
