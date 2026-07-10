
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_models.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/combat_demo_encounter.dart';

void main() {
  group('CombatDemoEncounter', () {
    test('creates encounter with RoomType.combat and 3 turns', () {
      final encounter = CombatDemoEncounter.create();

      expect(encounter.roomType, RoomType.combat);
      expect(encounter.turns.length, 3);
      expect(encounter.enemyName, isNotEmpty);
      expect(encounter.introText, isNotEmpty);
      expect(encounter.victoryText, isNotEmpty);
      expect(encounter.defeatText, isNotEmpty);
      expect(encounter.environmentClues.length, 1);
    });

    test('enemy action distribution: 2 attack, 1 defend', () {
      final encounter = CombatDemoEncounter.create();

      final actionCounts = <EnemyActionType, int>{};
      for (final turn in encounter.turns) {
        actionCounts[turn.enemyAction.type] =
            (actionCounts[turn.enemyAction.type] ?? 0) + 1;
      }

      expect(actionCounts[EnemyActionType.attack], 2);
      expect(actionCounts[EnemyActionType.defend], 1);
    });

    test('no bossPhases (not a boss encounter)', () {
      final encounter = CombatDemoEncounter.create();

      expect(encounter.bossPhases, isNull);
    });

    test('each turn has unique turnNumber', () {
      final encounter = CombatDemoEncounter.create();

      final turnNumbers = encounter.turns.map((t) => t.turnNumber).toSet();
      expect(turnNumbers.length, encounter.turns.length);
    });

    test('environment clue has required fields', () {
      final encounter = CombatDemoEncounter.create();

      for (final clue in encounter.environmentClues) {
        expect(clue.id, isNotEmpty);
        expect(clue.description, isNotEmpty);
        expect(clue.actionHint, isNotEmpty);
      }
    });

    group('load()', () {
      test('load — valid JSON replaces defaults', () async {
        final bundle = _TestBundle();
        await CombatDemoEncounter.load(bundle: bundle);

        final encounter = CombatDemoEncounter.create();
        expect(encounter.enemyName, 'TEST 적');
        expect(encounter.introText, contains('TEST'));

        // 복원: invalid bundle로 로드 → 기본값 폴백
        await CombatDemoEncounter.load(bundle: _InvalidBundle());
      });

      test('load — invalid JSON keeps defaults', () async {
        // 기본값 상태의 결과 기록
        final before = CombatDemoEncounter.create();

        await CombatDemoEncounter.load(bundle: _InvalidBundle());

        final after = CombatDemoEncounter.create();
        expect(after.enemyName, before.enemyName);
        expect(after.enemyName, '떠도는 망령');
      });
    });
  });
}

class _TestBundle extends CachingAssetBundle {
  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    return '{"combat":{"enemy_name":"TEST 적","intro_text":"TEST 인트로","victory_text":"TEST 승리","defeat_text":"TEST 패배","turns":[{"turn":1,"action_type":"attack","preview_text":"TEST t1","threat_level":1},{"turn":2,"action_type":"defend","preview_text":"TEST t2","threat_level":1},{"turn":3,"action_type":"attack","preview_text":"TEST t3","threat_level":1}]}}';
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
