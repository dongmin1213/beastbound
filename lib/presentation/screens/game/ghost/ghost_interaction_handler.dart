import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/core/events/ghost_encountered_event.dart';
import 'package:soul_dungeon/domain/progression/ghost/ghost_npc_data.dart';
import 'package:soul_dungeon/domain/progression/ghost/ghost_reaction.dart';
import 'package:soul_dungeon/presentation/screens/game/ghost/ghost_text_builder.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_data.dart';

/// 유령 NPC 상호작용 핸들러 (presentation 레이어).
///
/// 유령 만남 → 텍스트 + 선택지 표시, 선택 결과 처리.
class GhostInteractionHandler {
  final GameEventBus gameEventBus;
  final void Function(
    List<TextBlockData> blocks, {
    bool endCombat,
    bool resetMomentum,
  }) setTextBlockData;

  GhostInteractionHandler({
    required this.gameEventBus,
    required this.setTextBlockData,
  });

  /// 유령 만남 표시.
  void showGhostEncounter(GhostNpcData ghost, GhostReactionLevel level) {
    final intro = GhostTextBuilder.introText(ghost);
    final reaction = GhostTextBuilder.reactionText(level, ghost.jobId);
    final choices = GhostTextBuilder.ghostChoices(level);

    gameEventBus.emit(GhostEncounteredEvent(
      ghostJobId: ghost.jobId,
      ghostDeathFloor: ghost.deathFloor,
      reactionLevel: level.name,
    ));

    setTextBlockData(
      [
        TextBlockData(text: intro),
        TextBlockData(text: reaction, choices: choices),
      ],
      endCombat: false,
      resetMomentum: false,
    );
  }

  /// 유령 선택지 결과 처리.
  void handleGhostChoice(ChoiceData choice) {
    final resultText = switch (choice.id) {
      'ghost_talk' => '유령과 이야기를 나눴다. 지난 여정의 기억이 스쳐 지나간다.',
      'ghost_trade' => '유령이 가진 지식을 나눠주었다. 어딘가 익숙한 감각이 돌아온다.',
      'ghost_farewell' => '유령에게 작별을 고했다. 희미한 미소를 남기며 사라진다.',
      'ghost_approach' => '조심스럽게 다가갔다. 유령이 잠시 당신을 바라보다 사라진다.',
      'ghost_ignore' => '유령을 무시하고 지나갔다. 뒤에서 희미한 한숨 소리가 들린다.',
      _ => '유령이 사라졌다.',
    };

    setTextBlockData(
      [
        TextBlockData(
          text: resultText,
          choices: const [
            ChoiceData(
              id: 'ghost_continue',
              text: '떠난다',
              resultTextBlocks: ['유령의 잔상이 사라졌다.'],
            ),
          ],
        ),
      ],
      endCombat: false,
      resetMomentum: false,
    );
  }
}
