import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/core/events/ghost_encountered_event.dart';
import 'package:soul_dungeon/domain/progression/ghost/ghost_npc_data.dart';
import 'package:soul_dungeon/domain/progression/ghost/ghost_reaction.dart';
import 'package:soul_dungeon/presentation/screens/game/ghost/ghost_interaction_handler.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_data.dart';

void main() {
  group('GhostInteractionHandler', () {
    late GameEventBus gameEventBus;
    late List<List<TextBlockData>> capturedBlocks;
    late List<Map<String, bool>> capturedOptions;
    late GhostInteractionHandler handler;

    setUp(() {
      gameEventBus = GameEventBus();
      capturedBlocks = [];
      capturedOptions = [];

      handler = GhostInteractionHandler(
        gameEventBus: gameEventBus,
        setTextBlockData: (blocks, {bool endCombat = false, bool resetMomentum = false}) {
          capturedBlocks.add(blocks);
          capturedOptions.add({
            'endCombat': endCombat,
            'resetMomentum': resetMomentum,
          });
        },
      );
    });

    tearDown(() {
      gameEventBus.dispose();
    });

    test('showGhostEncounter calls setTextBlockData with intro and reaction', () {
      const ghost = GhostNpcData(
        deathFloor: 3,
        jobId: 'warrior',
        dispositionSnapshot: {},
        runNumber: 2,
      );

      handler.showGhostEncounter(ghost, GhostReactionLevel.familiar);

      expect(capturedBlocks.length, 1);
      expect(capturedBlocks[0].length, 2);
      expect(capturedBlocks[0][0].text, contains('전사'));
      expect(capturedBlocks[0][1].text, contains('반갑'));
      expect(capturedBlocks[0][1].hasChoices, true);
      expect(capturedOptions[0]['endCombat'], false);
      expect(capturedOptions[0]['resetMomentum'], false);
    });

    test('showGhostEncounter emits GhostEncounteredEvent', () async {
      const ghost = GhostNpcData(
        deathFloor: 5,
        jobId: 'sage',
        dispositionSnapshot: {},
        runNumber: 1,
      );

      final eventFuture = gameEventBus.on<GhostEncounteredEvent>().first;
      handler.showGhostEncounter(ghost, GhostReactionLevel.curious);
      final event = await eventFuture;

      expect(event.ghostJobId, 'sage');
      expect(event.ghostDeathFloor, 5);
      expect(event.reactionLevel, 'curious');
    });

    test('handleGhostChoice returns talk result text', () {
      const choice = ChoiceData(
        id: 'ghost_talk',
        text: '이야기를 나눈다',
        resultTextBlocks: [],
      );
      handler.handleGhostChoice(choice);

      expect(capturedBlocks.length, 1);
      expect(capturedBlocks[0][0].text, contains('이야기'));
    });

    test('handleGhostChoice returns trade result text', () {
      const choice = ChoiceData(
        id: 'ghost_trade',
        text: '지식을 나눠받는다',
        resultTextBlocks: [],
      );
      handler.handleGhostChoice(choice);

      expect(capturedBlocks[0][0].text, contains('지식'));
    });

    test('handleGhostChoice returns farewell result text', () {
      const choice = ChoiceData(
        id: 'ghost_farewell',
        text: '작별을 고한다',
        resultTextBlocks: [],
      );
      handler.handleGhostChoice(choice);

      expect(capturedBlocks[0][0].text, contains('작별'));
    });

    test('handleGhostChoice returns approach result text', () {
      const choice = ChoiceData(
        id: 'ghost_approach',
        text: '조심스럽게 다가간다',
        resultTextBlocks: [],
      );
      handler.handleGhostChoice(choice);

      expect(capturedBlocks[0][0].text, contains('다가갔다'));
    });

    test('handleGhostChoice returns ignore result text', () {
      const choice = ChoiceData(
        id: 'ghost_ignore',
        text: '무시하고 지나간다',
        resultTextBlocks: [],
      );
      handler.handleGhostChoice(choice);

      expect(capturedBlocks[0][0].text, contains('무시'));
    });

    test('handleGhostChoice returns default for unknown id', () {
      const choice = ChoiceData(
        id: 'ghost_unknown',
        text: '알 수 없는 선택',
        resultTextBlocks: [],
      );
      handler.handleGhostChoice(choice);

      expect(capturedBlocks[0][0].text, contains('사라졌다'));
    });
  });
}
