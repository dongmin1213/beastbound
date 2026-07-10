import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/core/models/player_run_state.dart';

/// HP 비율 기반 서술 티어.
enum HpNarrationTier {
  healthy, // 70%+
  wounded, // 50~70%
  critical, // 30~50%
  danger, // 0~30% (alive)
  dead, // 0%
}

/// 전투 패배 시 HP 손실 계산 + 퍼마데스 판정. 순수 함수, 상태 없음.
class CombatDefeatHandler {
  CombatDefeatHandler._();

  /// RoomType + CombatBalanceConfig → HP 손실량.
  static int calculateHpLoss(RoomType roomType, CombatBalanceConfig config) {
    return switch (roomType) {
      RoomType.elite => config.eliteDefeatHpLoss,
      RoomType.boss => config.bossDefeatHpLoss,
      _ => config.normalDefeatHpLoss,
    };
  }

  /// HP 손실 적용. 0 미만 클램프.
  static PlayerRunState applyDamage(PlayerRunState state, int loss) {
    final newHp = (state.currentHp - loss).clamp(0, state.maxHp);
    return state.copyWith(currentHp: newHp);
  }

  /// 퍼마데스 판정.
  static bool isPermadeath(PlayerRunState state) => !state.isAlive;

  /// HP 비율 기반 서술 티어.
  static HpNarrationTier hpNarrationTier(PlayerRunState state) {
    if (state.currentHp <= 0) return HpNarrationTier.dead;
    final percent = state.hpPercent;
    if (percent <= 0.3) return HpNarrationTier.danger;
    if (percent <= 0.5) return HpNarrationTier.critical;
    if (percent <= 0.7) return HpNarrationTier.wounded;
    return HpNarrationTier.healthy;
  }
}
