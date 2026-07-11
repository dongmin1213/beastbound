import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soul_dungeon/core/events/floor_completed_event.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/core/events/run_completed_event.dart';
import 'package:soul_dungeon/domain/run/run_event.dart';
import 'package:soul_dungeon/domain/run/run_state.dart';
import 'package:soul_dungeon/core/models/player_run_state.dart';

/// RunBloc — 플레이어 런 상태(HP/gold/floor) 관리.
/// AdvanceFloor 시 [gameEventBus]를 통해 FloorCompletedEvent/RunCompletedEvent 발행.
///
/// [initialPlayerState]를 전달하면 즉시 RunActive로 시작.
/// 생략하면 RunInitial → InitializeRun 이벤트로 전환.
class RunBloc extends Bloc<RunEvent, RunState> {
  final GameEventBus _gameEventBus;

  RunBloc({PlayerRunState? initialPlayerState, required GameEventBus gameEventBus})
      : _gameEventBus = gameEventBus,
        super(initialPlayerState != null
            ? RunActive(playerRunState: initialPlayerState)
            : const RunInitial()) {
    on<InitializeRun>(_onInitializeRun);
    on<GainGold>(_onGainGold);
    on<SetGold>(_onSetGold);
    on<ChangeHp>(_onChangeHp);
    on<ChangeMaxHp>(_onChangeMaxHp);
    on<SyncFromCombat>(_onSyncFromCombat);
    on<SetPlayerRunState>(_onSetPlayerRunState);
    on<ResetRun>(_onResetRun);
    on<SetJobId>(_onSetJobId);
    on<AcquireBlessing>(_onAcquireBlessing);
    on<AcquireRelic>(_onAcquireRelic);
    on<ApplyCurse>(_onApplyCurse);
    on<AdvanceFloor>(_onAdvanceFloor);
    on<RecordBossChoice>(_onRecordBossChoice);
  }

  void _onInitializeRun(InitializeRun event, Emitter<RunState> emit) {
    emit(RunActive(
      playerRunState: PlayerRunState.initial(maxHp: event.maxHp),
    ));
  }

  void _onGainGold(GainGold event, Emitter<RunState> emit) {
    final current = state;
    if (current is! RunActive) return;
    final prs = current.playerRunState;
    emit(RunActive(
      playerRunState: prs.copyWith(gold: prs.gold + event.amount),
    ));
  }

  void _onSetGold(SetGold event, Emitter<RunState> emit) {
    final current = state;
    if (current is! RunActive) return;
    emit(RunActive(
      playerRunState: current.playerRunState.copyWith(gold: event.gold),
    ));
  }

  void _onChangeHp(ChangeHp event, Emitter<RunState> emit) {
    final current = state;
    if (current is! RunActive) return;
    final prs = current.playerRunState;
    final newHp = (prs.currentHp + event.delta).clamp(0, prs.maxHp);
    emit(RunActive(
      playerRunState: prs.copyWith(currentHp: newHp),
    ));
  }

  void _onChangeMaxHp(ChangeMaxHp event, Emitter<RunState> emit) {
    final current = state;
    if (current is! RunActive) return;
    final prs = current.playerRunState;
    final newMaxHp = max(1, prs.maxHp + event.delta);
    final clampedHp = prs.currentHp.clamp(0, newMaxHp);
    emit(RunActive(
      playerRunState: prs.copyWith(maxHp: newMaxHp, currentHp: clampedHp),
    ));
  }

  /// 전투 결과 동기화.
  ///
  /// **동기화 전략:**
  /// - 전투가 권한을 가진 필드 (HP, maxHp, masterDeck, removedCardIds):
  ///   `event.playerRunState` 사용
  /// - RunBloc이 권한을 가진 필드 (gold, disposition, blessings, relics,
  ///   curses, floor, bossChoices, completedFloors, jobId):
  ///   RunBloc 상태 유지 (전투 중 GainGold/ChangeDisposition/AcquireBlessing 등
  ///   이벤트로 이미 RunBloc에 반영됨)
  void _onSyncFromCombat(SyncFromCombat event, Emitter<RunState> emit) {
    final current = state;
    if (current is! RunActive) return;
    final runPrs = current.playerRunState;
    final combatPrs = event.playerRunState;

    emit(RunActive(
      playerRunState: runPrs.copyWith(
        currentHp: combatPrs.currentHp,
        maxHp: combatPrs.maxHp,
        masterDeck: combatPrs.masterDeck,
        removedCardIds: combatPrs.removedCardIds,
      ),
    ));
  }

  void _onSetPlayerRunState(
      SetPlayerRunState event, Emitter<RunState> emit) {
    emit(RunActive(playerRunState: event.playerRunState));
  }

  void _onResetRun(ResetRun event, Emitter<RunState> emit) {
    emit(RunActive(
      playerRunState: PlayerRunState.initial(maxHp: event.maxHp),
    ));
  }

  void _onSetJobId(SetJobId event, Emitter<RunState> emit) {
    final current = state;
    if (current is! RunActive) return;
    emit(RunActive(
      playerRunState: current.playerRunState.copyWith(
        currentJobId: event.jobId,
      ),
    ));
  }

  void _onAcquireBlessing(AcquireBlessing event, Emitter<RunState> emit) {
    final current = state;
    if (current is! RunActive) return;
    final prs = current.playerRunState;
    // 중복 구매 방지
    if (prs.ownedBlessingIds.contains(event.blessingId)) return;
    emit(RunActive(
      playerRunState: prs.copyWith(
        ownedBlessingIds: [...prs.ownedBlessingIds, event.blessingId],
      ),
    ));
  }

  void _onAcquireRelic(AcquireRelic event, Emitter<RunState> emit) {
    final current = state;
    if (current is! RunActive) return;
    final prs = current.playerRunState;
    // 중복 구매 방지
    if (prs.ownedRelicIds.contains(event.relicId)) return;
    emit(RunActive(
      playerRunState: prs.copyWith(
        ownedRelicIds: [...prs.ownedRelicIds, event.relicId],
      ),
    ));
  }

  void _onApplyCurse(ApplyCurse event, Emitter<RunState> emit) {
    final current = state;
    if (current is! RunActive) return;
    final prs = current.playerRunState;
    emit(RunActive(
      playerRunState: prs.copyWith(
        activeCurseIds: [...prs.activeCurseIds, event.curseId],
      ),
    ));
  }

  void _onAdvanceFloor(AdvanceFloor event, Emitter<RunState> emit) {
    final current = state;
    if (current is! RunActive) return;
    final prs = current.playerRunState;

    final completedFloors = {...prs.completedFloors, prs.currentFloor};

    if (prs.currentFloor >= event.maxFloor) {
      // 최종 층 완료 — 상태 업데이트 후 RunCompletedEvent 발행
      emit(RunActive(
        playerRunState: prs.copyWith(completedFloors: completedFloors),
      ));
      _gameEventBus.emit(
          FloorCompletedEvent(floorNumber: prs.currentFloor));
      _gameEventBus.emit(
          RunCompletedEvent(totalFloors: event.maxFloor, jobId: prs.currentJobId));
      return;
    }

    // 다음 층으로 진행
    final nextFloor = prs.currentFloor + 1;
    emit(RunActive(
      playerRunState: prs.copyWith(
        currentFloor: nextFloor,
        completedFloors: completedFloors,
      ),
    ));
    _gameEventBus.emit(
        FloorCompletedEvent(floorNumber: prs.currentFloor));
  }

  void _onRecordBossChoice(RecordBossChoice event, Emitter<RunState> emit) {
    final current = state;
    if (current is! RunActive) return;
    final prs = current.playerRunState;
    emit(RunActive(
      playerRunState: prs.copyWith(
        bossChoices: [...prs.bossChoices, event.bossChoice],
      ),
    ));
  }
}
