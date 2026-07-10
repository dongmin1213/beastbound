import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/models/momentum_types.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 기세 변동 계산 순수 유틸리티 (domain 의존 없음)
class MomentumCalculator {
  MomentumCalculator._();

  /// 행동 전환/반복에 따른 기세 변동량 계산.
  ///
  /// [consecutiveCount]: 이전까지 같은 행동을 연속한 횟수 (현재 선택 미포함).
  /// 0=이전과 다름, 1=직전이 같음(2연속), 2+=3연속 이상.
  static MomentumDelta calculateDelta({
    required ActionType? previousAction,
    required ActionType currentAction,
    required int consecutiveCount,
    required MomentumConfig config,
  }) {
    // 첫 턴: 이전 행동 없음 → 변동 없음
    if (previousAction == null) {
      return const MomentumDelta(value: 0, reason: MomentumChangeReason.none);
    }

    // 행동 전환
    if (previousAction != currentAction) {
      // 환경 활용 행동 전환: 특별 보너스 (관찰 투자 보상)
      if (currentAction == ActionType.environment) {
        return MomentumDelta(
          value: config.environmentMomentumBonus,
          reason: MomentumChangeReason.environmentAction,
        );
      }
      // 특수 행동 전환: 환경과 동등한 보너스 (직업 분화 보상)
      if (currentAction == ActionType.special) {
        return MomentumDelta(
          value: config.specialActionMomentumBonus,
          reason: MomentumChangeReason.specialAction,
        );
      }
      // 일반 행동 전환: 표준 보너스
      return MomentumDelta(
        value: config.actionSwitchBonus,
        reason: MomentumChangeReason.actionSwitch,
      );
    }

    // 같은 행동 3+연속: 큰 페널티
    if (consecutiveCount >= 2) {
      return MomentumDelta(
        value: config.sameActionStreakPenalty,
        reason: MomentumChangeReason.sameActionStreak,
      );
    }

    // 같은 행동 2연속: 페널티
    return MomentumDelta(
      value: config.sameActionPenalty,
      reason: MomentumChangeReason.sameAction,
    );
  }

  /// 카드 전투용 기세 변동량 계산.
  ///
  /// - 다른 유형 카드 플레이: +actionSwitchBonus (기본 15)
  /// - 환경 카드: +environmentMomentumBonus (기본 25)
  /// - 동일 유형 반복: 페널티 없음 (0)
  /// - 첫 턴: 변동 없음
  static MomentumDelta calculateCardDelta({
    required CardType? previousCardType,
    required CardType currentCardType,
    required MomentumConfig config,
  }) {
    if (previousCardType == null) {
      return const MomentumDelta(value: 0, reason: MomentumChangeReason.none);
    }

    if (previousCardType != currentCardType) {
      return MomentumDelta(
        value: config.actionSwitchBonus,
        reason: MomentumChangeReason.cardTypeSwitch,
      );
    }

    // 동일 유형 반복: 페널티 없음
    return const MomentumDelta(value: 0, reason: MomentumChangeReason.none);
  }

  /// 기세 값 업데이트 (클램핑 적용)
  static int applyDelta(
      int current, MomentumDelta delta, MomentumConfig config) {
    return (current + delta.value).clamp(config.min, config.max);
  }

  /// 현재 기세 단계 판정
  static MomentumTier getTier(int momentum, MomentumConfig config) {
    if (momentum >= config.thresholdHigh) return MomentumTier.high;
    if (momentum >= config.thresholdMedium) return MomentumTier.medium;
    return MomentumTier.low;
  }
}
