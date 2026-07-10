import 'package:equatable/equatable.dart';

/// 데미지 계산 결과 — 공격/방어 판정 후 최종 수치.
class DamageResult extends Equatable {
  /// 카드/적 기본 데미지.
  final int rawDamage;

  /// 힘 스택 보너스.
  final int strengthBonus;

  /// 약화 적용 여부.
  final bool isWeakened;

  /// 취약 적용 여부 (피격 대상).
  final bool isVulnerable;

  /// 최종 계산 데미지 (약화/취약 적용 후).
  final int finalDamage;

  /// 블록이 흡수한 량.
  final int blockAbsorbed;

  /// 최종 HP 감소량.
  final int hpLost;

  const DamageResult({
    required this.rawDamage,
    this.strengthBonus = 0,
    this.isWeakened = false,
    this.isVulnerable = false,
    required this.finalDamage,
    this.blockAbsorbed = 0,
    required this.hpLost,
  });

  @override
  List<Object?> get props => [
        rawDamage,
        strengthBonus,
        isWeakened,
        isVulnerable,
        finalDamage,
        blockAbsorbed,
        hpLost,
      ];
}
