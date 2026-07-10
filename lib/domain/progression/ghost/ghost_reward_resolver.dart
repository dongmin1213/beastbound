import 'dart:math';

import 'package:soul_dungeon/domain/progression/ghost/ghost_reaction.dart';

/// 유령 NPC 선택지 보상/리스크 결과.
class GhostOutcome {
  /// 보상 종류: 'hp', 'momentum', 'gold', null(없음).
  final String? rewardType;

  /// 보상 수치 (양수).
  final int rewardValue;

  /// 리스크 종류: 'hpLoss', 'momentumReset', null(없음).
  final String? riskType;

  /// 리스크 수치 (양수 = 손실량).
  final int riskValue;

  const GhostOutcome({
    this.rewardType,
    this.rewardValue = 0,
    this.riskType,
    this.riskValue = 0,
  });

  bool get hasReward => rewardType != null;
  bool get hasRisk => riskType != null;

  static const empty = GhostOutcome();
}

/// 유령 NPC 선택지 보상/리스크 판정.
///
/// 선택지별 보상/리스크 확률이 반응 레벨에 따라 달라짐.
/// - familiar: 보상 높음, 리스크 낮음
/// - curious: 중간
/// - distant: 보상 낮음, 리스크 높음
class GhostRewardResolver {
  GhostRewardResolver._();

  static GhostOutcome resolve({
    required String choiceId,
    required GhostReactionLevel level,
    Random? random,
  }) {
    final rng = random ?? Random();
    final config = _outcomeTable[choiceId];
    if (config == null) return GhostOutcome.empty;

    final rates = config[level];
    if (rates == null) return GhostOutcome.empty;

    final roll = rng.nextDouble();

    String? rewardType;
    int rewardValue = 0;
    String? riskType;
    int riskValue = 0;

    // 보상 판정.
    if (roll < rates.rewardRate) {
      final rewardRoll = rng.nextInt(3);
      switch (rewardRoll) {
        case 0:
          rewardType = 'hp';
          rewardValue = rates.rewardAmount;
        case 1:
          rewardType = 'momentum';
          rewardValue = rates.rewardAmount;
        case 2:
          rewardType = 'gold';
          rewardValue = rates.rewardAmount;
      }
    }

    // 리스크 판정 (보상과 독립적으로 발생 가능).
    final riskRoll = rng.nextDouble();
    if (riskRoll < rates.riskRate) {
      final riskTypeRoll = rng.nextInt(2);
      switch (riskTypeRoll) {
        case 0:
          riskType = 'hpLoss';
          riskValue = rates.riskAmount;
        case 1:
          riskType = 'momentumReset';
          riskValue = 0;
      }
    }

    return GhostOutcome(
      rewardType: rewardType,
      rewardValue: rewardValue,
      riskType: riskType,
      riskValue: riskValue,
    );
  }

  /// 선택지 × 반응 레벨 → 확률/수치 테이블.
  static const _outcomeTable = <String, Map<GhostReactionLevel, _Rates>>{
    'ghost_talk': {
      GhostReactionLevel.familiar: _Rates(
        rewardRate: 0.8,
        rewardAmount: 8,
        riskRate: 0.1,
        riskAmount: 5,
      ),
      GhostReactionLevel.curious: _Rates(
        rewardRate: 0.5,
        rewardAmount: 6,
        riskRate: 0.2,
        riskAmount: 5,
      ),
    },
    'ghost_trade': {
      GhostReactionLevel.familiar: _Rates(
        rewardRate: 0.7,
        rewardAmount: 12,
        riskRate: 0.2,
        riskAmount: 8,
      ),
    },
    'ghost_farewell': {
      GhostReactionLevel.familiar: _Rates(
        rewardRate: 0.9,
        rewardAmount: 5,
        riskRate: 0.0,
        riskAmount: 0,
      ),
      GhostReactionLevel.curious: _Rates(
        rewardRate: 0.4,
        rewardAmount: 5,
        riskRate: 0.0,
        riskAmount: 0,
      ),
    },
    'ghost_approach': {
      GhostReactionLevel.distant: _Rates(
        rewardRate: 0.3,
        rewardAmount: 8,
        riskRate: 0.3,
        riskAmount: 8,
      ),
    },
    // ghost_ignore: 보상/리스크 없음 (테이블에 미등록 → empty).
  };
}

class _Rates {
  final double rewardRate;
  final int rewardAmount;
  final double riskRate;
  final int riskAmount;

  const _Rates({
    required this.rewardRate,
    required this.rewardAmount,
    required this.riskRate,
    required this.riskAmount,
  });
}
