
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/models/disposition_axis.dart';
import 'package:soul_dungeon/presentation/screens/game/disposition_hint_generator.dart';

void main() {
  const defaultConfig = DispositionConfig();

  group('DispositionHintGenerator.getDominantAxis', () {
    test('단일 우세 축 반환', () {
      final disposition = {
        DispositionAxis.struggle: 5,
        DispositionAxis.mercy: 2,
        DispositionAxis.wisdom: 1,
        DispositionAxis.shadow: 0,
        DispositionAxis.will: 0,
        DispositionAxis.harmony: 0,
      };

      expect(
        DispositionHintGenerator.getDominantAxis(disposition),
        DispositionAxis.struggle,
      );
    });

    test('동점 시 null 반환', () {
      final disposition = {
        DispositionAxis.struggle: 3,
        DispositionAxis.mercy: 3,
        DispositionAxis.wisdom: 0,
        DispositionAxis.shadow: 0,
        DispositionAxis.will: 0,
        DispositionAxis.harmony: 0,
      };

      expect(
        DispositionHintGenerator.getDominantAxis(disposition),
        isNull,
      );
    });

    test('모든 값 0 시 null 반환', () {
      final disposition = {
        DispositionAxis.struggle: 0,
        DispositionAxis.mercy: 0,
        DispositionAxis.wisdom: 0,
        DispositionAxis.shadow: 0,
        DispositionAxis.will: 0,
        DispositionAxis.harmony: 0,
      };

      expect(
        DispositionHintGenerator.getDominantAxis(disposition),
        isNull,
      );
    });

    test('harmony 축 제외', () {
      final disposition = {
        DispositionAxis.struggle: 1,
        DispositionAxis.mercy: 0,
        DispositionAxis.wisdom: 0,
        DispositionAxis.shadow: 0,
        DispositionAxis.will: 0,
        DispositionAxis.harmony: 10,
      };

      expect(
        DispositionHintGenerator.getDominantAxis(disposition),
        DispositionAxis.struggle,
      );
    });
  });

  group('DispositionHintGenerator.generateHint', () {
    test('threshold 충족 시 힌트 반환', () {
      final disposition = {
        DispositionAxis.struggle: 0,
        DispositionAxis.mercy: 3,
        DispositionAxis.wisdom: 0,
        DispositionAxis.shadow: 0,
        DispositionAxis.will: 0,
        DispositionAxis.harmony: 0,
      };

      final hint = DispositionHintGenerator.generateHint(
        disposition: disposition,
        roomsSinceLastHint: 99,
        hintIndex: 0,
        config: defaultConfig,
      );

      expect(hint, isNotNull);
      expect(hint, contains('빛'));
    });

    test('threshold 미달 시 null 반환', () {
      final disposition = {
        DispositionAxis.struggle: 0,
        DispositionAxis.mercy: 2,
        DispositionAxis.wisdom: 0,
        DispositionAxis.shadow: 0,
        DispositionAxis.will: 0,
        DispositionAxis.harmony: 0,
      };

      final hint = DispositionHintGenerator.generateHint(
        disposition: disposition,
        roomsSinceLastHint: 99,
        hintIndex: 0,
        config: defaultConfig,
      );

      expect(hint, isNull);
    });

    test('cooldown 미경과 시 null 반환', () {
      final disposition = {
        DispositionAxis.struggle: 0,
        DispositionAxis.mercy: 5,
        DispositionAxis.wisdom: 0,
        DispositionAxis.shadow: 0,
        DispositionAxis.will: 0,
        DispositionAxis.harmony: 0,
      };

      final hint = DispositionHintGenerator.generateHint(
        disposition: disposition,
        roomsSinceLastHint: 1,
        hintIndex: 0,
        config: defaultConfig,
      );

      expect(hint, isNull);
    });

    test('축별 텍스트 정합성 — 5축 각각 힌트 생성', () {
      final axes = [
        DispositionAxis.struggle,
        DispositionAxis.mercy,
        DispositionAxis.wisdom,
        DispositionAxis.shadow,
        DispositionAxis.will,
      ];

      for (final axis in axes) {
        final disposition = {
          for (final a in DispositionAxis.values) a: a == axis ? 5 : 0,
        };

        final hint = DispositionHintGenerator.generateHint(
          disposition: disposition,
          roomsSinceLastHint: 99,
          hintIndex: 0,
          config: defaultConfig,
        );

        expect(hint, isNotNull, reason: '${axis.name} 축 힌트가 null');
      }
    });

    test('hintIndex 순환 — 같은 축 다른 텍스트', () {
      final disposition = {
        DispositionAxis.struggle: 5,
        DispositionAxis.mercy: 0,
        DispositionAxis.wisdom: 0,
        DispositionAxis.shadow: 0,
        DispositionAxis.will: 0,
        DispositionAxis.harmony: 0,
      };

      final hint0 = DispositionHintGenerator.generateHint(
        disposition: disposition,
        roomsSinceLastHint: 99,
        hintIndex: 0,
        config: defaultConfig,
      );
      final hint1 = DispositionHintGenerator.generateHint(
        disposition: disposition,
        roomsSinceLastHint: 99,
        hintIndex: 1,
        config: defaultConfig,
      );
      final hint3 = DispositionHintGenerator.generateHint(
        disposition: disposition,
        roomsSinceLastHint: 99,
        hintIndex: 3,
        config: defaultConfig,
      );

      expect(hint0, isNot(equals(hint1)));
      expect(hint0, equals(hint3)); // 3 % 3 == 0 → 같은 텍스트
    });
  });

  group('DispositionHintGenerator.isBalanced', () {
    test('non-zero 3개 이상 + 편차 ≤ maxDeviation → true', () {
      final disposition = {
        DispositionAxis.struggle: 3,
        DispositionAxis.mercy: 4,
        DispositionAxis.wisdom: 3,
        DispositionAxis.shadow: 0,
        DispositionAxis.will: 0,
        DispositionAxis.harmony: 0,
      };

      expect(DispositionHintGenerator.isBalanced(disposition, 2), isTrue);
    });

    test('non-zero 2개 이하 → false', () {
      final disposition = {
        DispositionAxis.struggle: 3,
        DispositionAxis.mercy: 3,
        DispositionAxis.wisdom: 0,
        DispositionAxis.shadow: 0,
        DispositionAxis.will: 0,
        DispositionAxis.harmony: 0,
      };

      expect(DispositionHintGenerator.isBalanced(disposition, 2), isFalse);
    });

    test('편차 > maxDeviation → false', () {
      final disposition = {
        DispositionAxis.struggle: 1,
        DispositionAxis.mercy: 5,
        DispositionAxis.wisdom: 3,
        DispositionAxis.shadow: 0,
        DispositionAxis.will: 0,
        DispositionAxis.harmony: 0,
      };

      expect(DispositionHintGenerator.isBalanced(disposition, 2), isFalse);
    });
  });

  // harmony 힌트 텍스트 목록 — production _harmonyHints와 동기화.
  const harmonyHints = [
    '모든 것이 조화로운 균형 속에서 빛나고 있다.',
    '영혼의 모든 면이 고르게 깨어나고 있다.',
    '어떤 한쪽으로도 치우치지 않는 고요한 힘이 감돈다.',
  ];

  group('DispositionHintGenerator — harmony 힌트', () {
    test('균형 성향 + dominant null → harmony 힌트 반환', () {
      // 3축 동일값 → getDominantAxis null, isBalanced true, total=9 ≥ 5
      final disposition = {
        DispositionAxis.struggle: 3,
        DispositionAxis.mercy: 3,
        DispositionAxis.wisdom: 3,
        DispositionAxis.shadow: 0,
        DispositionAxis.will: 0,
        DispositionAxis.harmony: 0,
      };

      final hint = DispositionHintGenerator.generateHint(
        disposition: disposition,
        roomsSinceLastHint: 99,
        hintIndex: 0,
        config: defaultConfig,
        harmonyMaxDeviation: 2,
      );

      expect(hint, isNotNull);
      expect(harmonyHints, contains(hint));
    });

    test('불균형 + dominant null → null 반환', () {
      // 2축만 non-zero → isBalanced false, dominant tied → null
      final disposition = {
        DispositionAxis.struggle: 3,
        DispositionAxis.mercy: 3,
        DispositionAxis.wisdom: 0,
        DispositionAxis.shadow: 0,
        DispositionAxis.will: 0,
        DispositionAxis.harmony: 0,
      };

      final hint = DispositionHintGenerator.generateHint(
        disposition: disposition,
        roomsSinceLastHint: 99,
        hintIndex: 0,
        config: defaultConfig,
        harmonyMaxDeviation: 2,
      );

      expect(hint, isNull);
    });

    test('균형이지만 합계 < 5 → null (너무 이른 harmony 힌트 방지)', () {
      // 3축 각 1 → total=3 < _harmonyMinTotal(5), isBalanced true
      final disposition = {
        DispositionAxis.struggle: 1,
        DispositionAxis.mercy: 1,
        DispositionAxis.wisdom: 1,
        DispositionAxis.shadow: 0,
        DispositionAxis.will: 0,
        DispositionAxis.harmony: 0,
      };

      final hint = DispositionHintGenerator.generateHint(
        disposition: disposition,
        roomsSinceLastHint: 99,
        hintIndex: 0,
        config: defaultConfig,
        harmonyMaxDeviation: 2,
      );

      expect(hint, isNull);
    });

    test('균형 + 합계 == 5 (경계) → harmony 힌트 반환', () {
      // struggle:2 + mercy:2 + wisdom:1 → total=5, deviation=1 ≤ 2
      final disposition = {
        DispositionAxis.struggle: 2,
        DispositionAxis.mercy: 2,
        DispositionAxis.wisdom: 1,
        DispositionAxis.shadow: 0,
        DispositionAxis.will: 0,
        DispositionAxis.harmony: 0,
      };

      final hint = DispositionHintGenerator.generateHint(
        disposition: disposition,
        roomsSinceLastHint: 99,
        hintIndex: 0,
        config: defaultConfig,
        harmonyMaxDeviation: 2,
      );

      expect(hint, isNotNull);
      expect(harmonyHints, contains(hint));
    });

    test('harmony 힌트 인덱스 순환', () {
      final disposition = {
        DispositionAxis.struggle: 4,
        DispositionAxis.mercy: 4,
        DispositionAxis.wisdom: 4,
        DispositionAxis.shadow: 0,
        DispositionAxis.will: 0,
        DispositionAxis.harmony: 0,
      };

      final hint0 = DispositionHintGenerator.generateHint(
        disposition: disposition,
        roomsSinceLastHint: 99,
        hintIndex: 0,
        config: defaultConfig,
        harmonyMaxDeviation: 2,
      );
      final hint1 = DispositionHintGenerator.generateHint(
        disposition: disposition,
        roomsSinceLastHint: 99,
        hintIndex: 1,
        config: defaultConfig,
        harmonyMaxDeviation: 2,
      );
      final hint3 = DispositionHintGenerator.generateHint(
        disposition: disposition,
        roomsSinceLastHint: 99,
        hintIndex: 3,
        config: defaultConfig,
        harmonyMaxDeviation: 2,
      );

      expect(hint0, isNot(equals(hint1)));
      expect(hint0, equals(hint3)); // 3 % 3 == 0
    });
  });

  group('DispositionHintGenerator.load()', () {
    test('load — valid JSON replaces defaults', () async {
      final bundle = _TestBundle();
      await DispositionHintGenerator.load(bundle: bundle);

      // struggle 축 우세 성향으로 힌트 생성
      final disposition = {
        DispositionAxis.struggle: 5,
        DispositionAxis.mercy: 0,
        DispositionAxis.wisdom: 0,
        DispositionAxis.shadow: 0,
        DispositionAxis.will: 0,
        DispositionAxis.harmony: 0,
      };

      final hint = DispositionHintGenerator.generateHint(
        disposition: disposition,
        roomsSinceLastHint: 99,
        hintIndex: 0,
        config: defaultConfig,
      );

      expect(hint, contains('TEST'));

      // 복원: invalid bundle로 로드 → 기본값 폴백
      await DispositionHintGenerator.load(bundle: _InvalidBundle());
    });

    test('load — invalid JSON keeps defaults', () async {
      // 기본값 상태의 결과 기록
      final disposition = {
        DispositionAxis.struggle: 5,
        DispositionAxis.mercy: 0,
        DispositionAxis.wisdom: 0,
        DispositionAxis.shadow: 0,
        DispositionAxis.will: 0,
        DispositionAxis.harmony: 0,
      };

      final before = DispositionHintGenerator.generateHint(
        disposition: disposition,
        roomsSinceLastHint: 99,
        hintIndex: 0,
        config: defaultConfig,
      );

      await DispositionHintGenerator.load(bundle: _InvalidBundle());

      final after = DispositionHintGenerator.generateHint(
        disposition: disposition,
        roomsSinceLastHint: 99,
        hintIndex: 0,
        config: defaultConfig,
      );

      expect(after, before);
    });
  });
}

class _TestBundle extends CachingAssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    return '{"harmony":["TEST 조화"],"axes":{"struggle":["TEST 투쟁"],"mercy":["TEST 자비"],"wisdom":["TEST 지혜"],"shadow":["TEST 그림자"],"will":["TEST 의지"]}}';
  }

  @override
  Future<ByteData> load(String key) async => throw UnimplementedError();
}

class _InvalidBundle extends CachingAssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    return 'not valid json';
  }

  @override
  Future<ByteData> load(String key) async => throw UnimplementedError();
}
