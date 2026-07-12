
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/boss_encounter_factory.dart';

void main() {
  group('BossEncounterFactory', () {
    test('5층 모두 고유 보스 생성', () {
      final names = <String>{};
      for (var floor = 1; floor <= 5; floor++) {
        final encounter = BossEncounterFactory.create(floor: floor);
        expect(encounter.roomType, RoomType.boss);
        expect(encounter.enemyName, isNotEmpty);
        expect(encounter.bossPhases, isNotNull);
        expect(encounter.bossPhases!.length, 2);
        names.add(encounter.enemyName);
      }
      // 5개 모두 다른 이름
      expect(names.length, 5);
    });

    test('1층 보스 — 재(灰)의 주인', () {
      final encounter = BossEncounterFactory.create(floor: 1);
      expect(encounter.enemyName, contains('재'));
      expect(encounter.introText, contains('재'));
    });

    test('2층 보스 — 무(無)의 주인', () {
      final encounter = BossEncounterFactory.create(floor: 2);
      expect(encounter.enemyName, contains('무'));
    });

    test('3층 보스 — 경(鏡)의 주인', () {
      final encounter = BossEncounterFactory.create(floor: 3);
      expect(encounter.enemyName, contains('경'));
    });

    test('4층 보스 — 안(安)의 주인', () {
      final encounter = BossEncounterFactory.create(floor: 4);
      expect(encounter.enemyName, contains('안'));
    });

    test('5층 보스 — 근(根)의 주인', () {
      final encounter = BossEncounterFactory.create(floor: 5);
      expect(encounter.enemyName, contains('근'));
    });

    test('phase1 턴 수 = combatConfig.bossTurnCountPhase1', () {
      const config = CombatBalanceConfig();
      for (var floor = 1; floor <= 5; floor++) {
        final encounter = BossEncounterFactory.create(
          floor: floor,
          combatConfig: config,
        );
        expect(
          encounter.bossPhases![0].turns.length,
          config.bossTurnCountPhase1,
          reason: 'Floor $floor phase 1',
        );
      }
    });

    test('phase2 턴 수 = combatConfig.bossTurnCountPhase2', () {
      const config = CombatBalanceConfig();
      for (var floor = 1; floor <= 5; floor++) {
        final encounter = BossEncounterFactory.create(
          floor: floor,
          combatConfig: config,
        );
        expect(
          encounter.bossPhases![1].turns.length,
          config.bossTurnCountPhase2,
          reason: 'Floor $floor phase 2',
        );
      }
    });

    test('bossId 5층 각각 고유', () {
      final ids = <String>{};
      for (var floor = 1; floor <= 5; floor++) {
        ids.add(BossEncounterFactory.bossId(floor));
      }
      expect(ids.length, 5);
    });

    test('bossId(1) = boss_ash', () {
      expect(BossEncounterFactory.bossId(1), 'boss_ash');
    });

    test('bossId(5) = boss_root', () {
      expect(BossEncounterFactory.bossId(5), 'boss_root');
    });

    test('미정의 층 → 기본 보스', () {
      final encounter = BossEncounterFactory.create(floor: 99);
      expect(encounter.enemyName, '미지의 존재');
      expect(encounter.roomType, RoomType.boss);
      expect(encounter.bossPhases!.length, 2);
    });

    test('미정의 층 bossId = boss_unknown', () {
      expect(BossEncounterFactory.bossId(99), 'boss_unknown');
    });

    test('보스 전투 구조 — victoryText/defeatText 존재', () {
      for (var floor = 1; floor <= 5; floor++) {
        final encounter = BossEncounterFactory.create(floor: floor);
        expect(encounter.victoryText, isNotEmpty, reason: 'Floor $floor');
        expect(encounter.defeatText, isNotEmpty, reason: 'Floor $floor');
      }
    });

    test('보스 전투 구조 — transitionText 존재 (phase1)', () {
      for (var floor = 1; floor <= 5; floor++) {
        final encounter = BossEncounterFactory.create(floor: floor);
        expect(
          encounter.bossPhases![0].transitionText,
          isNotNull,
          reason: 'Floor $floor',
        );
        expect(
          encounter.bossPhases![0].transitionText,
          isNotEmpty,
          reason: 'Floor $floor',
        );
      }
    });

    group('load()', () {
      test('load — invalid JSON keeps defaults', () async {
        // invalid bundle 로드 → catch에서 기본값 유지
        await BossEncounterFactory.load(bundle: _InvalidBundle());

        final encounter = BossEncounterFactory.create(floor: 1);
        expect(encounter.enemyName, contains('재'));
        expect(BossEncounterFactory.bossId(1), 'boss_ash');
      });

      test('load — valid JSON replaces defaults', () async {
        final bundle = _TestBundle();
        await BossEncounterFactory.load(bundle: bundle);

        final encounter = BossEncounterFactory.create(floor: 1);
        expect(encounter.enemyName, 'TEST 보스');
        expect(BossEncounterFactory.bossId(1), 'boss_test');
      });
    });
  });
}

class _TestBundle extends CachingAssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    return '{"bosses":[{"floor":1,"id":"boss_test","name":"TEST 보스","intro_text":"테스트 인트로","transition_text":"테스트 전환","phase2_intro_text":"테스트 페이즈2","victory_text":"테스트 승리","defeat_text":"테스트 패배","phase1_turns":[{"turn":1,"action_type":"attack","preview_text":"t1","threat_level":1},{"turn":2,"action_type":"defend","preview_text":"t2","threat_level":1},{"turn":3,"action_type":"attack","preview_text":"t3","threat_level":1}],"phase2_turns":[{"turn":1,"action_type":"attack","preview_text":"t1","threat_level":1},{"turn":2,"action_type":"attack","preview_text":"t2","threat_level":1},{"turn":3,"action_type":"observe","preview_text":"t3","threat_level":1},{"turn":4,"action_type":"attack","preview_text":"t4","threat_level":1}]}]}';
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
