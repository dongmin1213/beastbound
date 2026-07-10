import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/core/events/job_unlock_event.dart';
import 'package:soul_dungeon/core/events/permadeath_event.dart';
import 'package:soul_dungeon/core/events/run_completed_event.dart';
import 'package:soul_dungeon/core/error/result.dart';
import 'package:soul_dungeon/core/logging/game_logger.dart';
import 'package:soul_dungeon/core/save/save_data.dart';
import 'package:soul_dungeon/core/save/save_manager.dart';
import 'package:soul_dungeon/core/models/job_path.dart';
import 'package:soul_dungeon/domain/progression/bloc/progression_event.dart';
import 'package:soul_dungeon/domain/progression/bloc/progression_state.dart';
import 'package:soul_dungeon/domain/progression/memory/memory_unlock_checker.dart';
import 'package:soul_dungeon/domain/progression/soul/soul_calculator.dart';
import 'package:soul_dungeon/domain/progression/soul/soul_upgrade_data.dart';
import 'package:soul_dungeon/domain/progression/soul/soul_upgrade_pool.dart';
import 'package:soul_dungeon/domain/progression/unlock/job_unlock_checker.dart';

/// 메타 진행 Bloc — 소울 경제, 업그레이드, 런 기록 중앙 관리.
///
/// GameEventBus의 [RunCompletedEvent], [PermadeathEvent] 구독하여
/// 자동으로 소울 보상 + 기록 갱신. SaveManager 경유 저장.
class ProgressionBloc extends Bloc<ProgressionEvent, ProgressionState> {
  final GameEventBus gameEventBus;
  final SaveManager? saveManager;
  final EconomyConfig economyConfig;

  StreamSubscription<RunCompletedEvent>? _runCompletedSub;
  StreamSubscription<PermadeathEvent>? _permadeathSub;

  ProgressionBloc({
    required this.gameEventBus,
    this.saveManager,
    this.economyConfig = const EconomyConfig(),
  }) : super(const ProgressionInitial()) {
    on<LoadProgression>(_onLoad);
    on<GainSoul>(_onGainSoul);
    on<PurchaseUpgrade>(_onPurchaseUpgrade);
    on<RecordDeath>(_onRecordDeath);
    on<RecordRunCompletion>(_onRecordRunCompletion);
    on<UnlockMemory>(_onUnlockMemory);
    on<UnlockHiddenJob>(_onUnlockHiddenJob);
    on<ResetAllProgression>(_onResetAll);

    _runCompletedSub = gameEventBus.on<RunCompletedEvent>().listen((event) {
      add(RecordRunCompletion(endingName: 'clear', jobId: event.jobId));
    });
    _permadeathSub = gameEventBus.on<PermadeathEvent>().listen((_) {
      // floorReached는 이벤트에 없으므로 RecordDeath에서 별도 처리
      // 실제 floor는 호출자가 RecordDeath를 직접 dispatch
    });
  }

  void _onLoad(LoadProgression event, Emitter<ProgressionState> emit) {
    // 초기 메타 데이터는 외부에서 주입 (app.dart에서 loadMeta 후 전달)
    // 여기서는 기본값으로 시작
    emit(const ProgressionLoaded(MetaSaveData()));
  }

  void _onGainSoul(GainSoul event, Emitter<ProgressionState> emit) {
    final current = state;
    if (current is! ProgressionLoaded) return;

    final updated = current.meta.copyWith(
      soulCount: current.soulCount + event.amount,
    );
    emit(ProgressionLoaded(updated));
    _save(updated);
  }

  void _onPurchaseUpgrade(
    PurchaseUpgrade event,
    Emitter<ProgressionState> emit,
  ) {
    final current = state;
    if (current is! ProgressionLoaded) return;

    final upgrade = SoulUpgradePool.byId(event.upgradeId);
    if (upgrade == null) {
      GameLogger.warning(
        LogSystem.progression,
        'Unknown upgrade: ${event.upgradeId}',
      );
      return;
    }

    final currentLevel = current.upgradeLevels[event.upgradeId] ?? 0;
    if (currentLevel >= upgrade.maxLevel) return;

    final price = SoulCalculator.upgradePrice(
      upgrade.basePrice,
      currentLevel,
      upgrade.priceExponent,
    );
    if (current.soulCount < price) return;

    final newLevel = currentLevel + 1;
    final newLevels = Map<String, int>.from(current.upgradeLevels)
      ..[event.upgradeId] = newLevel;

    var newPurchasedIds = current.purchasedUpgradeIds;
    if (newLevel >= upgrade.maxLevel) {
      newPurchasedIds = {...newPurchasedIds, event.upgradeId};
    }

    var newUnlockedCards = current.unlockedCardIds;
    if (upgrade.effectType == SoulUpgradeEffect.unlockCard &&
        upgrade.unlockedCardId != null) {
      newUnlockedCards = {...newUnlockedCards, upgrade.unlockedCardId!};
    }

    final updated = current.meta.copyWith(
      soulCount: current.soulCount - price,
      upgradeLevels: newLevels,
      purchasedUpgradeIds: newPurchasedIds,
      unlockedCardIds: newUnlockedCards,
    );
    emit(ProgressionLoaded(updated));
    _save(updated);
  }

  void _onRecordDeath(RecordDeath event, Emitter<ProgressionState> emit) {
    final current = state;
    if (current is! ProgressionLoaded) return;

    final baseSoul = SoulCalculator.calculateDeathReward(
      event.floorReached,
      economyConfig.soulBaseGain,
    );
    // 소울 획득량 배율 (영혼 친화 업그레이드)
    final multiplier =
        SoulUpgradePool.soulGainMultiplier(current.upgradeLevels);
    final soulGained = (baseSoul * multiplier).toInt();

    // 유령 풀 갱신 (최대 10개 유지).
    final ghostPool = List<Map<String, dynamic>>.from(
      current.meta.ghostNpcPoolRaw,
    );
    if (event.ghostDataRaw != null) {
      ghostPool.add(event.ghostDataRaw!);
      if (ghostPool.length > _maxGhostPoolSize) {
        ghostPool.removeAt(0);
      }
    }

    var updated = current.meta.copyWith(
      totalRuns: current.totalRuns + 1,
      deathCount: current.deathCount + 1,
      soulCount: current.soulCount + soulGained,
      ghostNpcPoolRaw: ghostPool,
    );
    updated = _autoUnlockMemories(updated);
    emit(ProgressionLoaded(updated));
    _save(updated);
  }

  static const _maxGhostPoolSize = 10;

  void _onRecordRunCompletion(
    RecordRunCompletion event,
    Emitter<ProgressionState> emit,
  ) {
    final current = state;
    if (current is! ProgressionLoaded) return;

    final baseSoul = SoulCalculator.calculateClearReward(
      economyConfig.soulBaseGain,
    );
    // 소울 획득량 배율 (영혼 친화 업그레이드)
    final multiplier =
        SoulUpgradePool.soulGainMultiplier(current.upgradeLevels);
    final soulGained = (baseSoul * multiplier).toInt();

    // 직업별 클리어 횟수 업데이트
    final newWinsByJob = Map<String, int>.from(current.winsByJob);
    if (event.jobId != null) {
      newWinsByJob[event.jobId!] = (newWinsByJob[event.jobId!] ?? 0) + 1;
    }

    final newClearCount = current.clearCount + 1;

    var updated = current.meta.copyWith(
      totalRuns: current.totalRuns + 1,
      clearCount: newClearCount,
      endingsReached: {...current.endingsReached, event.endingName},
      soulCount: current.soulCount + soulGained,
      winsByJob: newWinsByJob,
    );
    updated = _autoUnlockMemories(updated);
    emit(ProgressionLoaded(updated));
    _save(updated);

    // 히든 직업 해금 체크
    _checkAndUnlockJobs(updated, newClearCount, newWinsByJob);
  }

  /// 히든 직업 해금 조건 판정 + 해금 이벤트 발행.
  void _checkAndUnlockJobs(
    MetaSaveData meta,
    int totalWins,
    Map<String, int> winsByJob,
  ) {
    final newUnlocks = JobUnlockChecker.checkNewUnlocks(
      alreadyUnlocked: meta.unlockedHiddenJobIds,
      totalWins: totalWins,
      winsByJob: winsByJob,
    );

    if (newUnlocks.isEmpty) return;

    for (final jobId in newUnlocks) {
      add(UnlockHiddenJob(jobId));
    }
  }

  /// 기억 조각 자동 해금 — MetaSaveData 갱신 후 호출.
  MetaSaveData _autoUnlockMemories(MetaSaveData meta) {
    final newUnlocks = MemoryUnlockChecker.checkNewUnlocks(meta);
    if (newUnlocks.isEmpty) return meta;
    return meta.copyWith(
      unlockedMemoryIds: {...meta.unlockedMemoryIds, ...newUnlocks},
    );
  }

  void _onUnlockMemory(UnlockMemory event, Emitter<ProgressionState> emit) {
    final current = state;
    if (current is! ProgressionLoaded) return;
    if (current.unlockedMemoryIds.contains(event.memoryId)) return;

    final updated = current.meta.copyWith(
      unlockedMemoryIds: {...current.unlockedMemoryIds, event.memoryId},
    );
    emit(ProgressionLoaded(updated));
    _save(updated);
  }

  void _onUnlockHiddenJob(
    UnlockHiddenJob event,
    Emitter<ProgressionState> emit,
  ) {
    final current = state;
    if (current is! ProgressionLoaded) return;
    if (current.unlockedHiddenJobIds.contains(event.jobId)) return;

    // JobPath에서 displayName 조회
    final job = JobPath.values.where((j) => j.id == event.jobId).firstOrNull;
    final displayName = job?.displayName ?? event.jobId;

    GameLogger.info(
      LogSystem.progression,
      'Hidden job unlocked: ${event.jobId} ($displayName)',
    );

    final updated = current.meta.copyWith(
      unlockedHiddenJobIds: {
        ...current.unlockedHiddenJobIds,
        event.jobId,
      },
    );
    emit(ProgressionLoaded(updated));
    _save(updated);

    // GameEventBus로 해금 이벤트 발행 (presentation에서 알림 표시용)
    gameEventBus.emit(JobUnlockEvent(
      jobId: event.jobId,
      displayName: displayName,
    ));
  }

  Future<void> _onResetAll(
    ResetAllProgression event,
    Emitter<ProgressionState> emit,
  ) async {
    if (state is! ProgressionLoaded) return;

    const emptyMeta = MetaSaveData();
    emit(const ProgressionLoaded(emptyMeta));
    await saveManager?.deleteAllData();
    GameLogger.info(LogSystem.progression, 'Full progression reset');
  }

  void _save(MetaSaveData data) {
    saveManager?.saveMeta(data).then((result) {
      if (result is Failure) {
        GameLogger.warning(
          LogSystem.progression,
          'Meta save failed: ${result.error}',
        );
      }
    });
  }

  /// 초기 메타 데이터로 Bloc 상태 설정 (app.dart에서 호출).
  void initialize(MetaSaveData meta) {
    // ignore: invalid_use_of_visible_for_testing_member
    emit(ProgressionLoaded(meta));
  }

  @override
  Future<void> close() {
    _runCompletedSub?.cancel();
    _permadeathSub?.cancel();
    return super.close();
  }
}
