import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/core/events/mystery_reward_event.dart';
import 'package:soul_dungeon/domain/dungeon/mystery/mystery_event.dart';
import 'package:soul_dungeon/domain/dungeon/mystery/mystery_outcome.dart';
import 'package:soul_dungeon/domain/dungeon/mystery/mystery_state.dart';

/// 미스터리 방 Bloc — 생성자 주입, 3파일 분리.
/// 결과 공개 → 수락 흐름 관리. presentation 의존 없음.
class MysteryBloc extends Bloc<MysteryEvent, MysteryState> {
  final GameEventBus gameEventBus;

  MysteryBloc({required this.gameEventBus}) : super(const MysteryInitial()) {
    on<RevealMystery>(_onRevealMystery);
    on<AcceptResult>(_onAcceptResult);
  }

  void _onRevealMystery(RevealMystery event, Emitter<MysteryState> emit) {
    emit(MysteryRevealed(event.outcome));
  }

  void _onAcceptResult(AcceptResult event, Emitter<MysteryState> emit) {
    final currentState = state;
    if (currentState is! MysteryRevealed) return;

    final outcome = currentState.outcome;

    // outcomeType을 primitive String으로 변환 (core → domain 역방향 의존 방지)
    final outcomeType = switch (outcome) {
      TreasureOutcome() => 'treasure',
      TrapOutcome() => 'trap',
      EncounterOutcome() => 'combat',
      EventOutcome() => 'event',
      MinorOutcome() => 'minor',
    };

    gameEventBus.emit(MysteryRewardEvent(
      outcomeType: outcomeType,
      goldChange: outcome.goldChange,
      hpChange: outcome.hpChange,
    ));

    emit(MysteryCompleted(outcome));
  }
}
