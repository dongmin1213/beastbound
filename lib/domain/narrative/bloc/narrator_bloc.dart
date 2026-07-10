import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soul_dungeon/core/events/floor_completed_event.dart';
import 'package:soul_dungeon/core/events/game_event.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/core/events/truth_reveal_event.dart';
import 'package:soul_dungeon/core/logging/game_logger.dart';
import 'package:soul_dungeon/domain/narrative/bloc/narrator_event.dart';
import 'package:soul_dungeon/domain/narrative/bloc/narrator_state.dart';

/// 서술자 신뢰도 Bloc.
///
/// FloorCompletedEvent 구독 → 층별 신뢰도 전환.
/// domain 값 절대 변경 금지 — presentation 표시값만 왜곡.
class NarratorBloc extends Bloc<NarratorEvent, NarratorState> {
  final GameEventBus _gameEventBus;
  final Random _random;
  StreamSubscription<GameEvent>? _floorSub;
  StreamSubscription<GameEvent>? _truthSub;

  /// [hpLieRange] HP 왜곡 범위 (±). 기본값 5.
  final int hpLieRange;

  /// [microFloor] 미세 징조 시작 층. 기본값 2.
  final int microFloor;

  /// [unreliableFloor] 본격 왜곡 시작 층. 기본값 3.
  final int unreliableFloor;

  /// [heavyFloor] 심한 왜곡 시작 층. 기본값 4.
  final int heavyFloor;

  /// [silentFloor] 침묵 시작 층. 기본값 5.
  final int silentFloor;

  NarratorBloc({
    required GameEventBus gameEventBus,
    Random? random,
    this.hpLieRange = 5,
    this.microFloor = 2,
    this.unreliableFloor = 3,
    this.heavyFloor = 4,
    this.silentFloor = 5,
  })  : _gameEventBus = gameEventBus,
        _random = random ?? Random(),
        super(const NarratorReliable()) {
    on<NarratorFloorChanged>(_onFloorChanged);
    on<ResetNarrator>(_onReset);
    on<RevealTruth>(_onRevealTruth);
    on<TickTruthReveal>(_onTickTruthReveal);

    _floorSub = _gameEventBus.on<FloorCompletedEvent>().listen((event) {
      add(NarratorFloorChanged(event.floorNumber));
    });

    _truthSub = _gameEventBus.on<TruthRevealEvent>().listen((event) {
      add(RevealTruth(event.turns));
    });
  }

  void _onFloorChanged(
    NarratorFloorChanged event,
    Emitter<NarratorState> emit,
  ) {
    final floor = event.floor;

    if (floor >= silentFloor) {
      // 5층+: 침묵 + 카드 전체 왜곡
      final offset = _generateOffset();
      emit(NarratorDistorted(
        currentFloor: floor,
        hpLieOffset: offset,
        silent: true,
        cardDistortionLevel: 2,
      ));
      GameLogger.info(LogSystem.narrative, 'Narrator silent (floor $floor)');
    } else if (floor >= heavyFloor) {
      // 4층: 심한 왜곡 — HP ±5, 카드 전체 왜곡
      final offset = _generateOffset();
      emit(NarratorDistorted(
        currentFloor: floor,
        hpLieOffset: offset,
        silent: false,
        cardDistortionLevel: 2,
      ));
      GameLogger.info(
        LogSystem.narrative,
        'Narrator heavy distortion (floor $floor, offset: $offset)',
      );
    } else if (floor >= unreliableFloor) {
      // 3층: 본격 왜곡 — HP ±3, 카드 숫자 왜곡
      final offset = _generateSmallOffset();
      emit(NarratorDistorted(
        currentFloor: floor,
        hpLieOffset: offset,
        silent: false,
        cardDistortionLevel: 1,
      ));
      GameLogger.info(
        LogSystem.narrative,
        'Narrator unreliable (floor $floor, offset: $offset)',
      );
    } else if (floor >= microFloor) {
      // 2층: 미세 징조 — 글리치만, HP 오프셋 없음
      emit(NarratorDistorted(
        currentFloor: floor,
        hpLieOffset: 0,
        silent: false,
        cardDistortionLevel: 0,
        microGlitchProbability: 0.05,
      ));
      GameLogger.info(
        LogSystem.narrative,
        'Narrator micro-distortion (floor $floor)',
      );
    } else {
      // 1층: 신뢰
      emit(NarratorReliable(currentFloor: floor));
    }
  }

  void _onReset(ResetNarrator event, Emitter<NarratorState> emit) {
    emit(const NarratorReliable());
  }

  void _onRevealTruth(RevealTruth event, Emitter<NarratorState> emit) {
    final current = state;
    if (current is! NarratorDistorted) return;
    if (current.cardDistortionLevel <= 0) return;
    emit(current.copyWith(truthRevealTurnsRemaining: event.turns));
    GameLogger.info(
      LogSystem.narrative,
      'Truth revealed for ${event.turns} turns',
    );
  }

  void _onTickTruthReveal(
    TickTruthReveal event,
    Emitter<NarratorState> emit,
  ) {
    final current = state;
    if (current is! NarratorDistorted) return;
    if (current.truthRevealTurnsRemaining <= 0) return;
    final remaining = current.truthRevealTurnsRemaining - 1;
    emit(current.copyWith(truthRevealTurnsRemaining: remaining));
    if (remaining <= 0) {
      GameLogger.info(LogSystem.narrative, 'Truth reveal expired');
    }
  }

  /// [-hpLieRange, +hpLieRange] 범위의 0이 아닌 대칭 랜덤 오프셋.
  int _generateOffset() {
    final magnitude = _random.nextInt(hpLieRange) + 1; // [1, hpLieRange]
    return _random.nextBool() ? magnitude : -magnitude;
  }

  /// [-3, +3] 범위의 0이 아닌 작은 랜덤 오프셋 (3층용).
  int _generateSmallOffset() {
    final magnitude = _random.nextInt(3) + 1; // [1, 3]
    return _random.nextBool() ? magnitude : -magnitude;
  }

  @override
  Future<void> close() {
    _floorSub?.cancel();
    _truthSub?.cancel();
    return super.close();
  }
}
