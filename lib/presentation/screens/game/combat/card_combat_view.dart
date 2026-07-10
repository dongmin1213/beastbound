import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/core/models/momentum_types.dart';
import 'package:soul_dungeon/domain/combat/bloc/combat_bloc.dart';
import 'package:soul_dungeon/presentation/screens/game/combat/flame_combat_scene.dart';
import 'package:soul_dungeon/domain/combat/bloc/combat_state.dart';
import 'package:soul_dungeon/domain/momentum/bloc/momentum_bloc.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/theme/floor_theme_visuals.dart';
import 'package:soul_dungeon/presentation/theme/responsive_scale.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/momentum_gauge_widget.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/player_hand_area_widget.dart';
import 'package:soul_dungeon/presentation/widgets/effects/retro_window_frame.dart';

/// 카드 전투 화면의 본문 Column을 GameScreen에서 격리한 위젯.
///
/// 원작에서는 이 트리가 GameScreen.build 내부에 `if (_inCardCombat)` 조건부로
/// 탐색 모드와 뒤섞여 있었다. Reforged 로드맵의 1단계로, 전투 UI를 하나의
/// 독립 위젯으로 추출해 이후 이 위젯의 내부를 Flame `GameWidget` 씬으로
/// 교체할 수 있도록 한다.
///
/// **동작 보존이 목적** — 렌더 결과는 원작과 동일해야 한다.
/// 공유 헬퍼(전투 로그/선택지/액션 버튼)는 GameScreen이 빌드해 주입한다.
class CardCombatView extends StatelessWidget {
  /// 전투 로직 Bloc (GameScreen 소유 인스턴스를 그대로 사용).
  final CombatBloc combatBloc;

  /// 기세 게이지 설정.
  final MomentumConfig momentumConfig;

  /// 층별 테마 비주얼 (프레임/틴트 색상).
  final FloorThemeVisuals floorVisuals;

  /// 현재 층 (기세 게이지는 2층부터 표시).
  final int currentFloor;

  /// 플레이어 직업 ID (Flame 전투 씬의 플레이어 스프라이트용). null이면 실루엣.
  final String? playerJobId;

  /// 전투 액션 버튼(턴 종료/도주) 표시 여부.
  /// = 선택지 표시 중 && 보스 페이즈 전환 아님 && 카드 보상 단계 아님.
  final bool showActionButtons;

  /// 선택지가 방금 선택되어 페이드아웃 중인지 (액션 버튼 무력화용).
  final bool choiceSelected;

  /// 전투 로그 스크롤 영역 (GameScreen의 `_buildTextScrollArea` 결과).
  final Widget textScrollArea;

  /// 하단 카드 선택지 영역 (GameScreen의 `_buildBottomChoiceArea` 결과).
  final Widget bottomChoiceArea;

  /// 전투 액션 버튼 영역 (GameScreen의 `_buildCombatActionButtons` 결과).
  final Widget combatActionButtons;

  /// 멀티몹 타겟 선택 콜백 (원작: `_combatBloc.add(SelectTarget(index))`).
  final void Function(int index) onSelectTarget;

  const CardCombatView({
    super.key,
    required this.combatBloc,
    required this.momentumConfig,
    required this.floorVisuals,
    required this.currentFloor,
    required this.playerJobId,
    required this.showActionButtons,
    required this.choiceSelected,
    required this.textScrollArea,
    required this.bottomChoiceArea,
    required this.combatActionButtons,
    required this.onSelectTarget,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── 상단: 적 영역 (멀티몹 + 의도) ──
        _buildEnemyPanel(context),
        // ── 중단: 전투 로그 텍스트 (스크롤) ──
        _buildCombatLogArea(),
        // ── 하단 상: 플레이어 상태 바 (기세 + HP/AP/덱) ──
        _buildPlayerPanel(context),
        // ── 하단 하: 카드 선택지 + 액션 버튼 ──
        _buildCardPanel(context),
      ],
    );
  }

  /// #1 적 영역 — CombatBloc 상태 구독.
  Widget _buildEnemyPanel(BuildContext context) {
    return BlocBuilder<CombatBloc, CombatState>(
      bloc: combatBloc,
      buildWhen: (prev, curr) {
        if (prev is CardCombatActive && curr is CardCombatActive) {
          return prev.enemies != curr.enemies ||
              prev.selectedTargetIndex != curr.selectedTargetIndex ||
              prev.currentTurn != curr.currentTurn ||
              prev.intentRevealed != curr.intentRevealed;
        }
        return true;
      },
      builder: (context, combatState) {
        if (combatState is CardCombatActive) {
          final enemyPrefix = combatState.isBoss
              ? '☠ '
              : combatState.enemy.isElite
                  ? '★ '
                  : '⚔ ';
          final enemyTitleBarColor = combatState.isBoss
              ? const Color(0xFF2E1A1A)
              : combatState.enemy.isElite
                  ? const Color(0xFF2E2A1A)
                  : floorVisuals.combatUiTint;
          final titleText = combatState.enemies.length > 1
              ? '$enemyPrefix적 (${combatState.enemies.length}체)'
              : '$enemyPrefix${combatState.enemy.name}';
          return BlocBuilder<MomentumBloc, MomentumState>(
            buildWhen: (prev, curr) =>
                prev.runtimeType != curr.runtimeType ||
                (prev is MomentumUpdated &&
                    curr is MomentumUpdated &&
                    prev.tier != curr.tier),
            builder: (context, momentumState) {
              final tier = momentumState is MomentumUpdated
                  ? momentumState.tier
                  : MomentumTier.low;
              final enemyBorderColor = tier == MomentumTier.high
                  ? AppTheme.momentumHighColor
                  : const Color(0xFF555555);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: RetroWindowFrame(
                  title: titleText,
                  borderColor: enemyBorderColor,
                  titleBarColor: enemyTitleBarColor,
                  backgroundColor: floorVisuals.frameBackground,
                  // Reforged 2단계: 정적 초상화(MultiEnemyAreaWidget) 대신
                  // Flame 연출 씬 — 플레이어/적이 공격·피격·사망한다.
                  // (현 단계는 적 패널 밴드에 고정 높이로 배치. 이후 포켓몬식
                  //  씬-지배 구성으로 전환 시 이 SizedBox를 Expanded로 교체.)
                  child: SizedBox(
                    height: 220,
                    child: FlameCombatScene(
                      combatBloc: combatBloc,
                      floorVisuals: floorVisuals,
                      playerJobId: playerJobId,
                    ),
                  ),
                ),
              );
            },
          );
        }
        if (combatState is CardCombatResolved &&
            combatState.outcome == CombatOutcome.victory) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: RetroWindowFrame(
              title: '승리',
              titleBarColor: floorVisuals.combatUiTint,
              backgroundColor: floorVisuals.frameBackground,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Text(
                  '✦ 승리',
                  style: TextStyle(
                    color: AppTheme.titleGold,
                    fontSize: ResponsiveScale.scaleFontSize(context, 14),
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  /// #2 전투 로그 영역 — 스크롤 텍스트 (GameScreen 주입).
  Widget _buildCombatLogArea() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: RetroWindowFrame(
          title: '전투 기록',
          expand: true,
          titleBarColor: floorVisuals.combatUiTint,
          backgroundColor: floorVisuals.frameBackground,
          child: textScrollArea,
        ),
      ),
    );
  }

  /// #3 플레이어 상태 바 — 기세 게이지 + HP/AP/덱.
  Widget _buildPlayerPanel(BuildContext context) {
    return BlocBuilder<CombatBloc, CombatState>(
      bloc: combatBloc,
      buildWhen: (prev, curr) {
        if (prev is CardCombatActive && curr is CardCombatActive) {
          return prev.playerHp != curr.playerHp ||
              prev.playerMaxHp != curr.playerMaxHp ||
              prev.playerBlock != curr.playerBlock ||
              prev.actionPoints != curr.actionPoints ||
              prev.maxActionPoints != curr.maxActionPoints ||
              prev.currentTurn != curr.currentTurn ||
              prev.playerStatuses != curr.playerStatuses ||
              prev.deckState != curr.deckState;
        }
        return true;
      },
      builder: (context, combatState) {
        if (combatState is CardCombatActive) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: RetroWindowFrame(
              title: '손패',
              titleBarColor: floorVisuals.combatUiTint,
              backgroundColor: floorVisuals.frameBackground,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 기세 게이지 (HP 바 위) — O-03: 2층부터 표시
                  if (currentFloor >= 2)
                    BlocBuilder<MomentumBloc, MomentumState>(
                      buildWhen: (prev, curr) =>
                          prev.runtimeType != curr.runtimeType ||
                          (prev is MomentumUpdated &&
                              curr is MomentumUpdated &&
                              (prev.value != curr.value ||
                                  prev.tier != curr.tier)),
                      builder: (context, state) {
                        // 실제 CombatBloc의 maxAP를 표시 (MomentumBloc 기준 재계산 X)
                        // → 턴 중 기세가 올라도 AP 표시가 실제 값과 불일치하지 않음
                        final actualAp = combatState.maxActionPoints;
                        return switch (state) {
                          MomentumInitial() => MomentumGaugeWidget(
                              momentum: 0,
                              config: momentumConfig,
                              apForCurrentTier: actualAp,
                            ),
                          MomentumUpdated(
                            :final value,
                            :final lastDelta,
                          ) =>
                            MomentumGaugeWidget(
                              momentum: value,
                              lastDelta: lastDelta,
                              config: momentumConfig,
                              apForCurrentTier: actualAp,
                            ),
                        };
                      },
                    ),
                  PlayerHandAreaWidget(
                    playerHp: combatState.playerHp,
                    playerMaxHp: combatState.playerMaxHp,
                    playerBlock: combatState.playerBlock,
                    actionPoints: combatState.actionPoints,
                    maxActionPoints: combatState.maxActionPoints,
                    currentTurn: combatState.currentTurn,
                    drawPileCount: combatState.deckState.drawPileCount,
                    discardPileCount: combatState.deckState.discardPileCount,
                    exhaustPileCount: combatState.deckState.exhaustPileCount,
                    playerStatuses: combatState.playerStatuses,
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  /// #4 카드 선택지 + 액션 버튼.
  Widget _buildCardPanel(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: RetroWindowFrame(
        title: '카드',
        titleBarColor: floorVisuals.combatUiTint,
        backgroundColor: floorVisuals.frameBackground,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            bottomChoiceArea,
            if (showActionButtons)
              AnimatedOpacity(
                opacity: choiceSelected ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: IgnorePointer(
                  ignoring: choiceSelected,
                  child: combatActionButtons,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
