import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/ending/ending_resolver.dart';
import 'package:soul_dungeon/domain/ending/ending_types.dart';
import 'package:soul_dungeon/core/models/boss_choice.dart';

void main() {
  // Helper: create boss choices that meet hidden ending condition
  // (5 bosses, all 3 types present, max 2 of any type)
  List<BossChoice> hiddenChoices() => [
        const BossChoice(floor: 1, bossId: 'b1', choiceType: BossChoiceType.slay),
        const BossChoice(floor: 2, bossId: 'b2', choiceType: BossChoiceType.liberate),
        const BossChoice(floor: 3, bossId: 'b3', choiceType: BossChoiceType.coexist),
        const BossChoice(floor: 4, bossId: 'b4', choiceType: BossChoiceType.slay),
        const BossChoice(floor: 5, bossId: 'b5', choiceType: BossChoiceType.liberate),
      ];

  group('EndingResolver transcend ending', () {
    test('hidden condition + hiddenJob + memory 12 → transcend', () {
      expect(
        EndingResolver.resolve(hiddenChoices(), isHiddenJob: true, unlockedMemoryCount: 12),
        EndingType.transcend,
      );
    });

    test('hidden condition + hiddenJob + memory 15 → transcend', () {
      expect(
        EndingResolver.resolve(hiddenChoices(), isHiddenJob: true, unlockedMemoryCount: 15),
        EndingType.transcend,
      );
    });

    test('hidden condition + hiddenJob + memory 11 → hidden (not enough memory)', () {
      expect(
        EndingResolver.resolve(hiddenChoices(), isHiddenJob: true, unlockedMemoryCount: 11),
        EndingType.hidden,
      );
    });

    test('hidden condition + NOT hiddenJob + memory 12 → hidden', () {
      expect(
        EndingResolver.resolve(hiddenChoices(), isHiddenJob: false, unlockedMemoryCount: 12),
        EndingType.hidden,
      );
    });

    test('NOT hidden condition + hiddenJob + memory 12 → normal ending', () {
      // All slay → not hidden condition
      final choices = [
        const BossChoice(floor: 1, bossId: 'b1', choiceType: BossChoiceType.slay),
        const BossChoice(floor: 2, bossId: 'b2', choiceType: BossChoiceType.slay),
        const BossChoice(floor: 3, bossId: 'b3', choiceType: BossChoiceType.slay),
        const BossChoice(floor: 4, bossId: 'b4', choiceType: BossChoiceType.slay),
        const BossChoice(floor: 5, bossId: 'b5', choiceType: BossChoiceType.slay),
      ];
      expect(
        EndingResolver.resolve(choices, isHiddenJob: true, unlockedMemoryCount: 12),
        EndingType.slay,
      );
    });

    test('backward compatible: no optional params → same as before', () {
      // Hidden condition met
      expect(EndingResolver.resolve(hiddenChoices()), EndingType.hidden);

      // All slay
      final slayChoices = List.generate(
          5,
          (i) => BossChoice(
              floor: i + 1, bossId: 'b${i + 1}', choiceType: BossChoiceType.slay));
      expect(EndingResolver.resolve(slayChoices), EndingType.slay);
    });

    test('EndingType.transcend has correct properties', () {
      expect(EndingType.transcend.displayName, '초월');
      expect(EndingType.transcend.toneDescription, '근원의 결말');
    });

    test('EndingType has exactly 5 values', () {
      expect(EndingType.values.length, 5);
    });
  });
}
