import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/tutorial_config.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

void main() {
  group('TutorialConfig', () {
    test('기본값 — enabled + combat(0) + event(1)', () {
      const config = TutorialConfig();
      expect(config.enabled, isTrue);
      expect(config.fixedDepthRooms[0], RoomType.combat);
      expect(config.fixedDepthRooms[1], RoomType.event);
    });

    test('fromJson — 기본 구조', () {
      final config = TutorialConfig.fromJson({
        'enabled': true,
        'fixed_depth_rooms': {
          '0': 'combat',
          '1': 'event',
        },
      });
      expect(config.enabled, isTrue);
      expect(config.fixedDepthRooms[0], RoomType.combat);
      expect(config.fixedDepthRooms[1], RoomType.event);
    });

    test('fromJson — enabled false', () {
      final config = TutorialConfig.fromJson({'enabled': false});
      expect(config.enabled, isFalse);
    });

    test('fromJson — 커스텀 방 배치', () {
      final config = TutorialConfig.fromJson({
        'enabled': true,
        'fixed_depth_rooms': {
          '0': 'rest',
          '1': 'shop',
          '2': 'mystery',
        },
      });
      expect(config.fixedDepthRooms[0], RoomType.rest);
      expect(config.fixedDepthRooms[1], RoomType.shop);
      expect(config.fixedDepthRooms[2], RoomType.mystery);
    });

    test('fromJson — 빈 fixed_depth_rooms → 기본값', () {
      final config = TutorialConfig.fromJson({
        'enabled': true,
        'fixed_depth_rooms': {},
      });
      // 빈 맵 → 기본값 사용
      expect(config.fixedDepthRooms[0], RoomType.combat);
      expect(config.fixedDepthRooms[1], RoomType.event);
    });

    test('fromJson — 잘못된 RoomType 이름 무시', () {
      final config = TutorialConfig.fromJson({
        'enabled': true,
        'fixed_depth_rooms': {
          '0': 'invalid_type',
          '1': 'event',
        },
      });
      // invalid_type 무시, event만 남음 → 1개뿐이므로 기본값 폴백 아님
      expect(config.fixedDepthRooms.containsKey(0), isFalse);
      expect(config.fixedDepthRooms[1], RoomType.event);
    });

    test('fromJson — 빈 JSON → 기본값', () {
      final config = TutorialConfig.fromJson({});
      expect(config.enabled, isTrue);
      expect(config.fixedDepthRooms.length, 2);
    });
  });

  group('TutorialConfig.appliesTo', () {
    test('enabled + floor 1 + firstRun → true', () {
      const config = TutorialConfig();
      expect(
        config.appliesTo(floor: 1, isFirstRun: true),
        isTrue,
      );
    });

    test('enabled + floor 2 → false', () {
      const config = TutorialConfig();
      expect(
        config.appliesTo(floor: 2, isFirstRun: true),
        isFalse,
      );
    });

    test('enabled + not firstRun → false', () {
      const config = TutorialConfig();
      expect(
        config.appliesTo(floor: 1, isFirstRun: false),
        isFalse,
      );
    });

    test('disabled → false', () {
      const config = TutorialConfig(enabled: false);
      expect(
        config.appliesTo(floor: 1, isFirstRun: true),
        isFalse,
      );
    });
  });
}
