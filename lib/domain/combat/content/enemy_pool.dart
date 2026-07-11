import 'dart:math';
import 'package:soul_dungeon/core/config/floor_region.dart';
import 'package:soul_dungeon/domain/combat/content/floor_enemies.dart';
import 'package:soul_dungeon/core/models/enemy_combat_data.dart';
import 'package:soul_dungeon/core/models/enemy_modifier.dart';

/// 층/타입별 적 조회 중앙 레지스트리.
///
/// 5지역 × 2층 구조 — 한 지역의 두 층은 같은 적 풀을 공유한다(둘째 층은 HP 스케일링).
class EnemyPool {
  EnemyPool._();

  /// 층별 일반 적 리스트 (지역 풀 공유).
  static List<EnemyCombatData> normalEnemies(int floor) {
    return switch (FloorRegion.of(floor)) {
      1 => FloorEnemies.floor1Normal,
      2 => FloorEnemies.floor2Normal,
      3 => FloorEnemies.floor3Normal,
      4 => FloorEnemies.floor4Normal,
      5 => FloorEnemies.floor5Normal,
      _ => [],
    };
  }

  /// 층별 엘리트 적 리스트 (지역 풀 공유).
  static List<EnemyCombatData> eliteEnemies(int floor) {
    return switch (FloorRegion.of(floor)) {
      1 => FloorEnemies.floor1Elite,
      2 => FloorEnemies.floor2Elite,
      3 => FloorEnemies.floor3Elite,
      4 => FloorEnemies.floor4Elite,
      5 => FloorEnemies.floor5Elite,
      _ => [],
    };
  }

  /// 층별 랜덤 일반 적.
  static EnemyCombatData? randomNormal(int floor, {Random? random}) {
    final enemies = normalEnemies(floor);
    if (enemies.isEmpty) return null;
    final rng = random ?? Random();
    return enemies[rng.nextInt(enemies.length)];
  }

  /// 층별 랜덤 엘리트 적.
  static EnemyCombatData? randomElite(int floor, {Random? random}) {
    final enemies = eliteEnemies(floor);
    if (enemies.isEmpty) return null;
    final rng = random ?? Random();
    return enemies[rng.nextInt(enemies.length)];
  }

  /// 층별 랜덤 일반 적 + 변형 확률 적용.
  /// 2층+ 20%, 4층+ 40% 확률로 랜덤 수식어 부여.
  static EnemyCombatData? randomNormalWithVariant(
    int floor, {
    Random? random,
  }) {
    final base = randomNormal(floor, random: random);
    if (base == null) return null;
    return _applyVariant(base, floor, random: random);
  }

  /// 층별 랜덤 엘리트 적 + 변형 확률 적용.
  static EnemyCombatData? randomEliteWithVariant(
    int floor, {
    Random? random,
  }) {
    final base = randomElite(floor, random: random);
    if (base == null) return null;
    return _applyVariant(base, floor, random: random);
  }

  /// 변형 확률 적용: 2층+ 20%, 4층+ 40%.
  static EnemyCombatData _applyVariant(
    EnemyCombatData enemy,
    int floor, {
    Random? random,
  }) {
    if (floor < 2) return enemy;
    final rng = random ?? Random();
    final chance = floor >= 4 ? 0.40 : 0.20;
    if (rng.nextDouble() >= chance) return enemy;

    const modifiers = EnemyModifierType.values;
    final mod = modifiers[rng.nextInt(modifiers.length)];
    return enemy.withModifier(mod);
  }

  /// ID로 적 검색.
  static EnemyCombatData? findById(String id) {
    for (final enemy in FloorEnemies.all) {
      if (enemy.id == id) return enemy;
    }
    return null;
  }

  /// 전체 적 수.
  static int get count => FloorEnemies.all.length;
}
