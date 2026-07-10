import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/ending/ending_resolver.dart';
import 'package:soul_dungeon/domain/ending/ending_types.dart';
import 'package:soul_dungeon/core/models/boss_choice.dart';

void main() {
  group('EndingResolver', () {
    test('전원 처치 → slay 엔딩', () {
      final choices = List.generate(5, (i) => BossChoice(
        floor: i + 1,
        bossId: 'boss_$i',
        choiceType: BossChoiceType.slay,
      ));
      expect(EndingResolver.resolve(choices), EndingType.slay);
    });

    test('전원 해방 → liberate 엔딩', () {
      final choices = List.generate(5, (i) => BossChoice(
        floor: i + 1,
        bossId: 'boss_$i',
        choiceType: BossChoiceType.liberate,
      ));
      expect(EndingResolver.resolve(choices), EndingType.liberate);
    });

    test('전원 공존 → coexist 엔딩', () {
      final choices = List.generate(5, (i) => BossChoice(
        floor: i + 1,
        bossId: 'boss_$i',
        choiceType: BossChoiceType.coexist,
      ));
      expect(EndingResolver.resolve(choices), EndingType.coexist);
    });

    test('다수결 — 3처치 + 2해방 → slay', () {
      final choices = [
        const BossChoice(floor: 1, bossId: 'b1', choiceType: BossChoiceType.slay),
        const BossChoice(floor: 2, bossId: 'b2', choiceType: BossChoiceType.slay),
        const BossChoice(floor: 3, bossId: 'b3', choiceType: BossChoiceType.liberate),
        const BossChoice(floor: 4, bossId: 'b4', choiceType: BossChoiceType.slay),
        const BossChoice(floor: 5, bossId: 'b5', choiceType: BossChoiceType.liberate),
      ];
      expect(EndingResolver.resolve(choices), EndingType.slay);
    });

    test('다수결 — 1처치 + 3해방 + 1공존 → liberate', () {
      final choices = [
        const BossChoice(floor: 1, bossId: 'b1', choiceType: BossChoiceType.slay),
        const BossChoice(floor: 2, bossId: 'b2', choiceType: BossChoiceType.liberate),
        const BossChoice(floor: 3, bossId: 'b3', choiceType: BossChoiceType.liberate),
        const BossChoice(floor: 4, bossId: 'b4', choiceType: BossChoiceType.liberate),
        const BossChoice(floor: 5, bossId: 'b5', choiceType: BossChoiceType.coexist),
      ];
      expect(EndingResolver.resolve(choices), EndingType.liberate);
    });

    test('동점 → 4층 보스(안) 선택 우선', () {
      // 4보스: 2처치 + 2해방 (히든 조건 미달 — 5보스 필요)
      final choices = [
        const BossChoice(floor: 1, bossId: 'b1', choiceType: BossChoiceType.slay),
        const BossChoice(floor: 2, bossId: 'b2', choiceType: BossChoiceType.slay),
        const BossChoice(floor: 3, bossId: 'b3', choiceType: BossChoiceType.liberate),
        const BossChoice(floor: 4, bossId: 'b4', choiceType: BossChoiceType.liberate),
      ];
      // slay=2, liberate=2 동점 → 4층 선택 = liberate
      expect(EndingResolver.resolve(choices), EndingType.liberate);
    });

    test('동점 + 4층 부재 → 마지막 보스 선택', () {
      // 2보스: 동점, 4층 없음
      final choices = [
        const BossChoice(floor: 1, bossId: 'b1', choiceType: BossChoiceType.slay),
        const BossChoice(floor: 3, bossId: 'b3', choiceType: BossChoiceType.liberate),
      ];
      // slay=1, liberate=1 동점 → 4층 없음 → last=liberate
      expect(EndingResolver.resolve(choices), EndingType.liberate);
    });

    test('히든 엔딩 — 3유형 모두 + 5보스', () {
      final choices = [
        const BossChoice(floor: 1, bossId: 'b1', choiceType: BossChoiceType.slay),
        const BossChoice(floor: 2, bossId: 'b2', choiceType: BossChoiceType.liberate),
        const BossChoice(floor: 3, bossId: 'b3', choiceType: BossChoiceType.coexist),
        const BossChoice(floor: 4, bossId: 'b4', choiceType: BossChoiceType.slay),
        const BossChoice(floor: 5, bossId: 'b5', choiceType: BossChoiceType.liberate),
      ];
      // slay=2, liberate=2, coexist=1 → 3유형 모두 존재 + 5보스 완료 → hidden
      expect(EndingResolver.resolve(choices), EndingType.hidden);
    });

    test('히든 미달 — 3유형 있지만 다수결 존재 (1+1+3)', () {
      final choices = [
        const BossChoice(floor: 1, bossId: 'b1', choiceType: BossChoiceType.slay),
        const BossChoice(floor: 2, bossId: 'b2', choiceType: BossChoiceType.liberate),
        const BossChoice(floor: 3, bossId: 'b3', choiceType: BossChoiceType.coexist),
        const BossChoice(floor: 4, bossId: 'b4', choiceType: BossChoiceType.coexist),
        const BossChoice(floor: 5, bossId: 'b5', choiceType: BossChoiceType.coexist),
      ];
      // 3유형 모두 있지만 coexist=3 다수결 → 히든 아님
      expect(EndingResolver.resolve(choices), EndingType.coexist);
    });

    test('히든 미달 — 2유형만 (slay/liberate)', () {
      final choices = [
        const BossChoice(floor: 1, bossId: 'b1', choiceType: BossChoiceType.slay),
        const BossChoice(floor: 2, bossId: 'b2', choiceType: BossChoiceType.liberate),
        const BossChoice(floor: 3, bossId: 'b3', choiceType: BossChoiceType.slay),
        const BossChoice(floor: 4, bossId: 'b4', choiceType: BossChoiceType.liberate),
        const BossChoice(floor: 5, bossId: 'b5', choiceType: BossChoiceType.slay),
      ];
      // coexist 없음 → 히든 아님
      expect(EndingResolver.resolve(choices), EndingType.slay);
    });

    test('히든 미달 — 4보스만 (5보스 미완료)', () {
      final choices = [
        const BossChoice(floor: 1, bossId: 'b1', choiceType: BossChoiceType.slay),
        const BossChoice(floor: 2, bossId: 'b2', choiceType: BossChoiceType.liberate),
        const BossChoice(floor: 3, bossId: 'b3', choiceType: BossChoiceType.coexist),
        const BossChoice(floor: 4, bossId: 'b4', choiceType: BossChoiceType.slay),
      ];
      // 4보스 → 히든 아님 (5보스 필요)
      expect(EndingResolver.resolve(choices), isNot(EndingType.hidden));
    });

    test('빈 선택 → 기본값 slay', () {
      expect(EndingResolver.resolve([]), EndingType.slay);
    });

    test('1개 선택만 → 해당 엔딩', () {
      const choice = BossChoice(
        floor: 1,
        bossId: 'b1',
        choiceType: BossChoiceType.coexist,
      );
      expect(EndingResolver.resolve([choice]), EndingType.coexist);
    });

    // ── 신규 선택지 6→3 매핑 테스트 ──

    test('consume → slay 카테고리로 집계', () {
      final choices = List.generate(5, (i) => BossChoice(
        floor: i + 1,
        bossId: 'boss_$i',
        choiceType: BossChoiceType.consume,
      ));
      expect(EndingResolver.resolve(choices), EndingType.slay);
    });

    test('protect → liberate 카테고리로 집계', () {
      final choices = List.generate(5, (i) => BossChoice(
        floor: i + 1,
        bossId: 'boss_$i',
        choiceType: BossChoiceType.protect,
      ));
      expect(EndingResolver.resolve(choices), EndingType.liberate);
    });

    test('study → coexist 카테고리로 집계', () {
      final choices = List.generate(5, (i) => BossChoice(
        floor: i + 1,
        bossId: 'boss_$i',
        choiceType: BossChoiceType.study,
      ));
      expect(EndingResolver.resolve(choices), EndingType.coexist);
    });

    test('slay + consume 혼합 → slay 엔딩', () {
      final choices = [
        const BossChoice(floor: 1, bossId: 'b1', choiceType: BossChoiceType.slay),
        const BossChoice(floor: 2, bossId: 'b2', choiceType: BossChoiceType.consume),
        const BossChoice(floor: 3, bossId: 'b3', choiceType: BossChoiceType.slay),
        const BossChoice(floor: 4, bossId: 'b4', choiceType: BossChoiceType.consume),
        const BossChoice(floor: 5, bossId: 'b5', choiceType: BossChoiceType.slay),
      ];
      // 모두 slay 카테고리 → slay 엔딩
      expect(EndingResolver.resolve(choices), EndingType.slay);
    });

    test('liberate + protect 혼합 → liberate 엔딩', () {
      final choices = [
        const BossChoice(floor: 1, bossId: 'b1', choiceType: BossChoiceType.liberate),
        const BossChoice(floor: 2, bossId: 'b2', choiceType: BossChoiceType.protect),
        const BossChoice(floor: 3, bossId: 'b3', choiceType: BossChoiceType.liberate),
        const BossChoice(floor: 4, bossId: 'b4', choiceType: BossChoiceType.protect),
        const BossChoice(floor: 5, bossId: 'b5', choiceType: BossChoiceType.liberate),
      ];
      expect(EndingResolver.resolve(choices), EndingType.liberate);
    });

    test('coexist + study 혼합 → coexist 엔딩', () {
      final choices = [
        const BossChoice(floor: 1, bossId: 'b1', choiceType: BossChoiceType.coexist),
        const BossChoice(floor: 2, bossId: 'b2', choiceType: BossChoiceType.study),
        const BossChoice(floor: 3, bossId: 'b3', choiceType: BossChoiceType.coexist),
        const BossChoice(floor: 4, bossId: 'b4', choiceType: BossChoiceType.study),
        const BossChoice(floor: 5, bossId: 'b5', choiceType: BossChoiceType.coexist),
      ];
      expect(EndingResolver.resolve(choices), EndingType.coexist);
    });

    test('히든 엔딩 — 신규 타입 혼합으로 3카테고리 충족', () {
      final choices = [
        const BossChoice(floor: 1, bossId: 'b1', choiceType: BossChoiceType.consume),
        const BossChoice(floor: 2, bossId: 'b2', choiceType: BossChoiceType.protect),
        const BossChoice(floor: 3, bossId: 'b3', choiceType: BossChoiceType.study),
        const BossChoice(floor: 4, bossId: 'b4', choiceType: BossChoiceType.consume),
        const BossChoice(floor: 5, bossId: 'b5', choiceType: BossChoiceType.protect),
      ];
      // slay카테고리=2, liberate카테고리=2, coexist카테고리=1 → 히든
      expect(EndingResolver.resolve(choices), EndingType.hidden);
    });

    test('동점 — 4층 protect → liberate 카테고리 우선', () {
      final choices = [
        const BossChoice(floor: 1, bossId: 'b1', choiceType: BossChoiceType.consume),
        const BossChoice(floor: 2, bossId: 'b2', choiceType: BossChoiceType.consume),
        const BossChoice(floor: 3, bossId: 'b3', choiceType: BossChoiceType.protect),
        const BossChoice(floor: 4, bossId: 'b4', choiceType: BossChoiceType.protect),
      ];
      // slay카테고리=2, liberate카테고리=2 동점 → 4층=protect→liberate
      expect(EndingResolver.resolve(choices), EndingType.liberate);
    });
  });

  group('EndingType', () {
    test('5가지 엔딩 존재', () {
      expect(EndingType.values.length, 5);
    });

    test('displayName 한글', () {
      expect(EndingType.slay.displayName, '처치');
      expect(EndingType.liberate.displayName, '해방');
      expect(EndingType.coexist.displayName, '공존');
      expect(EndingType.hidden.displayName, '히든');
    });

    test('toneDescription 존재', () {
      for (final ending in EndingType.values) {
        expect(ending.toneDescription, isNotEmpty);
      }
    });
  });
}
