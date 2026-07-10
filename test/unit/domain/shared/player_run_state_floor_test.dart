import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/models/boss_choice.dart';
import 'package:soul_dungeon/core/models/player_run_state.dart';

void main() {
  group('PlayerRunState — floor 관련 필드', () {
    test('initial() → currentFloor=1, bossChoices=[], completedFloors={}', () {
      final prs = PlayerRunState.initial(maxHp: 100);
      expect(prs.currentFloor, 1);
      expect(prs.bossChoices, isEmpty);
      expect(prs.completedFloors, isEmpty);
    });

    test('기본 생성자 currentFloor 기본값 = 1', () {
      const prs = PlayerRunState(currentHp: 100, maxHp: 100);
      expect(prs.currentFloor, 1);
      expect(prs.bossChoices, isEmpty);
      expect(prs.completedFloors, isEmpty);
    });

    test('copyWith currentFloor', () {
      final prs = PlayerRunState.initial(maxHp: 100);
      final updated = prs.copyWith(currentFloor: 3);
      expect(updated.currentFloor, 3);
      expect(updated.currentHp, 100); // 나머지 보존
    });

    test('copyWith bossChoices', () {
      final prs = PlayerRunState.initial(maxHp: 100);
      const choice = BossChoice(floor: 1, bossId: 'b1', choiceType: BossChoiceType.slay);
      final updated = prs.copyWith(bossChoices: [choice]);
      expect(updated.bossChoices.length, 1);
      expect(updated.bossChoices.first.bossId, 'b1');
    });

    test('copyWith completedFloors', () {
      final prs = PlayerRunState.initial(maxHp: 100);
      final updated = prs.copyWith(completedFloors: {1, 2});
      expect(updated.completedFloors, {1, 2});
    });

    test('copyWith null → 기존값 유지', () {
      const choice = BossChoice(floor: 1, bossId: 'b1', choiceType: BossChoiceType.slay);
      final prs = PlayerRunState.initial(maxHp: 100).copyWith(
        currentFloor: 3,
        bossChoices: [choice],
        completedFloors: {1, 2},
      );
      final copy = prs.copyWith(gold: 50);
      expect(copy.currentFloor, 3);
      expect(copy.bossChoices.length, 1);
      expect(copy.completedFloors, {1, 2});
      expect(copy.gold, 50);
    });

    test('동등성 — currentFloor 포함', () {
      final a = PlayerRunState.initial(maxHp: 100).copyWith(currentFloor: 2);
      final b = PlayerRunState.initial(maxHp: 100).copyWith(currentFloor: 2);
      final c = PlayerRunState.initial(maxHp: 100).copyWith(currentFloor: 3);
      expect(a, b);
      expect(a, isNot(c));
    });

    test('동등성 — bossChoices 포함', () {
      const choice = BossChoice(floor: 1, bossId: 'b1', choiceType: BossChoiceType.slay);
      final a = PlayerRunState.initial(maxHp: 100).copyWith(bossChoices: [choice]);
      final b = PlayerRunState.initial(maxHp: 100).copyWith(bossChoices: [choice]);
      final c = PlayerRunState.initial(maxHp: 100);
      expect(a, b);
      expect(a, isNot(c));
    });

    test('동등성 — completedFloors 포함', () {
      final a = PlayerRunState.initial(maxHp: 100).copyWith(completedFloors: {1});
      final b = PlayerRunState.initial(maxHp: 100).copyWith(completedFloors: {1});
      final c = PlayerRunState.initial(maxHp: 100).copyWith(completedFloors: {1, 2});
      expect(a, b);
      expect(a, isNot(c));
    });

    test('hashCode 다른 값 → 다른 해시', () {
      final a = PlayerRunState.initial(maxHp: 100).copyWith(currentFloor: 1);
      final b = PlayerRunState.initial(maxHp: 100).copyWith(currentFloor: 2);
      // 해시 충돌 가능하지만 대부분 다름
      expect(a.hashCode, isNot(b.hashCode));
    });

    test('toString에 floor 정보 포함', () {
      final prs = PlayerRunState.initial(maxHp: 100).copyWith(currentFloor: 3);
      expect(prs.toString(), contains('floor: 3'));
    });

    test('assert: currentFloor < 1 → AssertionError', () {
      expect(
        () => PlayerRunState(currentHp: 100, maxHp: 100, currentFloor: 0),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
