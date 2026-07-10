import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/dungeon/event/job_event_variants.dart';

void main() {
  group('JobEventVariants', () {
    test('warrior variant for 전사의 유령', () {
      final variant = JobEventVariants.getVariant('전사의 유령', 'warrior');
      expect(variant, isNotNull);
      expect(variant!.label, contains('전사'));
    });

    test('sage variant for 수정 동굴', () {
      final variant = JobEventVariants.getVariant('수정 동굴', 'sage');
      expect(variant, isNotNull);
      expect(variant!.label, contains('분석'));
    });

    test('assassin variant for 수상한 상인', () {
      final variant = JobEventVariants.getVariant('수상한 상인', 'assassin');
      expect(variant, isNotNull);
      expect(variant!.label, contains('그림자'));
    });

    test('saint variant for 깨진 제단', () {
      final variant = JobEventVariants.getVariant('깨진 제단', 'saint');
      expect(variant, isNotNull);
      expect(variant!.label, contains('신성'));
    });

    test('guardian variant for 잊혀진 보물상자', () {
      final variant = JobEventVariants.getVariant('잊혀진 보물상자', 'guardian');
      expect(variant, isNotNull);
      expect(variant!.label, contains('방패'));
    });

    test('wanderer variant for 이상한 거래', () {
      final variant = JobEventVariants.getVariant('이상한 거래', 'wanderer');
      expect(variant, isNotNull);
      expect(variant!.label, contains('운'));
    });

    test('returns null for non-matching event', () {
      expect(JobEventVariants.getVariant('수정 동굴', 'warrior'), isNull);
    });

    test('returns null for null jobId', () {
      expect(JobEventVariants.getVariant('전사의 유령', null), isNull);
    });

    test('returns null for unknown jobId', () {
      expect(JobEventVariants.getVariant('전사의 유령', 'unknown'), isNull);
    });
  });
}
