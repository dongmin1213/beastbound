import 'package:flutter/foundation.dart';
import 'package:soul_dungeon/core/logging/game_logger.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
export 'package:soul_dungeon/core/models/game_enums.dart' show CombatOutcome;

/// 전투 결과 점수 데이터
class CombatResultScore {
  final int score;
  final CombatOutcome outcome;
  final List<String> turnResults;

  const CombatResultScore({
    required this.score,
    required this.outcome,
    required this.turnResults,
  });
}

/// 턴 결과 리스트를 포인트로 합산하여 전투 결과 판정
class CombatResultCalculator {
  CombatResultCalculator._();

  /// effective=+1, neutral=0, ineffective=-1
  /// 합산 >= victoryThreshold → victory, 미만 → defeat
  static CombatResultScore calculate(
    List<String> turnResults, {
    int victoryThreshold = 0,
  }) {
    int score = 0;
    for (final result in turnResults) {
      switch (result) {
        case 'effective':
          score += 1;
        case 'neutral':
          score += 0;
        case 'ineffective':
          score -= 1;
        default:
          if (kDebugMode) {
            GameLogger.warning(
              LogSystem.combat,
              'Unknown turn result type: $result, treating as neutral',
            );
          }
      }
    }
    return CombatResultScore(
      score: score,
      outcome: score >= victoryThreshold
          ? CombatOutcome.victory
          : CombatOutcome.defeat,
      turnResults: turnResults,
    );
  }
}
