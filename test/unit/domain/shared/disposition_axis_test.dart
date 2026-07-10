import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/models/disposition_axis.dart';

void main() {
  group('DispositionAxis', () {
    test('has exactly 6 values', () {
      expect(DispositionAxis.values.length, 6);
    });

    test('contains all expected values', () {
      expect(DispositionAxis.values, containsAll([
        DispositionAxis.struggle,
        DispositionAxis.mercy,
        DispositionAxis.wisdom,
        DispositionAxis.shadow,
        DispositionAxis.will,
        DispositionAxis.harmony,
      ]));
    });

    test('each axis has a Korean displayName', () {
      expect(DispositionAxis.struggle.displayName, '투쟁');
      expect(DispositionAxis.mercy.displayName, '자비');
      expect(DispositionAxis.wisdom.displayName, '지혜');
      expect(DispositionAxis.shadow.displayName, '그림자');
      expect(DispositionAxis.will.displayName, '의지');
      expect(DispositionAxis.harmony.displayName, '조화');
    });

    test('all displayNames are non-empty', () {
      for (final axis in DispositionAxis.values) {
        expect(axis.displayName, isNotEmpty);
      }
    });

    test('switch exhaustiveness covers all cases', () {
      for (final axis in DispositionAxis.values) {
        final result = switch (axis) {
          DispositionAxis.struggle => 'struggle',
          DispositionAxis.mercy => 'mercy',
          DispositionAxis.wisdom => 'wisdom',
          DispositionAxis.shadow => 'shadow',
          DispositionAxis.will => 'will',
          DispositionAxis.harmony => 'harmony',
        };
        expect(result, isNotEmpty);
      }
    });
  });
}
