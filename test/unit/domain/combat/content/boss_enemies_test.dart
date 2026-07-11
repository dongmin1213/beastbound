import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/floor_region.dart';
import 'package:soul_dungeon/domain/combat/content/boss_enemies.dart';
import 'package:soul_dungeon/domain/combat/models/boss_combat_data.dart';

void main() {
  group('BossEnemies', () {
    test('전체 15보스', () {
      expect(BossEnemies.all.length, 15);
    });

    test('모든 ID 고유', () {
      final ids = BossEnemies.all.map((b) => b.id).toSet();
      expect(ids.length, 15);
    });

    test('층별 보스 조회 (10층, 지역 매핑)', () {
      for (int floor = 1; floor <= FloorRegion.totalFloors; floor++) {
        final boss = BossEnemies.forFloor(floor);
        expect(boss, isNotNull, reason: 'Floor $floor should have a boss');
        // boss.floor 필드는 지역(1~5)을 뜻한다.
        expect(boss!.floor, FloorRegion.of(floor));
      }
    });

    test('짝수층 = 지역 주인, 홀수층 = 하위 주인', () {
      // 폐허(1·2): 2층 = 주인(슬라임 왕), 1층 = 하위 주인
      expect(BossEnemies.forFloor(2)!.id, BossEnemies.slimeKing.id);
      expect(BossEnemies.forFloor(1)!.id, isNot(BossEnemies.slimeKing.id));
      // 심연(9·10): 10층 = 태초의 주인
      expect(BossEnemies.forFloor(10)!.id, BossEnemies.dungeonMaster.id);
    });

    test('범위 밖 층은 지역으로 클램프 (non-null)', () {
      expect(BossEnemies.forFloor(0), isNotNull);
      expect(BossEnemies.forFloor(11), isNotNull);
    });

    group('슬라임 왕 (1층)', () {
      test('2페이즈', () {
        expect(BossEnemies.slimeKing.totalPhases, 2);
      });

      test('Phase 1 HP=60', () {
        expect(BossEnemies.slimeKing.phaseAt(0).hp, 60);
      });

      test('Phase 2 기믹=regen', () {
        expect(BossEnemies.slimeKing.phaseAt(1).gimmick, BossGimmick.regen);
      });
    });

    group('거미 군주 (2층)', () {
      test('2페이즈', () {
        expect(BossEnemies.spiderLord.totalPhases, 2);
      });

      test('Phase 1 기믹=web', () {
        expect(BossEnemies.spiderLord.phaseAt(0).gimmick, BossGimmick.web);
      });

      test('Phase 2 ATK > Phase 1 (광란)', () {
        expect(
          BossEnemies.spiderLord.phaseAt(1).atk >
              BossEnemies.spiderLord.phaseAt(0).atk,
          true,
        );
      });
    });

    group('오크 대장군 (3층)', () {
      test('Phase 1 HP=100', () {
        expect(BossEnemies.orcGeneral.phaseAt(0).hp, 100);
      });

      test('Phase 2 기믹=rage', () {
        expect(BossEnemies.orcGeneral.phaseAt(1).gimmick, BossGimmick.rage);
      });
    });

    group('뱀파이어 군주 (4층)', () {
      test('Phase 1 기믹=drain', () {
        expect(BossEnemies.vampireLord.phaseAt(0).gimmick, BossGimmick.drain);
      });

      test('Phase 2 기믹=drain', () {
        expect(BossEnemies.vampireLord.phaseAt(1).gimmick, BossGimmick.drain);
      });
    });

    group('태초의 주인 (5층)', () {
      test('3페이즈', () {
        expect(BossEnemies.dungeonMaster.totalPhases, 3);
      });

      test('Phase 1 HP=110', () {
        expect(BossEnemies.dungeonMaster.phaseAt(0).hp, 110);
      });

      test('Phase 2 HP=90', () {
        expect(BossEnemies.dungeonMaster.phaseAt(1).hp, 90);
      });

      test('Phase 3 HP=60', () {
        expect(BossEnemies.dungeonMaster.phaseAt(2).hp, 60);
      });

      test('모든 페이즈 기믹=formShift', () {
        for (final phase in BossEnemies.dungeonMaster.phases) {
          expect(phase.gimmick, BossGimmick.formShift);
        }
      });
    });

    test('모든 보스는 최소 2페이즈', () {
      for (final boss in BossEnemies.all) {
        expect(boss.totalPhases >= 2, true,
            reason: '${boss.name} should have >= 2 phases');
      }
    });

    test('모든 페이즈는 양수 HP/ATK', () {
      for (final boss in BossEnemies.all) {
        for (int i = 0; i < boss.totalPhases; i++) {
          final phase = boss.phaseAt(i);
          expect(phase.hp > 0, true,
              reason: '${boss.name} phase $i HP should be > 0');
          expect(phase.atk > 0, true,
              reason: '${boss.name} phase $i ATK should be > 0');
        }
      }
    });

    test('모든 페이즈는 최소 1개 패턴', () {
      for (final boss in BossEnemies.all) {
        for (int i = 0; i < boss.totalPhases; i++) {
          expect(boss.phaseAt(i).pattern.isNotEmpty, true,
              reason: '${boss.name} phase $i should have pattern');
        }
      }
    });
  });
}
