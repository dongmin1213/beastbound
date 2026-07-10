import 'package:soul_dungeon/core/events/game_event.dart';

/// 보스 선택 이벤트 — 보스 승리 후 3선택지(처치/해방/공존) 선택 시 emit.
/// 크로스 시스템 반응 (NarratorBloc, AudioBloc 등)에 사용.
class BossChoiceEvent extends GameEvent {
  final int floor;
  final String bossId;
  final String choiceType; // slay, liberate, coexist, study, consume, protect
  final String? playerJobId;

  BossChoiceEvent({
    required this.floor,
    required this.bossId,
    required this.choiceType,
    this.playerJobId,
  });

  @override
  String toString() =>
      'BossChoiceEvent(floor: $floor, bossId: $bossId, choiceType: $choiceType, playerJobId: $playerJobId)';
}
