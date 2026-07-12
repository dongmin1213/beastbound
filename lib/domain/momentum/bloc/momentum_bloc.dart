import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/core/events/momentum_gain_event.dart';
import 'package:soul_dungeon/core/events/rest_choice_event.dart';
import 'package:soul_dungeon/domain/momentum/bloc/momentum_event.dart';
import 'package:soul_dungeon/domain/momentum/bloc/momentum_state.dart';
import 'package:soul_dungeon/core/events/momentum_changed_event.dart';
import 'package:soul_dungeon/domain/momentum/logic/momentum_calculator.dart';
import 'package:soul_dungeon/core/models/momentum_types.dart';

export 'momentum_event.dart';
export 'momentum_state.dart';

/// 야성 상태를 관리하는 Bloc.
///
/// 생성자 주입: [GameEventBus] + [MomentumConfig].
/// 크로스도메인 통신은 [GameEventBus]를 통해 [MomentumChangedEvent] 발행.
class MomentumBloc extends Bloc<MomentumEvent, MomentumState> {
  final GameEventBus gameEventBus;
  final MomentumConfig config;
  int _consecutiveSameAction = 0;
  StreamSubscription<RestChoiceEvent>? _restChoiceSubscription;
  StreamSubscription<MomentumGainEvent>? _momentumGainSubscription;

  MomentumBloc({required this.gameEventBus, required this.config})
      : super(const MomentumInitial()) {
    on<ActionPerformed>(_onActionPerformed);
    on<CardPlayed>(_onCardPlayed);
    on<DirectMomentumGain>(_onDirectMomentumGain);
    on<MomentumReset>(_onMomentumReset);
    on<RestoreMomentum>(_onRestoreMomentum);

    _restChoiceSubscription = gameEventBus
        .on<RestChoiceEvent>()
        .listen((_) { add(const MomentumReset()); });

    _momentumGainSubscription = gameEventBus
        .on<MomentumGainEvent>()
        .listen((e) { add(DirectMomentumGain(e.amount)); });
  }

  void _onActionPerformed(
    ActionPerformed event,
    Emitter<MomentumState> emit,
  ) {
    final currentState = state;
    final previousValue =
        currentState is MomentumUpdated ? currentState.value : config.initialValue;
    final previousAction =
        currentState is MomentumUpdated ? currentState.lastActionType : null;

    // 연속 행동 추적 — calculateDelta 이전에 업데이트해야 3연속 시점 정확
    if (previousAction == event.actionType) {
      _consecutiveSameAction++;
    } else {
      _consecutiveSameAction = 0;
    }

    final delta = MomentumCalculator.calculateDelta(
      previousAction: previousAction,
      currentAction: event.actionType,
      consecutiveCount: _consecutiveSameAction,
      config: config,
    );

    final newValue = MomentumCalculator.applyDelta(previousValue, delta, config);
    final newTier = MomentumCalculator.getTier(newValue, config);

    emit(MomentumUpdated(
      value: newValue,
      tier: newTier,
      lastDelta: delta,
      lastActionType: event.actionType,
      consecutiveSameAction: _consecutiveSameAction,
    ));

    // 크로스도메인 통신
    gameEventBus.emit(MomentumChangedEvent(value: newValue, tier: newTier));
  }

  void _onCardPlayed(
    CardPlayed event,
    Emitter<MomentumState> emit,
  ) {
    final currentState = state;
    final previousValue =
        currentState is MomentumUpdated ? currentState.value : config.initialValue;
    final previousCardType =
        currentState is MomentumUpdated ? currentState.lastCardType : null;

    final delta = MomentumCalculator.calculateCardDelta(
      previousCardType: previousCardType,
      currentCardType: event.cardType,
      config: config,
    );

    final newValue = MomentumCalculator.applyDelta(previousValue, delta, config);
    final newTier = MomentumCalculator.getTier(newValue, config);

    emit(MomentumUpdated(
      value: newValue,
      tier: newTier,
      lastDelta: delta,
      lastCardType: event.cardType,
    ));

    gameEventBus.emit(MomentumChangedEvent(value: newValue, tier: newTier));
  }

  void _onDirectMomentumGain(
    DirectMomentumGain event,
    Emitter<MomentumState> emit,
  ) {
    final currentState = state;
    final previousValue =
        currentState is MomentumUpdated ? currentState.value : config.initialValue;

    final newValue = (previousValue + event.amount).clamp(config.min, config.max);
    final newTier = MomentumCalculator.getTier(newValue, config);

    emit(MomentumUpdated(
      value: newValue,
      tier: newTier,
      lastDelta: MomentumDelta(
        value: event.amount,
        reason: MomentumChangeReason.none,
      ),
      lastActionType:
          currentState is MomentumUpdated ? currentState.lastActionType : null,
      lastCardType:
          currentState is MomentumUpdated ? currentState.lastCardType : null,
      consecutiveSameAction:
          currentState is MomentumUpdated ? currentState.consecutiveSameAction : 0,
    ));

    gameEventBus.emit(MomentumChangedEvent(value: newValue, tier: newTier));
  }

  void _onRestoreMomentum(
    RestoreMomentum event,
    Emitter<MomentumState> emit,
  ) {
    _consecutiveSameAction = event.consecutiveCount;
    final value = event.value.clamp(config.min, config.max);
    final tier = MomentumCalculator.getTier(value, config);
    emit(MomentumUpdated(
      value: value,
      tier: tier,
      lastDelta: const MomentumDelta(value: 0, reason: MomentumChangeReason.none),
      consecutiveSameAction: event.consecutiveCount,
    ));
    gameEventBus.emit(MomentumChangedEvent(value: value, tier: tier));
  }

  void _onMomentumReset(
    MomentumReset event,
    Emitter<MomentumState> emit,
  ) {
    _consecutiveSameAction = 0;
    emit(const MomentumInitial());

    // 크로스도메인 리셋 알림 (M3: ActionPerformed와 동일하게 발행)
    final resetTier = MomentumCalculator.getTier(config.initialValue, config);
    gameEventBus.emit(MomentumChangedEvent(
      value: config.initialValue,
      tier: resetTier,
    ));
  }

  @override
  Future<void> close() {
    _restChoiceSubscription?.cancel();
    _restChoiceSubscription = null;
    _momentumGainSubscription?.cancel();
    _momentumGainSubscription = null;
    return super.close();
  }
}
