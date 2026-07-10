import 'package:soul_dungeon/domain/dungeon/mystery/mystery_outcome.dart';

/// MysteryBloc 이벤트 — sealed class (Dart 3 switch exhaustiveness).
sealed class MysteryEvent {
  const MysteryEvent();
}

/// 미스터리 결과 공개 — 생성된 outcome을 Bloc에 전달.
final class RevealMystery extends MysteryEvent {
  final MysteryOutcome outcome;

  const RevealMystery(this.outcome);
}

/// 결과 수락 — 플레이어가 "진행하기" 선택.
final class AcceptResult extends MysteryEvent {
  const AcceptResult();
}
