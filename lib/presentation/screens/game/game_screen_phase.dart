/// GameScreen의 최상위 Phase — 13개 boolean 플래그 대체.
///
/// Step 6f에서 `switch (_phase)` 패턴 매칭으로
/// 기존 `_inCombat`, `_inCardCombat`, `_inPrepPhase` 등을 대체한다.
sealed class GameScreenPhase {
  const GameScreenPhase();
}

/// 텍스트 표시 Phase — 서술 진행, 선택지 표시.
class TextDisplayPhase extends GameScreenPhase {
  final bool showingChoices;
  final bool choiceSelected;

  const TextDisplayPhase({
    this.showingChoices = false,
    this.choiceSelected = false,
  });

  TextDisplayPhase copyWith({
    bool? showingChoices,
    bool? choiceSelected,
  }) {
    return TextDisplayPhase(
      showingChoices: showingChoices ?? this.showingChoices,
      choiceSelected: choiceSelected ?? this.choiceSelected,
    );
  }
}

/// 카드 전투 Phase — 카드 전투 UI 활성.
class CardCombatPhase extends GameScreenPhase {
  final bool pendingVictory;

  const CardCombatPhase({this.pendingVictory = false});

  CardCombatPhase copyWith({bool? pendingVictory}) {
    return CardCombatPhase(
      pendingVictory: pendingVictory ?? this.pendingVictory,
    );
  }
}

/// 준비 Phase — 카드 덱 확인 등 전투 전 준비 UI.
class PrepPhase extends GameScreenPhase {
  const PrepPhase();
}

/// 던전 탐색 Phase — 미니맵 표시, 경로 선택.
class DungeonExplorationPhase extends GameScreenPhase {
  final bool pendingIntro;
  final bool hasShownIntro;

  const DungeonExplorationPhase({
    this.pendingIntro = false,
    this.hasShownIntro = false,
  });

  DungeonExplorationPhase copyWith({
    bool? pendingIntro,
    bool? hasShownIntro,
  }) {
    return DungeonExplorationPhase(
      pendingIntro: pendingIntro ?? this.pendingIntro,
      hasShownIntro: hasShownIntro ?? this.hasShownIntro,
    );
  }
}

/// 방 인터랙션 Phase — 상점/NPC/이벤트/미스터리/휴식 방 UI.
class RoomInteractionPhase extends GameScreenPhase {
  final bool showingChoices;
  final bool choiceSelected;

  const RoomInteractionPhase({
    this.showingChoices = false,
    this.choiceSelected = false,
  });

  RoomInteractionPhase copyWith({
    bool? showingChoices,
    bool? choiceSelected,
  }) {
    return RoomInteractionPhase(
      showingChoices: showingChoices ?? this.showingChoices,
      choiceSelected: choiceSelected ?? this.choiceSelected,
    );
  }
}
