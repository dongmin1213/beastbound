import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/narrative/bloc/narrator_state.dart';
import 'package:soul_dungeon/presentation/screens/game/narrator_display.dart';

void main() {
  group('NarratorDisplay.displayHp', () {
    test('narratorState null → 실제값 반환', () {
      expect(NarratorDisplay.displayHp(80, null), 80);
    });

    test('NarratorReliable → 실제값 반환', () {
      const state = NarratorReliable();
      expect(NarratorDisplay.displayHp(80, state), 80);
    });

    test('NarratorDistorted + 양수 오프셋 → 왜곡', () {
      const state = NarratorDistorted(hpLieOffset: 5);
      expect(NarratorDisplay.displayHp(80, state), 85);
    });

    test('NarratorDistorted + 음수 오프셋 → 왜곡', () {
      const state = NarratorDistorted(hpLieOffset: -3);
      expect(NarratorDisplay.displayHp(80, state), 77);
    });

    test('왜곡 결과 최소 1 (0 이하 방지)', () {
      const state = NarratorDistorted(hpLieOffset: -5);
      expect(NarratorDisplay.displayHp(3, state), 1);
    });

    test('왜곡 결과 최대 999', () {
      const state = NarratorDistorted(hpLieOffset: 5);
      expect(NarratorDisplay.displayHp(998, state), 999);
    });

    test('domain 값 불변 검증 — 실제값 변경 없음', () {
      const state = NarratorDistorted(hpLieOffset: 10);
      const realHp = 50;
      NarratorDisplay.displayHp(realHp, state);
      // realHp는 변경되지 않음 (int는 값 타입이므로 당연하지만 의도 확인)
      expect(realHp, 50);
    });

    test('silent 상태에서도 왜곡 적용', () {
      const state = NarratorDistorted(
        hpLieOffset: 3,
        silent: true,
      );
      expect(NarratorDisplay.displayHp(50, state), 53);
    });
  });
}
