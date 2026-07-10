import 'package:equatable/equatable.dart';
import 'package:soul_dungeon/domain/combat/models/combat_encounter_data.dart';

/// 보스 전투의 개별 페이즈 데이터 (domain).
/// 각 페이즈는 이름과 턴 리스트를 보유.
class BossPhaseData extends Equatable {
  final String phaseName;
  final List<CombatTurnInfo> turns;

  const BossPhaseData({
    required this.phaseName,
    required this.turns,
  });

  @override
  List<Object?> get props => [phaseName, turns];
}
