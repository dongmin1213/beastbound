import 'package:soul_dungeon/core/models/job_path.dart';
import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 덱 분석 기반 빌드 아키타입 감지.
class BuildArchetypeDetector {
  BuildArchetypeDetector._();

  /// 덱을 분석하여 빌드명과 대표 카드를 반환.
  static BuildArchetypeResult detect(List<CardData> deck, String? jobId) {
    if (deck.isEmpty) {
      return BuildArchetypeResult(name: '빈 덱', keyCards: const []);
    }

    // 효과 기반 카운트
    int poisonCount = 0;
    int burnCount = 0;
    int strengthCount = 0;
    int blockCards = 0;
    int attackCards = 0;
    int drawCount = 0;

    for (final card in deck) {
      if (card.type == CardType.attack) attackCards++;
      if (card.block != null && card.block! > 0) blockCards++;

      for (final e in card.effects) {
        switch (e.type) {
          case CardEffectType.applyPoison:
            poisonCount++;
          case CardEffectType.applyBurn:
            burnCount++;
          case CardEffectType.gainStrength:
            strengthCount++;
          case CardEffectType.draw:
            drawCount++;
          default:
            break;
        }
      }
    }

    // 빌드명 판정 (우선순위)
    String archetype;
    if (poisonCount >= 3) {
      archetype = '독 빌드';
    } else if (burnCount >= 3) {
      archetype = '화상 빌드';
    } else if (strengthCount >= 2) {
      archetype = '힘 빌드';
    } else if (blockCards > deck.length * 0.5) {
      archetype = '방어 빌드';
    } else if (drawCount >= 3) {
      archetype = '드로우 빌드';
    } else if (attackCards > deck.length * 0.6) {
      archetype = '공격 빌드';
    } else {
      archetype = _jobDisplayName(jobId) ?? '범용 빌드';
    }

    // 대표 카드 선정: 비용 높은 순 (시작 카드 제외)
    final sortedDeck = deck.toList()
      ..sort((a, b) => b.apCost.compareTo(a.apCost));
    final keyCards = sortedDeck
        .where((c) => c.apCost >= 1)
        .take(3)
        .map((c) => c.name)
        .toList();

    return BuildArchetypeResult(name: archetype, keyCards: keyCards);
  }

  static String? _jobDisplayName(String? jobId) {
    if (jobId == null) return null;
    try {
      return JobPath.values.firstWhere((j) => j.id == jobId).displayName;
    } catch (_) {
      return null;
    }
  }
}

/// 빌드 아키타입 감지 결과.
class BuildArchetypeResult {
  final String name;
  final List<String> keyCards;

  const BuildArchetypeResult({
    required this.name,
    required this.keyCards,
  });

  /// "힘 빌드 (강타 × 전투의 함성 × 분노)" 형태.
  String formatted() {
    if (keyCards.isEmpty) return name;
    return '$name (${keyCards.join(' × ')})';
  }
}
