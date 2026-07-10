import 'dart:math';
import 'package:soul_dungeon/domain/combat/content/enemy_pool.dart';
import 'package:soul_dungeon/core/models/enemy_combat_data.dart';

/// 조우 풀 — 일반 전투에서 1~3체 멀티몹 조우 생성.
class EncounterPool {
  EncounterPool._();

  /// 일반 전투 조우 생성.
  /// 확률: 1체 60% / 2체 30% / 3체 10% (3층+만).
  /// 멀티몹 시 개별 HP 70~80% 스케일링 + 패턴 랜덤 선택 + 오프셋 부여.
  /// [enemyHpMultiplier]로 층별 HP 스케일링 적용.
  static List<EnemyCombatData> generateNormalEncounter(
    int floor, {
    double enemyHpMultiplier = 1.0,
    Random? random,
  }) {
    final rng = random ?? Random();

    // 1체는 항상 보장 — 패턴 랜덤 선택
    final baseRaw = EnemyPool.randomNormalWithVariant(floor, random: rng) ??
        EnemyPool.normalEnemies(1).first;
    final base = baseRaw.withRandomPattern(rng);

    // 멀티몹 확률 결정
    final roll = rng.nextDouble();
    int count;
    if (floor >= 3) {
      // 3층+: 1체 60% / 2체 30% / 3체 10%
      count = roll < 0.6 ? 1 : (roll < 0.9 ? 2 : 3);
    } else {
      // 1~2층: 1체 60% / 2체 40%
      count = roll < 0.6 ? 1 : 2;
    }

    if (count == 1) {
      // 층별 HP 배율 적용
      if (enemyHpMultiplier != 1.0) {
        final scaledHp = (base.hp * enemyHpMultiplier).toInt().clamp(1, 9999);
        return [base.copyWith(hp: scaledHp)];
      }
      return [base];
    }

    // 멀티몹: HP 스케일링 (70~80%) + 층별 배율 + 패턴 랜덤 + 오프셋
    final enemies = <EnemyCombatData>[];
    for (var i = 0; i < count; i++) {
      final raw = i == 0
          ? base
          : (EnemyPool.randomNormalWithVariant(floor, random: rng) ??
                  EnemyPool.normalEnemies(1).first)
              .withRandomPattern(rng);

      final scaleFactor = 0.70 + rng.nextDouble() * 0.10; // 0.70~0.80
      final scaledHp = (raw.hp * scaleFactor * enemyHpMultiplier).toInt().clamp(1, 9999);
      enemies.add(raw.copyWith(hp: scaledHp));
    }
    return enemies;
  }

  /// 멀티몹 개체별 패턴 오프셋 계산.
  /// 같은 종류 적끼리만 오프셋 부여 (다른 종류는 이미 패턴이 다름).
  static List<int> calculateOffsets(List<EnemyCombatData> enemies) {
    final offsets = List.filled(enemies.length, 0);
    final idCounts = <String, int>{};
    for (var i = 0; i < enemies.length; i++) {
      final id = enemies[i].id;
      final count = idCounts[id] ?? 0;
      offsets[i] = count;
      idCounts[id] = count + 1;
    }
    return offsets;
  }
}
