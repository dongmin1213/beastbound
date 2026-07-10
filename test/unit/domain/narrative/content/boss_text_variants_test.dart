import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/narrative/content/boss_text_variants.dart';
import 'package:soul_dungeon/core/models/boss_choice.dart';

void main() {
  group('BossTextVariants', () {
    test('returns generic text for all 5 bosses x 3 choices', () {
      const bosses = [
        'boss_slime_king',
        'boss_spider_lord',
        'boss_orc_general',
        'boss_vampire_lord',
        'boss_dungeon_master',
      ];
      for (final boss in bosses) {
        for (final choice in BossChoiceType.values) {
          final text = BossTextVariants.choiceResultText(boss, choice);
          expect(text, isNotEmpty, reason: '$boss + ${choice.name}');
        }
      }
    });

    test('returns job-specific text for warrior', () {
      final text = BossTextVariants.choiceResultText(
        'boss_slime_king',
        BossChoiceType.slay,
        jobId: 'warrior',
      );
      expect(text, contains('전사'));
    });

    test('returns job-specific text for sage', () {
      final text = BossTextVariants.choiceResultText(
        'boss_spider_lord',
        BossChoiceType.liberate,
        jobId: 'sage',
      );
      expect(text, contains('현자'));
    });

    test('returns job-specific text for assassin', () {
      final text = BossTextVariants.choiceResultText(
        'boss_slime_king',
        BossChoiceType.slay,
        jobId: 'assassin',
      );
      expect(text, contains('독'));
    });

    test('falls back to generic for unmatched job', () {
      final generic = BossTextVariants.choiceResultText(
        'boss_slime_king',
        BossChoiceType.liberate,
      );
      final withJob = BossTextVariants.choiceResultText(
        'boss_slime_king',
        BossChoiceType.liberate,
        jobId: 'guardian',
      );
      expect(withJob, generic);
    });

    test('falls back to default for unknown boss', () {
      final text = BossTextVariants.choiceResultText(
        'boss_unknown',
        BossChoiceType.slay,
      );
      expect(text, contains('처치'));
    });
  });
}
