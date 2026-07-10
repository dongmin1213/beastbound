import 'package:soul_dungeon/domain/combat/bloc/combat_bloc.dart';
import 'package:soul_dungeon/domain/combat/bloc/combat_event.dart';
import 'package:soul_dungeon/domain/combat/bloc/combat_state.dart';
import 'package:soul_dungeon/domain/combat/logic/action_interaction.dart';
import 'package:soul_dungeon/domain/combat/logic/special_action_resolver.dart';
import 'package:soul_dungeon/domain/combat/models/combat_turn_result.dart';
import 'package:soul_dungeon/domain/momentum/bloc/momentum_bloc.dart';
import 'package:soul_dungeon/core/models/momentum_types.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_data.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_flow_manager.dart';

/// 전투 행동 처리 — CombatBloc에 행동 이벤트 발행 + 결과 텍스트 블록 생성.
class CombatActionProcessor {
  final CombatBloc _combatBloc;

  CombatActionProcessor({required CombatBloc combatBloc})
      : _combatBloc = combatBloc;

  /// CombatBloc에 행동 이벤트를 발행하고 결과 텍스트 블록을 생성.
  Future<List<TextBlockData>> process(
    ChoiceData choice, {
    required MomentumBloc momentumBloc,
  }) async {
    final actionType = ActionType.values.firstWhere(
      (e) => e.name == choice.actionType,
      orElse: () => ActionType.attack,
    );

    // 기세 티어 스냅샷 (행동 전)
    final momentumState = momentumBloc.state;
    final currentTier = switch (momentumState) {
      MomentumUpdated(:final tier) => tier,
      MomentumInitial() => MomentumTier.low,
    };

    // 기세 변동 → MomentumBloc
    momentumBloc.add(ActionPerformed(actionType));

    // 환경 해금 상태 스냅샷 (행동 전)
    final currentState = _combatBloc.state;
    if (currentState is! CombatActive) return [];
    final wasEnvironmentUnlocked = currentState.environmentUnlocked;

    // CombatBloc 이벤트 발행 + 결과 대기
    final nextStateFuture = _combatBloc.stream.first;
    if (actionType == ActionType.special) {
      final specialType = choice.id.replaceFirst('special_', '');
      _combatBloc.add(SelectSpecialAction(
        specialType,
        currentMomentumTier: currentTier,
      ));
    } else if (actionType == ActionType.environment) {
      final clueId = choice.id.replaceFirst('env_', '');
      _combatBloc.add(SelectEnvironmentAction(
        clueId,
        currentMomentumTier: currentTier,
      ));
    } else {
      _combatBloc.add(SelectAction(
        actionType,
        currentMomentumTier: currentTier,
      ));
    }
    final CombatState newState;
    try {
      newState = await nextStateFuture;
    } on StateError {
      return [];
    }

    // CombatBloc 결과 읽기
    if (newState is! CombatActive) return [];
    final combatActive = newState;
    final turnResult = combatActive.lastTurnResult;
    if (turnResult == null) return [];

    // 결과 텍스트 블록 생성
    return _buildTurnResultBlocks(
      turnResult,
      actionType,
      combatActive,
      choice: choice,
      wasEnvironmentUnlocked: wasEnvironmentUnlocked,
    );
  }

  /// CombatTurnResult로부터 결과 텍스트 블록 목록 생성.
  List<TextBlockData> _buildTurnResultBlocks(
    CombatTurnResult turnResult,
    ActionType actionType,
    CombatActive combatState, {
    required ChoiceData choice,
    required bool wasEnvironmentUnlocked,
  }) {
    final resultBlocks = <TextBlockData>[];

    if (actionType == ActionType.special) {
      // 특수 행동: 직업별 결과 텍스트
      final specialType = choice.id.replaceFirst('special_', '');
      final resultText =
          SpecialActionResolver.getResultText(specialType, turnResult.enemyAction);
      final prefix =
          ActionInteraction.getResultPrefix(turnResult.actionResult);

      final enrichedMetadata = <String, dynamic>{
        'actionResult': turnResult.actionResult.name,
        'playerAction': ActionType.special.name,
        'specialActionType': specialType,
      };
      if (turnResult.tierEffect?.effectText != null) {
        enrichedMetadata['tierEffectText'] = turnResult.tierEffect!.effectText;
        enrichedMetadata['tierEffectLevel'] =
            turnResult.tierEffect!.effectLevel.name;
      }

      resultBlocks.add(TextBlockData(
        text: '$prefix$resultText',
        blockType: TextBlockType.combatResult,
        metadata: enrichedMetadata,
      ));
    } else if (actionType == ActionType.environment) {
      // 환경 행동: clue 기반 결과
      final clueId = choice.id.replaceFirst('env_', '');
      final clue = combatState.discoveredClues
          .where((c) => c.id == clueId)
          .firstOrNull;
      if (clue == null) return [];

      final enrichedMetadata = <String, dynamic>{
        'actionResult': turnResult.actionResult.name,
        'playerAction': ActionType.environment.name,
      };
      if (turnResult.tierEffect?.effectText != null) {
        enrichedMetadata['tierEffectText'] = turnResult.tierEffect!.effectText;
        enrichedMetadata['tierEffectLevel'] =
            turnResult.tierEffect!.effectLevel.name;
      }

      resultBlocks.add(TextBlockData(
        text: '✦ ${clue.actionHint}를 활용했다!',
        blockType: TextBlockType.combatResult,
        metadata: enrichedMetadata,
      ));
    } else {
      // 일반 행동: CombatFlowManager 기반 결과 텍스트 생성
      final resultBlock = CombatFlowManager.resolveActionResult(
        playerAction: actionType,
        enemyAction: turnResult.enemyAction,
      );

      final enrichedMetadata =
          Map<String, dynamic>.from(resultBlock.metadata ?? {});
      if (turnResult.tierEffect?.effectText != null) {
        enrichedMetadata['tierEffectText'] = turnResult.tierEffect!.effectText;
        enrichedMetadata['tierEffectLevel'] =
            turnResult.tierEffect!.effectLevel.name;
      }

      resultBlocks.add(TextBlockData(
        text: resultBlock.text,
        blockType: resultBlock.blockType,
        metadata: enrichedMetadata,
      ));

      // 관찰 행동 후 환경 발견 블록 삽입
      if (actionType == ActionType.observe) {
        if (!wasEnvironmentUnlocked && combatState.environmentUnlocked) {
          if (combatState.allTurnsCompleted) {
            // 마지막 턴 최초 관찰: 힌트를 활용할 기회 없음
            resultBlocks.add(const TextBlockData(
              text: '주변을 주의 깊게 살피지만... 활용할 기회는 이미 지나갔다.',
              blockType: TextBlockType.environmentDiscovery,
            ));
          } else {
            // 최초 관찰: 환경 단서 발견
            resultBlocks.add(const TextBlockData(
              text: '주변을 주의 깊게 살핀다...',
              blockType: TextBlockType.environmentDiscovery,
            ));
            for (final clue in combatState.discoveredClues) {
              resultBlocks.add(TextBlockData(
                text: '💡 ${clue.actionHint}',
                blockType: TextBlockType.environmentDiscovery,
              ));
            }
          }
        } else if (combatState.environmentUnlocked) {
          // 재관찰: 기세 전환 보너스 암시 텍스트
          resultBlocks.add(const TextBlockData(
            text:
                '주변을 다시 살피지만 새로운 단서는 없다. 하지만 집중력이 높아진다.',
            blockType: TextBlockType.environmentDiscovery,
          ));
        }
      }
    }

    return resultBlocks;
  }
}
