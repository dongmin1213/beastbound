import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/narrative/content/boss_text_variants.dart';
import 'package:soul_dungeon/core/models/boss_choice.dart';

void main() {
  group('BossTextVariants', () {
    test('returns generic text for all 5 bosses x all choices', () {
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

    test('jobId는 무시된다 (직업 개념 폐기) — generic과 동일', () {
      final generic = BossTextVariants.choiceResultText(
        'boss_slime_king',
        BossChoiceType.liberate,
      );
      final withJob = BossTextVariants.choiceResultText(
        'boss_slime_king',
        BossChoiceType.liberate,
        jobId: 'warrior',
      );
      expect(withJob, generic);
    });

    test('falls back to default for unknown boss', () {
      final text = BossTextVariants.choiceResultText(
        'boss_unknown',
        BossChoiceType.slay,
      );
      expect(text, contains('쓰러뜨렸다'));
    });
  });
}
