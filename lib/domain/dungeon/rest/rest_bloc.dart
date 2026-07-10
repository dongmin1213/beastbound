import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/core/events/rest_choice_event.dart';
import 'package:soul_dungeon/domain/dungeon/rest/rest_event.dart';
import 'package:soul_dungeon/domain/dungeon/rest/rest_state.dart';

/// Rest Bloc — 생성자 주입, 3파일 분리.
/// 휴식 방 HP 회복/축복 강화 선택 로직 담당. presentation 의존 없음.
class RestBloc extends Bloc<RestEvent, RestState> {
  final GameEventBus gameEventBus;
  final RestConfig restConfig;

  /// 소울 업그레이드 추가 휴식 회복률 (0.0 ~ 0.1).
  final double bonusHealRate;

  RestBloc({required this.gameEventBus, required this.restConfig, this.bonusHealRate = 0.0})
      : super(const RestInitial()) {
    on<EnterRest>(_onEnterRest);
    on<ChooseHeal>(_onChooseHeal);
    on<ChooseUpgrade>(_onChooseUpgrade);
    on<ExploreMemory>(_onExploreMemory);
    on<CompleteMemoryExploration>(_onCompleteMemoryExploration);
  }

  void _onEnterRest(EnterRest event, Emitter<RestState> emit) {
    final healAmount = _calculateHealAmount(event.currentHp, event.maxHp);
    emit(RestReady(
      currentHp: event.currentHp,
      maxHp: event.maxHp,
      healAmount: healAmount,
      upgradeAmount: restConfig.maxHpIncrease,
    ));
  }

  void _onChooseHeal(ChooseHeal event, Emitter<RestState> emit) {
    final currentState = state;
    if (currentState is! RestReady) return;

    gameEventBus.emit(RestChoiceEvent(
      choiceType: 'heal',
      hpChange: currentState.healAmount,
    ));

    emit(RestClosed(
      hpRecovered: currentState.healAmount,
      maxHpIncreased: 0,
    ));
  }

  void _onChooseUpgrade(ChooseUpgrade event, Emitter<RestState> emit) {
    final currentState = state;
    if (currentState is! RestReady) return;

    gameEventBus.emit(RestChoiceEvent(
      choiceType: 'upgrade',
      maxHpChange: currentState.upgradeAmount,
    ));

    emit(RestClosed(
      hpRecovered: 0,
      maxHpIncreased: currentState.upgradeAmount,
    ));
  }

  void _onExploreMemory(ExploreMemory event, Emitter<RestState> emit) {
    final currentState = state;
    if (currentState is! RestReady) return;

    emit(MemoryExploring(
      memoryId: event.memoryId,
      memoryTitle: event.memoryTitle,
      memoryDescription: event.memoryDescription,
      currentHp: currentState.currentHp,
      maxHp: currentState.maxHp,
      healAmount: currentState.healAmount,
      upgradeAmount: currentState.upgradeAmount,
    ));
  }

  void _onCompleteMemoryExploration(
    CompleteMemoryExploration event,
    Emitter<RestState> emit,
  ) {
    final currentState = state;
    if (currentState is! MemoryExploring) return;

    emit(RestReady(
      currentHp: currentState.currentHp,
      maxHp: currentState.maxHp,
      healAmount: currentState.healAmount,
      upgradeAmount: currentState.upgradeAmount,
    ));
  }

  int _calculateHealAmount(int currentHp, int maxHp) {
    final effectiveRate = restConfig.hpRecoveryPercent + bonusHealRate;
    final rawHeal = (maxHp * effectiveRate).round();
    final missingHp = maxHp - currentHp;
    if (missingHp <= 0) return 0;
    return rawHeal < missingHp ? rawHeal : missingHp;
  }
}
