import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/progression/ghost/ghost_npc_data.dart';
import 'package:soul_dungeon/domain/progression/ghost/ghost_reaction.dart';
import 'package:soul_dungeon/presentation/screens/game/ghost/ghost_text_builder.dart';

void main() {
  group('GhostTextBuilder', () {
    group('introText', () {
      test('contains job display name', () {
        const ghost = GhostNpcData(
          deathFloor: 3,
          jobId: 'warrior',
          dispositionSnapshot: {},
          runNumber: 2,
        );
        final text = GhostTextBuilder.introText(ghost);
        expect(text, contains('전사'));
        expect(text, contains('3층'));
        expect(text, contains('2번째'));
      });

      test('contains sage job name', () {
        const ghost = GhostNpcData(
          deathFloor: 5,
          jobId: 'sage',
          dispositionSnapshot: {},
          runNumber: 1,
        );
        final text = GhostTextBuilder.introText(ghost);
        expect(text, contains('현자'));
      });

      test('uses raw jobId for unknown job', () {
        const ghost = GhostNpcData(
          deathFloor: 1,
          jobId: 'unknown_job',
          dispositionSnapshot: {},
          runNumber: 1,
        );
        final text = GhostTextBuilder.introText(ghost);
        expect(text, contains('unknown_job'));
      });
    });

    group('reactionText', () {
      test('familiar level has warm tone', () {
        final text = GhostTextBuilder.reactionText(
          GhostReactionLevel.familiar,
          'warrior',
        );
        expect(text, contains('반갑'));
        expect(text, contains('전사'));
      });

      test('curious level has neutral tone', () {
        final text = GhostTextBuilder.reactionText(
          GhostReactionLevel.curious,
          'sage',
        );
        expect(text, contains('흥미'));
        expect(text, contains('현자'));
      });

      test('distant level has cold tone', () {
        final text = GhostTextBuilder.reactionText(
          GhostReactionLevel.distant,
          'assassin',
        );
        expect(text, contains('냉담'));
        expect(text, contains('암살자'));
      });

      test('different levels produce different text', () {
        final familiar = GhostTextBuilder.reactionText(
          GhostReactionLevel.familiar,
          'warrior',
        );
        final curious = GhostTextBuilder.reactionText(
          GhostReactionLevel.curious,
          'warrior',
        );
        final distant = GhostTextBuilder.reactionText(
          GhostReactionLevel.distant,
          'warrior',
        );
        expect(familiar, isNot(curious));
        expect(curious, isNot(distant));
        expect(familiar, isNot(distant));
      });
    });

    group('ghostChoices', () {
      test('familiar returns 4 choices (talk, trade, fight, farewell)', () {
        final choices =
            GhostTextBuilder.ghostChoices(GhostReactionLevel.familiar);
        expect(choices.length, 4);
        expect(choices[0].id, 'ghost_talk');
        expect(choices[1].id, 'ghost_trade');
        expect(choices[2].id, 'ghost_fight');
        expect(choices[3].id, 'ghost_farewell');
      });

      test('curious returns 3 choices (talk, fight, farewell)', () {
        final choices =
            GhostTextBuilder.ghostChoices(GhostReactionLevel.curious);
        expect(choices.length, 3);
        expect(choices[0].id, 'ghost_talk');
        expect(choices[1].id, 'ghost_fight');
        expect(choices[2].id, 'ghost_farewell');
      });

      test('distant returns 3 choices (approach, fight, ignore)', () {
        final choices =
            GhostTextBuilder.ghostChoices(GhostReactionLevel.distant);
        expect(choices.length, 3);
        expect(choices[0].id, 'ghost_approach');
        expect(choices[1].id, 'ghost_fight');
        expect(choices[2].id, 'ghost_ignore');
      });

      test('all choices have ghost_ prefix IDs', () {
        for (final level in GhostReactionLevel.values) {
          final choices = GhostTextBuilder.ghostChoices(level);
          for (final choice in choices) {
            expect(
              choice.id.startsWith('ghost_'),
              true,
              reason: '${choice.id} should start with ghost_',
            );
          }
        }
      });
    });
  });
}
