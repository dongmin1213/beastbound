import 'dart:async';

import 'package:flutter/material.dart';
import 'package:soul_dungeon/core/events/combat_reward_event.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/core/events/gold_gained_event.dart';
import 'package:soul_dungeon/core/events/momentum_gain_event.dart';
import 'package:soul_dungeon/domain/build/data/relic_pool.dart';
import 'package:soul_dungeon/domain/run/run_bloc.dart';
import 'package:soul_dungeon/domain/run/run_event.dart';
import 'package:soul_dungeon/core/models/player_run_state.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_data.dart';

/// 플레이어 런 상태(HP, 골드) + completedBlocks 중앙 관리.
///
/// GameScreen에서 분산되어 있던 PlayerRunState 변경, RunBloc 동기화,
/// completedBlocks 소유권을 단일 컨트롤러로 통합.
class GameRunController {
  PlayerRunState playerRunState;
  final RunBloc runBloc;
  final GameEventBus gameEventBus;
  final List<CompletedBlock> completedBlocks = [];
  final List<CompletedBlock> _pendingEventResultBlocks = [];
  final VoidCallback onStateChanged;
  final bool Function() isScrolledUp;
  final VoidCallback scrollToBottom;

  StreamSubscription<CombatRewardEvent>? _combatRewardSub;

  GameRunController({
    required PlayerRunState initialState,
    required this.runBloc,
    required this.gameEventBus,
    required this.onStateChanged,
    required this.isScrolledUp,
    required this.scrollToBottom,
  }) : playerRunState = initialState;

  bool get isPermadeath => playerRunState.currentHp <= 0;

  /// CombatRewardEvent 구독 — 전투 승리 시 금화 적립.
  void initRewardSubscription(bool Function() isMounted) {
    _combatRewardSub?.cancel();
    _combatRewardSub = gameEventBus.on<CombatRewardEvent>().listen((event) {
      if (!isMounted()) return;
      final amount = event.goldAmount;
      playerRunState = playerRunState.copyWith(
        gold: playerRunState.gold + amount,
      );
      onStateChanged();
      runBloc.add(GainGold(amount));
      gameEventBus.emit(GoldGainedEvent(
        amount: amount,
        totalGold: playerRunState.gold,
      ));
      appendFeedbackText('$amount 골드 획득!');

      // 전투 승리 시 유물 트리거 (골드 보너스)
      final relicMessages = _applyRelicTrigger('combatEnd');
      for (final msg in relicMessages) {
        appendFeedbackText(msg);
      }
    });
  }

  /// 골드 직접 설정 — 상점/NPC 종료 시 잔여 금화 동기화.
  void setGold(int gold) {
    playerRunState = playerRunState.copyWith(gold: gold);
    runBloc.add(SetGold(gold));
  }

  /// RunBloc에 전체 상태 동기화.
  void syncToRunBloc() {
    runBloc.add(SetPlayerRunState(playerRunState));
  }

  /// 방 진입 시 호출 — 유물 트리거.
  ///
  /// 반환값: 유물 효과 피드백 문자열 목록 (UI에 표시용).
  List<String> onRoomEntered() {
    return _applyRelicTrigger('roomEnter');
  }

  /// 이벤트 결과 텍스트를 pending 큐에 저장 — 다음 setTextBlockData 시 flush.
  ///
  /// CompleteRoom 후 경로 선택으로 즉시 전환되므로, 이벤트 결과를
  /// 다음 화면(갈림길) 상단에 표시한다.
  void appendEventResultText(String text) {
    _pendingEventResultBlocks.add(CompletedBlock(text: text));
  }

  /// 다음 층 진행 — 보스 승리 후 호출.
  void advanceFloor() {
    final current = playerRunState.currentFloor;
    // 최종 층 이상에서는 진행하지 않음 (엔딩 처리)
    if (current >= 5) return;
    playerRunState = playerRunState.copyWith(
      currentFloor: current + 1,
      completedFloors: {...playerRunState.completedFloors, current},
    );
    runBloc.add(const AdvanceFloor());

    // 층 전환 시 유물 트리거 (HP 회복)
    final messages = _applyRelicTrigger('floorTransition');
    for (final msg in messages) {
      appendFeedbackText(msg);
    }
  }

  /// 런 리셋 — 퍼마데스 후 재시작.
  void resetRun(int maxHp) {
    playerRunState = PlayerRunState.initial(maxHp: maxHp);
    _pendingEventResultBlocks.clear();
    runBloc.add(ResetRun(maxHp: maxHp));
  }

  /// completedBlocks 초기화 — setTextBlockData 전용.
  ///
  /// pending된 이벤트 결과 텍스트가 있으면 clear 후 flush하여
  /// 다음 화면 상단에 표시되도록 한다.
  void clearCompletedBlocks() {
    completedBlocks.clear();
    // 이벤트 결과 텍스트 flush (1회성 — 생존 불필요)
    if (_pendingEventResultBlocks.isNotEmpty) {
      completedBlocks.addAll(_pendingEventResultBlocks);
      _pendingEventResultBlocks.clear();
    }
  }

  /// 피드백 텍스트를 completedBlocks에 추가 (골드 획득, 구매 등).
  void appendFeedbackText(String text) {
    _appendBlock(text);
  }

  /// completedBlocks에 블록 추가 + UI 갱신 + 스크롤.
  void _appendBlock(String text, {TextBlockType blockType = TextBlockType.normal}) {
    completedBlocks.add(CompletedBlock(text: text, blockType: blockType));
    onStateChanged();
    if (!isScrolledUp()) {
      scrollToBottom();
    }
  }

  /// 소유 유물 중 해당 트리거 조건의 효과 적용.
  ///
  /// 반환값: 유물 효과 피드백 문자열 목록.
  List<String> _applyRelicTrigger(String conditionType) {
    final relics = RelicPool.resolveIds(playerRunState.ownedRelicIds);
    final messages = <String>[];
    for (final relic in relics.where((r) => r.conditionType == conditionType)) {
      switch (relic.passiveEffect) {
        case 'hpRegen':
          final heal = relic.effectValue;
          final newHp =
              (playerRunState.currentHp + heal).clamp(0, playerRunState.maxHp);
          final actual = newHp - playerRunState.currentHp;
          if (actual > 0) {
            playerRunState = playerRunState.copyWith(currentHp: newHp);
            runBloc.add(ChangeHp(actual));
            messages.add('${relic.name}: +$actual HP');
          }
        case 'goldBonus':
          final gold = relic.effectValue;
          playerRunState = playerRunState.copyWith(
            gold: playerRunState.gold + gold,
          );
          runBloc.add(GainGold(gold));
          gameEventBus.emit(GoldGainedEvent(
            amount: gold,
            totalGold: playerRunState.gold,
          ));
          messages.add('${relic.name}: +$gold 골드');
        case 'momentumGain':
          gameEventBus.emit(MomentumGainEvent(amount: relic.effectValue));
          messages.add('${relic.name}: 야성 +${relic.effectValue}');
        case 'maxHpPerFloor':
          final bonus = relic.effectValue;
          playerRunState = playerRunState.copyWith(
            maxHp: playerRunState.maxHp + bonus,
            currentHp: playerRunState.currentHp + bonus,
          );
          runBloc.add(ChangeMaxHp(bonus));
          runBloc.add(ChangeHp(bonus));
          messages.add('${relic.name}: 최대HP +$bonus');
      }
    }
    return messages;
  }

  void dispose() {
    _combatRewardSub?.cancel();
  }
}
