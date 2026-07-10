import 'package:soul_dungeon/core/events/game_event.dart';

/// 미스터리 방 결과 수락 이벤트 — MysteryBloc이 AcceptResult 처리 시 발행.
/// primitive 타입만 사용 — core → domain 역방향 의존 방지.
/// 향후 인벤토리/세이브/통계 시스템 연동용.
class MysteryRewardEvent extends GameEvent {
  final String outcomeType;
  final int goldChange;
  final int hpChange;

  MysteryRewardEvent({
    required this.outcomeType,
    required this.goldChange,
    required this.hpChange,
  });

  @override
  String toString() =>
      'MysteryRewardEvent(outcomeType: $outcomeType, goldChange: $goldChange, hpChange: $hpChange)';
}
