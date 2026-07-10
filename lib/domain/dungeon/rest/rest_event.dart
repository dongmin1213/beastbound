/// RestBloc 이벤트 — sealed class (Dart 3 switch exhaustiveness).
sealed class RestEvent {
  const RestEvent();
}

/// 휴식 방 진입 — 현재 HP와 최대 HP로 초기화.
final class EnterRest extends RestEvent {
  final int currentHp;
  final int maxHp;

  const EnterRest({required this.currentHp, required this.maxHp});
}

/// HP 회복 선택 — healAmount=0이어도 처리 (Story 3-7 기세 리셋 대비).
final class ChooseHeal extends RestEvent {
  const ChooseHeal();
}

/// 최대 HP 강화 선택.
final class ChooseUpgrade extends RestEvent {
  const ChooseUpgrade();
}

/// 기억 탐색 선택 — 데이터를 이벤트에 직접 전달 (domain간 의존 방지).
final class ExploreMemory extends RestEvent {
  final String memoryId;
  final String memoryTitle;
  final String memoryDescription;

  const ExploreMemory({
    required this.memoryId,
    required this.memoryTitle,
    required this.memoryDescription,
  });
}

/// 기억 탐색 완료 — RestReady 상태로 복귀.
final class CompleteMemoryExploration extends RestEvent {
  const CompleteMemoryExploration();
}
