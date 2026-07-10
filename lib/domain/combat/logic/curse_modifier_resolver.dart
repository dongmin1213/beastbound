import 'package:soul_dungeon/core/models/curse_modifier_data.dart';

/// 저주 모디파이어 효과 해결 — 트리거 시점에 호출. 순수 함수.
///
/// [BlessingEffectResolver] 패턴을 따름.
class CurseModifierResolver {
  CurseModifierResolver._();

  // ── 전투 시작 ──

  /// 전투 저주: 적 힘 보너스.
  static CombatStartCurseResult resolveCombatStart(
    List<CurseModifierData> curses,
  ) {
    int enemyStrengthBonus = 0;

    for (final curse in curses) {
      if (curse.curseType != CurseModifierType.combat || !curse.isActive) {
        continue;
      }
      enemyStrengthBonus += _combatStrengthByLevel(curse.level);
    }

    return CombatStartCurseResult(enemyStrengthBonus: enemyStrengthBonus);
  }

  /// 레벨별 적 힘 보너스.
  static int _combatStrengthByLevel(int level) => switch (level) {
        1 => 2,
        2 => 3,
        3 => 5,
        4 => 7,
        5 => 10,
        _ => 0,
      };

  // ── 카드 보상 ──

  /// 덱 저주: 카드 보상 수 감소량.
  static int resolveRewardReduction(List<CurseModifierData> curses) {
    int reduction = 0;

    for (final curse in curses) {
      if (curse.curseType != CurseModifierType.deck || !curse.isActive) {
        continue;
      }
      reduction += _rewardReductionByLevel(curse.level);
    }

    return reduction;
  }

  static int _rewardReductionByLevel(int level) => switch (level) {
        1 => 0,
        2 => 1,
        3 => 1,
        4 => 2,
        5 => 2,
        _ => 0,
      };

  // ── 상점 가격 ──

  /// 덱 저주: 상점 가격 배율.
  static double resolveShopPriceMultiplier(List<CurseModifierData> curses) {
    double multiplier = 1.0;

    for (final curse in curses) {
      if (curse.curseType != CurseModifierType.deck || !curse.isActive) {
        continue;
      }
      multiplier *= _shopMultiplierByLevel(curse.level);
    }

    return multiplier;
  }

  static double _shopMultiplierByLevel(int level) => switch (level) {
        1 => 1.0,
        2 => 1.3,
        3 => 1.5,
        4 => 1.7,
        5 => 2.0,
        _ => 1.0,
      };

  // ── 서술자 왜곡 ──

  /// 서술자 저주: 왜곡 시작 층 오프셋 (기본 4층에서 빼기).
  static int resolveNarratorFloorOffset(List<CurseModifierData> curses) {
    int offset = 0;

    for (final curse in curses) {
      if (curse.curseType != CurseModifierType.narrator || !curse.isActive) {
        continue;
      }
      offset += _narratorOffsetByLevel(curse.level);
    }

    return offset;
  }

  static int _narratorOffsetByLevel(int level) => switch (level) {
        1 => 0,
        2 => 1,
        3 => 1,
        4 => 2,
        5 => 2,
        _ => 0,
      };

  // ── 저주 카드 ──

  /// 카드 저주: 시작 덱에 추가할 저주 카드 수.
  static int resolveCurseCardCount(List<CurseModifierData> curses) {
    int count = 0;

    for (final curse in curses) {
      if (curse.curseType != CurseModifierType.card || !curse.isActive) {
        continue;
      }
      count += _curseCardCountByLevel(curse.level);
    }

    return count;
  }

  static int _curseCardCountByLevel(int level) => switch (level) {
        1 => 1,
        2 => 1,
        3 => 2,
        4 => 2,
        5 => 3,
        _ => 0,
      };

  // ── 저주 레벨 결정 ──

  /// 클리어 횟수 → 저주 레벨 (0~5).
  static int curseLevel(int clearCount) {
    if (clearCount <= 0) return 0;
    if (clearCount <= 2) return 1;
    if (clearCount <= 4) return 2;
    if (clearCount <= 7) return 3;
    if (clearCount <= 11) return 4;
    return 5;
  }

  /// 클리어 횟수 → 활성 저주 ID 목록 생성 ('id:level' 형식).
  static List<String> generateCurseIds(int clearCount) {
    final level = curseLevel(clearCount);
    if (level <= 0) return const [];

    return [
      'curse_mod_combat:$level',
      'curse_mod_deck:$level',
      'curse_mod_card:$level',
      'curse_mod_narrator:$level',
    ];
  }
}

// ── 결과 클래스 ──

class CombatStartCurseResult {
  final int enemyStrengthBonus;

  const CombatStartCurseResult({this.enemyStrengthBonus = 0});
}
