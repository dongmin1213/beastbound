import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 연쇄 보너스 계산 — 공격 카드 연속 사용 시 보너스.
///
/// 수치는 balance.json chain_bonus 섹션에서 설정.
/// 2연쇄: +20% 데미지, +1 드로우.
/// 3연쇄+: +45% 데미지, +1 드로우, +10 기세.
/// 공격(attack) 카드에만 적용 — 스킬/파워는 연쇄 끊김.
class ChainBonus {
  ChainBonus._();

  /// 연쇄 카운터 업데이트.
  ///
  /// 공격 카드 연속이면 +1, 그 외(스킬/파워/다른 타입)는 0으로 리셋.
  /// [currentType]이 attack이 아니면 0 반환 (연쇄 불가).
  static int updateChainCount(
    CardType? lastType,
    CardType currentType,
    int currentChain,
  ) {
    // 공격 카드만 연쇄 가능
    if (currentType != CardType.attack) return 0;
    if (lastType == null || lastType != CardType.attack) return 1;
    return currentChain + 1;
  }

  /// 연쇄 데미지 배율 (퍼센트).
  ///
  /// 2연쇄 → chain2BonusPercent, 3연쇄+ → chain3BonusPercent, 그 외 0%.
  static int bonusPercent(int chainCount, ChainBonusConfig config) {
    if (chainCount >= 3) return config.chain3BonusPercent;
    if (chainCount >= 2) return config.chain2BonusPercent;
    return 0;
  }

  /// 연쇄 드로우 보너스 — 2연쇄+ → chainDrawBonus.
  static int drawBonus(int chainCount, ChainBonusConfig config) {
    return chainCount >= 2 ? config.chainDrawBonus : 0;
  }

  /// 연쇄 기세 보너스 — 3연쇄+ → chain3MomentumBonus.
  static int momentumBonus(int chainCount, ChainBonusConfig config) {
    return chainCount >= 3 ? config.chain3MomentumBonus : 0;
  }

  /// [baseValue]에 연쇄 배율 적용하여 보너스 값 반환.
  static int applyToValue(int baseValue, int chainCount, ChainBonusConfig config) {
    final percent = bonusPercent(chainCount, config);
    if (percent == 0) return 0;
    return (baseValue * percent / 100).round();
  }
}
