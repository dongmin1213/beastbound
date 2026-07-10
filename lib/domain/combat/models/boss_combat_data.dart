import 'package:equatable/equatable.dart';
import 'package:soul_dungeon/core/models/enemy_action_type.dart';

/// 보스 기믹 유형.
enum BossGimmick {
  /// 기믹 없음.
  none,

  /// 재생 — 매 턴 시작 시 HP 회복.
  regen,

  /// 거미줄 — 플레이어 드로우 -1.
  web,

  /// 분노 — 피격 시 힘 +2.
  rage,

  /// 흡혈 — 공격 데미지의 일부 HP 회복.
  drain,

  /// 형태 변환 — 페이즈별 다른 패턴/스탯.
  formShift,

  /// 출혈 — 공격 시 플레이어에게 화상 2.
  bleed,

  /// 속박 — 매 턴 플레이어 AP -1.
  shackle,

  /// 반사 — 받은 데미지 15% 반사.
  reflect,

  /// 부패 — 매 턴 플레이어 랜덤 디버프 1.
  corruption,

  /// 공허 — 매 턴 드로우 -1 + 소진 1장.
  voidGimmick,
}

/// 보스 개별 페이즈 설정.
class BossPhaseConfig extends Equatable {
  final int hp;
  final int atk;
  final int def;
  final List<EnemyActionType> pattern;
  final BossGimmick gimmick;

  const BossPhaseConfig({
    required this.hp,
    required this.atk,
    required this.def,
    required this.pattern,
    this.gimmick = BossGimmick.none,
  });

  @override
  List<Object?> get props => [hp, atk, def, pattern, gimmick];
}

/// 보스 카드 전투 데이터 — 다단계 페이즈.
class BossCombatData extends Equatable {
  final String id;
  final String name;
  final int floor;
  final List<BossPhaseConfig> phases;

  const BossCombatData({
    required this.id,
    required this.name,
    required this.floor,
    required this.phases,
  });

  /// 총 페이즈 수.
  int get totalPhases => phases.length;

  /// 페이즈 설정 조회. 범위 초과 시 마지막 페이즈 반환.
  BossPhaseConfig phaseAt(int index) =>
      phases[index.clamp(0, phases.length - 1)];

  @override
  List<Object?> get props => [id, name, floor, phases];
}
