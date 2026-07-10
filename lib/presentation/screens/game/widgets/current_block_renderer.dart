import 'package:flutter/material.dart';
import 'package:soul_dungeon/presentation/screens/game/widgets/combat_result_renderer.dart';
import 'package:soul_dungeon/presentation/screens/game/widgets/completed_block_renderer.dart';
import 'package:soul_dungeon/presentation/screens/game/widgets/text_block_style.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_data.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_models.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_outcome_widget.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_preview_widget.dart';
import 'package:soul_dungeon/presentation/widgets/text_engine/typewriter_widget.dart';

/// 현재 블록 렌더링 — GameScreen에서 추출 (Step 6).
///
/// TextBlockType에 따라 적절한 위젯으로 렌더링한다.
class CurrentBlockRenderer extends StatelessWidget {
  final TextBlockData blockData;
  final int blockIndex;
  final GlobalKey<TypewriterWidgetState> typewriterKey;
  final TextSpeed speed;
  final int charsPerSecondSlow;
  final int charsPerSecondNormal;
  final int charsPerSecondFast;
  final VoidCallback onComplete;

  const CurrentBlockRenderer({
    super.key,
    required this.blockData,
    required this.blockIndex,
    required this.typewriterKey,
    required this.speed,
    required this.charsPerSecondSlow,
    required this.charsPerSecondNormal,
    required this.charsPerSecondFast,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return switch (blockData.blockType) {
      TextBlockType.turnDivider => _buildTurnDivider(context),
      TextBlockType.combatPreview => _buildCombatPreview(),
      TextBlockType.combatResult => CombatResultRenderer.build(
          context,
          blockData.text,
          blockData.metadata,
        ),
      TextBlockType.combatOutcome => CombatOutcomeWidget(
          blockData: blockData,
        ),
      TextBlockType.environmentNarration ||
      TextBlockType.environmentDiscovery =>
        _buildEnvironmentNarration(context),
      TextBlockType.dispositionHint => _buildDispositionHint(context),
      TextBlockType.classChange => _buildClassChange(context),
      TextBlockType.normal => _buildNormal(context),
    };
  }

  Widget _buildClassChange(BuildContext context) {
    return TypewriterWidget(
      key: typewriterKey,
      text: blockData.text,
      style: TextBlockStyle.classChange(context),
      speed: speed,
      charsPerSecondSlow: charsPerSecondSlow,
      charsPerSecondNormal: charsPerSecondNormal,
      charsPerSecondFast: charsPerSecondFast,
      onComplete: onComplete,
    );
  }

  Widget _buildDispositionHint(BuildContext context) {
    return TypewriterWidget(
      key: typewriterKey,
      text: blockData.text,
      style: TextBlockStyle.dispositionHint(context),
      speed: speed,
      charsPerSecondSlow: charsPerSecondSlow,
      charsPerSecondNormal: charsPerSecondNormal,
      charsPerSecondFast: charsPerSecondFast,
      onComplete: onComplete,
    );
  }

  Widget _buildNormal(BuildContext context) {
    // 런 요약은 타이핑 없이 즉시 스타일 적용
    final isRunSummary = blockData.metadata?['runSummary'] == true;
    if (isRunSummary) {
      WidgetsBinding.instance.addPostFrameCallback((_) => onComplete());
      return CompletedBlockRenderer.build(
        context,
        CompletedBlock(
          text: blockData.text,
          blockType: blockData.blockType,
          metadata: blockData.metadata,
        ),
      );
    }

    final isEliteWarning = blockData.metadata?['eliteWarning'] == true;
    final style = isEliteWarning
        ? TextBlockStyle.eliteWarning(context)
        : Theme.of(context).textTheme.bodyLarge;

    return TypewriterWidget(
      key: typewriterKey,
      text: blockData.text,
      style: style,
      speed: speed,
      charsPerSecondSlow: charsPerSecondSlow,
      charsPerSecondNormal: charsPerSecondNormal,
      charsPerSecondFast: charsPerSecondFast,
      onComplete: onComplete,
    );
  }

  Widget _buildTurnDivider(BuildContext context) {
    return Center(
      child: Text(
        blockData.text,
        style: TextBlockStyle.turnDivider(context),
      ),
    );
  }

  Widget _buildCombatPreview() {
    final actionTypeName = blockData.metadata?['actionType'] ?? 'attack';
    final actionType = EnemyActionType.values.firstWhere(
      (e) => e.name == actionTypeName,
      orElse: () => EnemyActionType.attack,
    );

    return CombatPreviewWidget(
      key: ValueKey('combat_preview_$blockIndex'),
      action: EnemyAction(
        type: actionType,
        previewText: blockData.metadata?['previewText'] ?? blockData.text,
      ),
    );
  }

  Widget _buildEnvironmentNarration(BuildContext context) {
    return Container(
      decoration: TextBlockStyle.environmentBorder,
      padding: TextBlockStyle.environmentPadding,
      child: TypewriterWidget(
        key: typewriterKey,
        text: blockData.text,
        style: TextBlockStyle.environment(context),
        speed: speed,
        charsPerSecondSlow: charsPerSecondSlow,
        charsPerSecondNormal: charsPerSecondNormal,
        charsPerSecondFast: charsPerSecondFast,
        onComplete: onComplete,
      ),
    );
  }
}
