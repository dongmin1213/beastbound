import 'dart:math';

import 'package:soul_dungeon/domain/progression/ghost/ghost_npc_data.dart';
import 'package:soul_dungeon/domain/progression/ghost/ghost_reaction.dart';

/// 유령 NPC 생성기 — 사망 기록 기반 유령 스폰 + 반응 레벨 판정.
class GhostNpcGenerator {
  GhostNpcGenerator._();

  /// 유령 등장 여부 결정.
  /// [currentRun]: 현재 런 번호 (1-based).
  /// [ghostPool]: 기존 유령 풀 (사망 기록).
  /// [currentFloor]: 현재 층.
  /// [random]: 테스트용 Random 주입.
  static GhostNpcData? trySpawn({
    required int currentRun,
    required List<GhostNpcData> ghostPool,
    required int currentFloor,
    int guaranteeRun = 2,
    double spawnProbability = 0.3,
    Random? random,
  }) {
    if (ghostPool.isEmpty) return null;
    final rng = random ?? Random();

    // 2런차 2층: 확정 등장
    if (currentRun == guaranteeRun && currentFloor == 2) {
      return ghostPool.last; // 가장 최근 사망
    }

    // 3런차+: 확률 등장
    if (currentRun > guaranteeRun) {
      if (rng.nextDouble() < spawnProbability) {
        // 같은 층에서 사망한 유령 우선, 없으면 랜덤
        final sameFloor =
            ghostPool.where((g) => g.deathFloor == currentFloor).toList();
        if (sameFloor.isNotEmpty) {
          return sameFloor[rng.nextInt(sameFloor.length)];
        }
        return ghostPool[rng.nextInt(ghostPool.length)];
      }
    }

    return null;
  }

  /// 코사인 유사도 기반 반응 레벨 결정.
  /// [ghostDisposition]: 유령 NPC의 성향 스냅샷.
  /// [currentDisposition]: 현재 플레이어의 성향.
  static GhostReactionLevel reactionLevel({
    required Map<String, int> ghostDisposition,
    required Map<String, int> currentDisposition,
    double familiarThreshold = 0.7,
    double curiousThreshold = 0.3,
  }) {
    final similarity = cosineSimilarity(ghostDisposition, currentDisposition);
    if (similarity >= familiarThreshold) return GhostReactionLevel.familiar;
    if (similarity >= curiousThreshold) return GhostReactionLevel.curious;
    return GhostReactionLevel.distant;
  }

  /// 코사인 유사도 계산 (6축 성향 벡터).
  /// 두 벡터가 모두 0이면 0.0 반환.
  static double cosineSimilarity(
    Map<String, int> a,
    Map<String, int> b,
  ) {
    final keys = {...a.keys, ...b.keys};
    if (keys.isEmpty) return 0.0;

    double dotProduct = 0;
    double normA = 0;
    double normB = 0;

    for (final key in keys) {
      final va = (a[key] ?? 0).toDouble();
      final vb = (b[key] ?? 0).toDouble();
      dotProduct += va * vb;
      normA += va * va;
      normB += vb * vb;
    }

    if (normA == 0 || normB == 0) return 0.0;
    return dotProduct / (sqrt(normA) * sqrt(normB));
  }
}
