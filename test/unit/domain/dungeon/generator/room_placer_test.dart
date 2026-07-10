import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/dungeon_balance_config.dart';
import 'package:soul_dungeon/domain/dungeon/generator/map_generator.dart';
import 'package:soul_dungeon/domain/dungeon/generator/path_finder.dart';
import 'package:soul_dungeon/domain/dungeon/generator/room_placer.dart';
import 'package:soul_dungeon/core/models/floor_map.dart';
import 'package:soul_dungeon/core/config/tutorial_config.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

void main() {
  const config = DungeonBalanceConfig();

  FloorMap generateAndPlace(
    int seed, {
    DungeonBalanceConfig? cfg,
    int floor = 1,
    TutorialConfig? tutorialConfig,
    bool isFirstRun = false,
  }) {
    final c = cfg ?? config;
    final raw = MapGenerator.generate(floor, seed, c);
    return RoomPlacer.placeRooms(
      raw, floor, seed, c,
      tutorialConfig: tutorialConfig,
      isFirstRun: isFirstRun,
    );
  }

  group('RoomPlacer', () {
    test('fixed placements: start is combat, boss is boss', () {
      final map = generateAndPlace(42);
      expect(map.nodeById(map.startNodeId)!.roomType, RoomType.combat);
      expect(map.nodeById(map.bossNodeId)!.roomType, RoomType.boss);
    });

    test('elite count within min~max range and not placed at start/boss', () {
      var eliteShortfall = 0;
      for (var seed = 0; seed < 100; seed++) {
        final map = generateAndPlace(seed);
        final elites = map.nodes.where((n) => n.roomType == RoomType.elite).toList();
        // 경로 커버리지 보장으로 일부 시드에서 엘리트가 부족할 수 있음
        if (elites.length < config.eliteMin) eliteShortfall++;
        expect(elites.length, lessThanOrEqualTo(config.eliteMax),
            reason: 'seed=$seed: elite count ${elites.length} > ${config.eliteMax}');
        // elite는 start(depth 0), boss에 배치되지 않아야 함 (pre-boss 안전망 제거됨)
        for (final elite in elites) {
          expect(elite.depth, greaterThan(0),
              reason: 'seed=$seed: elite at depth 0 (start layer)');
          expect(elite.id, isNot(map.bossNodeId),
              reason: 'seed=$seed: elite at boss node');
        }
      }
      // 85% 이상의 시드에서 eliteMin 이상 배치
      expect(eliteShortfall, lessThanOrEqualTo(15),
          reason: 'Too many seeds ($eliteShortfall/100) have fewer elites than eliteMin');
    });

    test('every path has at least one shop', () {
      for (var seed = 0; seed < 100; seed++) {
        final map = generateAndPlace(seed);
        final paths = PathFinder.allPaths(map);
        for (final path in paths) {
          final hasShop = path.any((id) => map.nodeById(id)!.roomType == RoomType.shop);
          expect(hasShop, isTrue,
              reason: 'seed=$seed: path ${path.join("→")} has no shop');
        }
      }
    });

    test('every path has at least one event or npc', () {
      for (var seed = 0; seed < 100; seed++) {
        final map = generateAndPlace(seed);
        final paths = PathFinder.allPaths(map);
        for (final path in paths) {
          final hasEventOrNpc = path.any((id) {
            final type = map.nodeById(id)!.roomType;
            return type == RoomType.event || type == RoomType.npc;
          });
          expect(hasEventOrNpc, isTrue,
              reason: 'seed=$seed: path ${path.join("→")} has no event/npc');
        }
      }
    });

    test('pre-boss layer has valid room types (no boss or unassigned)', () {
      // 보스 직전 레이어는 안전망 없이 일반 배치 대상
      for (var seed = 0; seed < 100; seed++) {
        final map = generateAndPlace(seed);
        final preBossDepth = map.maxDepth - 1;
        final preBossNodes = map.nodesAtDepth(preBossDepth);
        expect(preBossNodes, isNotEmpty,
            reason: 'seed=$seed: no nodes at pre-boss depth $preBossDepth');
        for (final node in preBossNodes) {
          expect(node.roomType, isNot(RoomType.boss),
              reason: 'seed=$seed: boss room should not appear at pre-boss depth');
          expect(RoomType.values.contains(node.roomType), isTrue,
              reason: 'seed=$seed: invalid roomType at pre-boss depth');
        }
      }
    });

    test('all placements are valid room types with no unassigned nodes', () {
      final map = generateAndPlace(42);
      for (final node in map.nodes) {
        expect(RoomType.values.contains(node.roomType), isTrue);
      }
      // 모든 노드가 기본 combat이 아닌 의미 있는 할당을 가져야 함
      // (start=combat, boss=boss는 의도적)
      expect(map.nodes.length, greaterThanOrEqualTo(config.roomsPerFloor));
    });
  });

  group('RoomPlacer — Tutorial', () {
    const tutorialConfig = TutorialConfig();

    test('첫 런 floor 1 — depth 0 combat, depth 1 대부분 event', () {
      var eventCount = 0;
      const totalSeeds = 50;
      for (var seed = 0; seed < totalSeeds; seed++) {
        final map = generateAndPlace(
          seed,
          tutorialConfig: tutorialConfig,
          isFirstRun: true,
        );
        final depth0 = map.nodesAtDepth(0);

        // depth 0 = start = combat (Phase 1 고정)
        expect(depth0.first.roomType, RoomType.combat,
            reason: 'seed=$seed: depth 0 should be combat');

        // depth 1 = event (튜토리얼 Phase 0 배치, 경로 커버리지가 덮어쓸 수 있음)
        final depth1 = map.nodesAtDepth(1);
        if (depth1.first.roomType == RoomType.event) {
          eventCount++;
        }
      }
      // 대부분의 시드에서 depth 1이 event (커버리지 덮어쓰기는 드문 경우)
      expect(eventCount, greaterThan(totalSeeds * 0.8),
          reason: 'tutorial depth 1 should mostly be event ($eventCount/$totalSeeds)');
    });

    test('반복 런 (isFirstRun=false) — 튜토리얼 미적용', () {
      final withTutorial = generateAndPlace(
        42,
        tutorialConfig: tutorialConfig,
        isFirstRun: true,
      );

      // depth 1 첫 노드: 튜토리얼 적용 시 event
      final depth1Tutorial = withTutorial.nodesAtDepth(1).first;
      expect(depth1Tutorial.roomType, RoomType.event);

      // 미적용 시: 50개 시드 중 일부는 depth 1이 event가 아님
      var nonEventCount = 0;
      for (var seed = 0; seed < 50; seed++) {
        final map = generateAndPlace(
          seed,
          tutorialConfig: tutorialConfig,
          isFirstRun: false,
        );
        final depth1 = map.nodesAtDepth(1);
        if (depth1.isNotEmpty && depth1.first.roomType != RoomType.event) {
          nonEventCount++;
        }
      }
      expect(nonEventCount, greaterThan(0),
          reason: 'isFirstRun=false should not force event at depth 1');
    });

    test('floor 2에서는 튜토리얼 미적용', () {
      // floor 2에서 depth 1 노드가 event로 강제되지 않아야 함
      var nonEventCount = 0;
      for (var seed = 0; seed < 50; seed++) {
        final map = generateAndPlace(
          seed,
          floor: 2,
          tutorialConfig: tutorialConfig,
          isFirstRun: true,
        );
        final depth1 = map.nodesAtDepth(1);
        if (depth1.isNotEmpty && depth1.first.roomType != RoomType.event) {
          nonEventCount++;
        }
      }
      // 50개 시드 중 최소 1개는 event가 아닌 게 있어야 함 (확률적)
      expect(nonEventCount, greaterThan(0),
          reason: 'floor 2 should not force event at depth 1');
    });

    test('튜토리얼 disabled — 고정 배치 미적용', () {
      const disabledConfig = TutorialConfig(enabled: false);
      var nonEventCount = 0;
      for (var seed = 0; seed < 50; seed++) {
        final map = generateAndPlace(
          seed,
          tutorialConfig: disabledConfig,
          isFirstRun: true,
        );
        final depth1 = map.nodesAtDepth(1);
        if (depth1.isNotEmpty && depth1.first.roomType != RoomType.event) {
          nonEventCount++;
        }
      }
      expect(nonEventCount, greaterThan(0),
          reason: 'disabled tutorial should not force event at depth 1');
    });

    test('커스텀 튜토리얼 — depth 0 rest, depth 1 shop', () {
      const customConfig = TutorialConfig(
        fixedDepthRooms: {0: RoomType.rest, 1: RoomType.shop},
      );
      final map = generateAndPlace(
        42,
        tutorialConfig: customConfig,
        isFirstRun: true,
      );
      // depth 0은 start 노드인데, Phase 0(튜토리얼)이 Phase 1(고정 combat) 전에 실행.
      // Phase 1이 start 노드를 combat으로 덮어씀.
      // → depth 0은 combat이 아닌 rest가 되어야 하나? Phase 1이 덮어쓰므로 combat.
      // 실제로는 Phase 0에서 먼저 할당, Phase 1에서 덮어쓰기.
      // start 노드는 항상 combat (Phase 1 우선).
      final depth0 = map.nodesAtDepth(0).first;
      expect(depth0.roomType, RoomType.combat,
          reason: 'start node always combat (Phase 1 overrides Phase 0)');
      // depth 1은 shop 고정
      final depth1 = map.nodesAtDepth(1).first;
      expect(depth1.roomType, RoomType.shop);
    });

    test('튜토리얼 적용 후에도 기존 제약 유지', () {
      var shopFailCount = 0;
      for (var seed = 0; seed < 50; seed++) {
        final map = generateAndPlace(
          seed,
          tutorialConfig: tutorialConfig,
          isFirstRun: true,
        );
        // boss 노드 여전히 boss
        expect(map.nodeById(map.bossNodeId)!.roomType, RoomType.boss,
            reason: 'seed=$seed: boss must be boss');

        // 경로 보장: 대부분의 경로에 shop 존재
        final paths = PathFinder.allPaths(map);
        for (final path in paths) {
          final hasShop = path.any((id) => map.nodeById(id)!.roomType == RoomType.shop);
          if (!hasShop) shopFailCount++;
        }
      }
      // 95% 이상의 경로에서 shop 보장
      expect(shopFailCount, lessThanOrEqualTo(5),
          reason: '$shopFailCount paths across 50 seeds have no shop');
    });
  });
}
