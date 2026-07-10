import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 카드 전투 텍스트 표시 포맷터 — presentation 전용.
class CardDisplayFormatter {
  CardDisplayFormatter._();

  /// 카드 타입 아이콘.
  static String typeIcon(CardType type) {
    return switch (type) {
      CardType.attack => '⚔',
      CardType.skill => '🛡',
      CardType.power => '✨',
    };
  }

  /// 키워드 태그 텍스트 (예: "[소진] [선천]").
  static String keywordTags(Set<CardKeyword> keywords) {
    if (keywords.isEmpty) return '';
    final tags = keywords.map((k) => switch (k) {
      CardKeyword.exhaust => '[소진]',
      CardKeyword.innate => '[선천]',
      CardKeyword.ethereal => '[영혼]',
      CardKeyword.retain => '[잔류]',
    });
    return tags.join(' ');
  }

  /// 카드 한줄 서식 — "[1AP] ⚔ 강타 — 14 데미지".
  static String formatCardLine(CardData card) {
    final icon = typeIcon(card.type);
    final parts = <String>[];

    if (card.damage != null) parts.add('${card.damage} 데미지');
    if (card.block != null) parts.add('${card.block} 블록');

    // 추가 효과 간단 표시
    for (final e in card.effects) {
      switch (e.type) {
        case CardEffectType.draw:
          parts.add('${e.value}장 드로우');
        case CardEffectType.heal:
          parts.add('${e.value} 회복');
        case CardEffectType.apGain:
          parts.add('AP +${e.value}');
        case CardEffectType.applyPoison:
          parts.add('독 ${e.value}');
        case CardEffectType.applyBurn:
          parts.add('화상 ${e.value}');
        case CardEffectType.applyWeak:
          parts.add('약화 ${e.duration ?? e.value}턴');
        case CardEffectType.applyVulnerable:
          parts.add('취약 ${e.duration ?? e.value}턴');
        case CardEffectType.gainStrength:
          parts.add('힘 +${e.value}');
        case CardEffectType.gainDexterity:
          parts.add('민첩 +${e.value}');
        case CardEffectType.cleanse:
          parts.add('정화');
        case CardEffectType.retribution:
          parts.add('응보 ${e.value}%');
        case CardEffectType.blockPerTurnStart:
          parts.add('매턴 블록 ${e.value}');
        case CardEffectType.blockRetain:
          parts.add('블록 유지');
        case CardEffectType.thornMultiplierDamage:
          parts.add('가시 반사 ${e.value}%');
        case CardEffectType.generateRandomCard:
          parts.add('카드 생성');
        case CardEffectType.coinFlip:
          parts.add('동전 던지기');
        case CardEffectType.randomDamage:
          parts.add('랜덤 데미지');
        case CardEffectType.randomDebuffs:
          parts.add('랜덤 디버프');
        case CardEffectType.mimicEnemyDamage:
          parts.add('적 공격 모방');
        case CardEffectType.blockPerCardPlayed:
          parts.add('카드당 블록 ${e.value}');
        case CardEffectType.retrieveRandomPerTurn:
          parts.add('매턴 회수 ${e.value}');
        case CardEffectType.blockPerTurnStartConditional:
          parts.add('조건부 매턴 블록 ${e.value}');
        default:
          break;
      }
    }

    final effectText = parts.isNotEmpty ? ' — ${parts.join(', ')}' : '';
    final kwText = keywordTags(card.keywords);
    final kwSuffix = kwText.isNotEmpty ? ' $kwText' : '';

    return '[${card.apCost}AP] $icon ${card.name}$effectText$kwSuffix';
  }

  /// 카드 선택지 표시 (비용 초과 표시 포함).
  static String formatCardChoice(CardData card, int currentAp) {
    final base = formatCardLine(card);
    if (card.apCost > currentAp) {
      return '$base [비용 초과]';
    }
    return base;
  }

  /// 전투 상태 바.
  static String formatStatusBar({
    required int playerHp,
    required int playerMaxHp,
    required int playerBlock,
    required int actionPoints,
    required int maxActionPoints,
    required String enemyName,
    required int enemyHp,
    required int enemyMaxHp,
    required int enemyBlock,
    required int currentTurn,
  }) {
    final apBar = '■' * actionPoints + '□' * (maxActionPoints - actionPoints);
    final blockText = playerBlock > 0 ? '  블록: $playerBlock' : '';
    final enemyBlockText = enemyBlock > 0 ? ' [블록 $enemyBlock]' : '';

    return '[$currentTurn턴] HP: $playerHp/$playerMaxHp$blockText  '
        'AP: $apBar ($actionPoints/$maxActionPoints)  '
        '$enemyName: $enemyHp/$enemyMaxHp$enemyBlockText';
  }

  /// 상태 효과 요약 텍스트.
  static String formatStatusEffects(
    List<({String name, int stacks})> effects,
  ) {
    if (effects.isEmpty) return '';
    return effects.map((e) => '${e.name} ${e.stacks}').join(' | ');
  }
}
