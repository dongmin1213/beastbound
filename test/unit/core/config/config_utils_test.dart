import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/config_utils.dart';

void main() {
  group('clampInt', () {
    test('returns value when within range', () {
      expect(clampInt(5, 1, 10, 0, 'test'), 5);
      expect(clampInt(1, 1, 10, 0, 'test'), 1);
      expect(clampInt(10, 1, 10, 0, 'test'), 10);
    });

    test('returns fallback for out-of-range, invalid type, and edge cases', () {
      // 범위 초과
      expect(clampInt(11, 1, 10, 0, 'test'), 0);
      // 범위 미만
      expect(clampInt(0, 1, 10, 5, 'test'), 5);
      // 잘못된 타입
      expect(clampInt('invalid', 1, 10, 5, 'test'), 5);
      expect(clampInt(null, 1, 10, 5, 'test'), 5);
      expect(clampInt(3.5, 1, 10, 5, 'test'), 5);
      // 음수 범위
      expect(clampInt(-10, -100, 0, -50, 'test'), -10);
      expect(clampInt(1, -100, 0, -50, 'test'), -50);
    });
  });
}
