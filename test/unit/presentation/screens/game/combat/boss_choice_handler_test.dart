import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/models/boss_choice.dart';
import 'package:soul_dungeon/presentation/screens/game/combat/boss_choice_handler.dart';

void main() {
  group('BossChoiceHandler', () {
    group('buildChoices', () {
      test('항상 3개 선택지 반환', () {
        final choices = BossChoiceHandler.buildChoices(
          floor: 1,
          bossId: 'boss_ash',
          momentum: 80,
          random: Random(42),
        );
        expect(choices.length, 3);
      });

      test('공격적 1개 + 온건 2개 구조', () {
        final choices = BossChoiceHandler.buildChoices(
          floor: 1,
          bossId: 'boss_ash',
          momentum: 100,
          random: Random(42),
        );

        // 첫 번째는 공격적 (slay or consume)
        final aggressiveIds = {'boss_slay', 'boss_consume'};
        expect(aggressiveIds.contains(choices[0].id), isTrue);

        // 나머지 2개는 온건 (liberate/protect/coexist/study)
        final moderateIds = {
          'boss_liberate',
          'boss_protect',
          'boss_coexist',
          'boss_study',
        };
        expect(moderateIds.contains(choices[1].id), isTrue);
        expect(moderateIds.contains(choices[2].id), isTrue);
      });

      test('기세 80+ → 온건 선택지 활성', () {
        final choices = BossChoiceHandler.buildChoices(
          floor: 1,
          bossId: 'boss_ash',
          momentum: 80,
          random: Random(42),
        );
        // 잠금 선택지 없음
        for (final choice in choices) {
          expect(choice.id.endsWith('_locked'), isFalse);
        }
      });

      test('기세 49 → 첫 번째 온건 해금, 두 번째 온건 잠금', () {
        final choices = BossChoiceHandler.buildChoices(
          floor: 1,
          bossId: 'boss_ash',
          momentum: 49,
          random: Random(42),
        );

        // 첫 번째(공격적)는 잠금 아님
        expect(choices[0].id.endsWith('_locked'), isFalse);

        // 첫 번째 온건은 항상 해금, 두 번째 온건은 잠금
        expect(choices[1].id.endsWith('_locked'), isFalse);
        expect(choices[2].id.endsWith('_locked'), isTrue);
      });

      test('기세 0 → 첫 번째 온건 해금, 두 번째 온건 잠금', () {
        final choices = BossChoiceHandler.buildChoices(
          floor: 1,
          bossId: 'boss_ash',
          momentum: 0,
          random: Random(42),
        );
        expect(choices[0].id.endsWith('_locked'), isFalse);
        expect(choices[1].id.endsWith('_locked'), isFalse);
        expect(choices[2].id.endsWith('_locked'), isTrue);
      });

      test('잠금 선택지 텍스트에 기세 요구치 표시', () {
        final choices = BossChoiceHandler.buildChoices(
          floor: 1,
          bossId: 'boss_ash',
          momentum: 0,
          random: Random(42),
        );
        // 두 번째 온건 잠금 선택지에서 기세 표시 확인
        final locked = choices.where((c) => c.id.endsWith('_locked'));
        expect(locked, isNotEmpty);
        for (final c in locked) {
          expect(c.text, contains('기세'));
          expect(c.text, contains('50'));
        }
      });

      test('공격적 선택지 항상 가능 (기세 0)', () {
        final choices = BossChoiceHandler.buildChoices(
          floor: 1,
          bossId: 'boss_ash',
          momentum: 0,
          random: Random(42),
        );
        expect(choices[0].id.endsWith('_locked'), isFalse);
      });

      test('여러 시드에서 다양한 조합 생성', () {
        final allChoiceIds = <Set<String>>[];
        for (int seed = 0; seed < 50; seed++) {
          final choices = BossChoiceHandler.buildChoices(
            floor: 1,
            bossId: 'boss_ash',
            momentum: 100,
            random: Random(seed),
          );
          allChoiceIds.add(choices.map((c) => c.id).toSet());
        }
        // 50번 시도에서 최소 2가지 이상 다른 조합이 나와야 함
        expect(allChoiceIds.toSet().length, greaterThan(1));
      });
    });

    group('choiceTypeFromId', () {
      test('boss_slay → BossChoiceType.slay', () {
        expect(
          BossChoiceHandler.choiceTypeFromId('boss_slay'),
          BossChoiceType.slay,
        );
      });

      test('boss_liberate → BossChoiceType.liberate', () {
        expect(
          BossChoiceHandler.choiceTypeFromId('boss_liberate'),
          BossChoiceType.liberate,
        );
      });

      test('boss_coexist → BossChoiceType.coexist', () {
        expect(
          BossChoiceHandler.choiceTypeFromId('boss_coexist'),
          BossChoiceType.coexist,
        );
      });

      test('boss_study → BossChoiceType.study', () {
        expect(
          BossChoiceHandler.choiceTypeFromId('boss_study'),
          BossChoiceType.study,
        );
      });

      test('boss_consume → BossChoiceType.consume', () {
        expect(
          BossChoiceHandler.choiceTypeFromId('boss_consume'),
          BossChoiceType.consume,
        );
      });

      test('boss_protect → BossChoiceType.protect', () {
        expect(
          BossChoiceHandler.choiceTypeFromId('boss_protect'),
          BossChoiceType.protect,
        );
      });

      test('잠금 선택지 → null', () {
        expect(BossChoiceHandler.choiceTypeFromId('boss_liberate_locked'), isNull);
        expect(BossChoiceHandler.choiceTypeFromId('boss_coexist_locked'), isNull);
        expect(BossChoiceHandler.choiceTypeFromId('boss_study_locked'), isNull);
        expect(BossChoiceHandler.choiceTypeFromId('boss_protect_locked'), isNull);
      });

      test('boss_continue → null', () {
        expect(BossChoiceHandler.choiceTypeFromId('boss_continue'), isNull);
      });

      test('unknown → null', () {
        expect(BossChoiceHandler.choiceTypeFromId('unknown'), isNull);
      });
    });

    group('momentumThreshold', () {
      test('기본값 50', () {
        expect(BossChoiceHandler.momentumThreshold, 50);
      });
    });
  });
}
