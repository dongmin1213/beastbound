import 'dart:math';

import 'package:soul_dungeon/core/config/dungeon_balance_config.dart';
import 'package:soul_dungeon/domain/dungeon/generator/path_finder.dart';
import 'package:soul_dungeon/core/models/floor_map.dart';
import 'package:soul_dungeon/core/config/tutorial_config.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 맵 노드에 방 유형을 배치하는 순수 함수 클래스.
/// DFS(PathFinder)로 경로 커버리지 확인.
class RoomPlacer {
  RoomPlacer._();

  static FloorMap placeRooms(
    FloorMap map,
    int floor,
    int seed,
    DungeonBalanceConfig config, {
    TutorialConfig? tutorialConfig,
    bool isFirstRun = false,
  }) {
    final floorSeed = (seed.hashCode ^ (floor * 0x517CC1B7)) & 0x7FFFFFFF;
    final random = Random(floorSeed);
    final maxDepth = map.maxDepth;

    final typeMap = <String, RoomType>{};
    final fixedIds = <String>{map.startNodeId, map.bossNodeId};

    // Phase 0: 튜토리얼 고정 배치 (첫 런 floor 1)
    // tutorialIds는 엘리트 배치에서만 보호, 경로 커버리지에서는 덮어쓰기 허용
    final tutorialIds = <String>{};
    if (tutorialConfig != null &&
        tutorialConfig.appliesTo(floor: floor, isFirstRun: isFirstRun)) {
      for (final entry in tutorialConfig.fixedDepthRooms.entries) {
        final depth = entry.key;
        final roomType = entry.value;
        final nodesAtDepth = map.nodesAtDepth(depth);
        if (nodesAtDepth.isNotEmpty) {
          final node = nodesAtDepth.first;
          typeMap[node.id] = roomType;
          tutorialIds.add(node.id);
        }
      }
    }

    // Phase 1: 고정 배치
    typeMap[map.startNodeId] = RoomType.combat;
    typeMap[map.bossNodeId] = RoomType.boss;

    // Phase 2: 보스 직전 레이어 — 안전망 없이 일반 배치 대상으로 편입
    final preBossNodes = map.nodesAtDepth(maxDepth - 1);
    final preBossIds = <String>{};
    for (final node in preBossNodes) {
      preBossIds.add(node.id);
    }

    // Phase 3: 엘리트 배치
    // effectiveEliteMinDepth: eliteMinDepth가 pre-boss depth 이상이면 낮춤
    final effectiveEliteMinDepth =
        config.eliteMinDepth >= maxDepth - 1 && maxDepth > 2
            ? max(1, maxDepth - 2)
            : config.eliteMinDepth;
    final eliteCount = config.eliteMin +
        (config.eliteMax > config.eliteMin
            ? random.nextInt(config.eliteMax - config.eliteMin + 1)
            : 0);
    final eliteCandidates = map.nodes
        .where((n) =>
            n.depth >= effectiveEliteMinDepth &&
            !fixedIds.contains(n.id) &&
            !tutorialIds.contains(n.id) &&
            !preBossIds.contains(n.id) &&
            !typeMap.containsKey(n.id))
        .toList();

    final elitesToPlace = min(eliteCount, eliteCandidates.length);
    eliteCandidates.shuffle(random);
    for (var i = 0; i < elitesToPlace; i++) {
      typeMap[eliteCandidates[i].id] = RoomType.elite;
    }

    // Phase 4: 경로 보장 — 반복 수렴 방식
    // shop/event/rest 모두 충족할 때까지 반복 (최대 3회)
    final ctx = _PlacementContext(
      map: map,
      typeMap: typeMap,
      fixedIds: fixedIds,
      preBossIds: preBossIds,
      allPaths: PathFinder.allPaths(map),
      random: random,
    );
    for (var pass = 0; pass < 3; pass++) {
      _ensureCoverage(ctx,
          (t) => t == RoomType.shop, RoomType.shop, RoomType.shop);
      _ensureCoverage(ctx,
          (t) => t == RoomType.event || t == RoomType.npc, RoomType.event, RoomType.npc);
      _ensureCoverage(ctx,
          (t) => t == RoomType.rest, RoomType.rest, RoomType.rest);

      // 수렴 확인
      if (_allPathsCovered(ctx, (t) => t == RoomType.shop) &&
          _allPathsCovered(ctx, (t) => t == RoomType.event || t == RoomType.npc) &&
          _allPathsCovered(ctx, (t) => t == RoomType.rest)) {
        break;
      }
    }

    // 수렴 실패 시 강제 배치 — shop/event/rest 서로 보호하며 강제 배치
    _rescueCoverage(ctx, (t) => t == RoomType.shop, RoomType.shop,
        {RoomType.event, RoomType.npc, RoomType.rest});
    _rescueCoverage(
        ctx,
        (t) => t == RoomType.event || t == RoomType.npc,
        RoomType.event,
        {RoomType.shop, RoomType.rest});
    _rescueCoverage(ctx, (t) => t == RoomType.rest, RoomType.rest,
        {RoomType.shop, RoomType.event, RoomType.npc});

    // Phase 4b: 경로별 최소 이벤트 수 보장 (전직 기회)
    if (config.minEventsPerPath > 1) {
      _ensureMinEvents(ctx, config.minEventsPerPath);
    }

    // Phase 4.5: 엘리트 보충 — 경로 보장으로 덮어쓴 엘리트 복구
    var currentElites =
        typeMap.values.where((t) => t == RoomType.elite).length;
    if (currentElites < config.eliteMin) {
      var deficit = config.eliteMin - currentElites;

      // 1차: 미할당 노드에서 보충
      final unassignedElite = map.nodes
          .where((n) =>
              n.depth >= effectiveEliteMinDepth &&
              !fixedIds.contains(n.id) &&
              !tutorialIds.contains(n.id) &&
              !preBossIds.contains(n.id) &&
              !typeMap.containsKey(n.id))
          .toList();
      unassignedElite.shuffle(random);
      final fromUnassigned = min(deficit, unassignedElite.length);
      for (var i = 0; i < fromUnassigned; i++) {
        typeMap[unassignedElite[i].id] = RoomType.elite;
      }
      deficit -= fromUnassigned;

      // 2차: combat/mystery 노드 덮어쓰기 (경로 보장 타입은 보호)
      if (deficit > 0) {
        final overwriteElite = map.nodes
            .where((n) =>
                n.depth >= effectiveEliteMinDepth &&
                !fixedIds.contains(n.id) &&
                !tutorialIds.contains(n.id) &&
                !preBossIds.contains(n.id) &&
                (typeMap[n.id] == RoomType.combat ||
                    typeMap[n.id] == RoomType.mystery))
            .toList();
        overwriteElite.shuffle(random);
        final fromOverwrite = min(deficit, overwriteElite.length);
        for (var i = 0; i < fromOverwrite; i++) {
          typeMap[overwriteElite[i].id] = RoomType.elite;
        }
      }
    }

    // Phase 5: 잔여 노드 — config 가중치 랜덤
    for (final node in map.nodes) {
      if (!typeMap.containsKey(node.id)) {
        typeMap[node.id] = _weightedRandom(random, config);
      }
    }

    final newNodes = map.nodes.map((n) {
      return n.copyWith(roomType: typeMap[n.id]!);
    }).toList();

    return FloorMap(
      floorNumber: map.floorNumber,
      seed: map.seed,
      nodes: List.unmodifiable(newNodes),
      startNodeId: map.startNodeId,
      bossNodeId: map.bossNodeId,
    );
  }

  static bool _allPathsCovered(
    _PlacementContext ctx,
    bool Function(RoomType) check,
  ) {
    return ctx.allPaths.every((path) => path.any((id) {
          final t = ctx.typeMap[id];
          return t != null && check(t);
        }));
  }

  static void _ensureCoverage(
    _PlacementContext ctx,
    bool Function(RoomType) coverCheck,
    RoomType placeType,
    RoomType preBossPlaceType,
  ) {
    for (final path in ctx.allPaths) {
      if (path.any((id) {
        final t = ctx.typeMap[id];
        return t != null && coverCheck(t);
      })) {
        continue;
      }

      final candidates = path.where((id) => !ctx.fixedIds.contains(id)).toList();

      // 1순위: 미할당
      final unassigned = candidates.where((id) => !ctx.typeMap.containsKey(id)).toList();
      if (unassigned.isNotEmpty) {
        ctx.typeMap[unassigned[ctx.random.nextInt(unassigned.length)]] = placeType;
        continue;
      }

      // 2순위: 비preBoss 비엘리트 비shop 비event 노드 (combat/mystery만)
      final overwriteSafe = candidates
          .where((id) =>
              !ctx.preBossIds.contains(id) &&
              ctx.typeMap[id] != RoomType.elite &&
              ctx.typeMap[id] != RoomType.shop &&
              ctx.typeMap[id] != RoomType.event &&
              ctx.typeMap[id] != RoomType.npc)
          .toList();
      if (overwriteSafe.isNotEmpty) {
        ctx.typeMap[overwriteSafe[ctx.random.nextInt(overwriteSafe.length)]] = placeType;
        continue;
      }

      // 3순위: pre-boss 노드 변경 (valid pre-boss type 사용)
      final preBoss = candidates.where((id) => ctx.preBossIds.contains(id)).toList();
      if (preBoss.isNotEmpty) {
        ctx.typeMap[preBoss[ctx.random.nextInt(preBoss.length)]] = preBossPlaceType;
        continue;
      }

      // 4순위: 엘리트 덮어쓰기
      final elite = candidates.where((id) => ctx.typeMap[id] == RoomType.elite).toList();
      if (elite.isNotEmpty) {
        ctx.typeMap[elite[ctx.random.nextInt(elite.length)]] = placeType;
      }
    }
  }

  /// 수렴 실패 시 강제 배치 — 남은 위반 경로에 대해 non-fixed 노드 중
  /// 다른 커버리지 타입을 보호하면서 덮어쓰기.
  static void _rescueCoverage(
    _PlacementContext ctx,
    bool Function(RoomType) coverCheck,
    RoomType placeType,
    Set<RoomType> protectedTypes,
  ) {
    for (final path in ctx.allPaths) {
      if (path.any((id) {
        final t = ctx.typeMap[id];
        return t != null && coverCheck(t);
      })) {
        continue;
      }

      final candidates = path.where((id) => !ctx.fixedIds.contains(id)).toList();
      // 1순위: 보호 타입이 아닌 노드
      final safe = candidates
          .where((id) => !protectedTypes.contains(ctx.typeMap[id]))
          .toList();
      if (safe.isNotEmpty) {
        ctx.typeMap[safe[ctx.random.nextInt(safe.length)]] = placeType;
        continue;
      }
      // 2순위: 아무 노드나 (최후 수단)
      if (candidates.isNotEmpty) {
        ctx.typeMap[candidates[ctx.random.nextInt(candidates.length)]] = placeType;
      }
    }
  }

  /// 경로별 최소 이벤트+NPC 수를 보장.
  /// 전직에 필요한 성향 포인트를 얻을 기회를 확보.
  /// NPC도 성향 변화에 기여하므로 event+NPC 합산 카운트.
  static void _ensureMinEvents(
    _PlacementContext ctx,
    int minEvents,
  ) {
    for (final path in ctx.allPaths) {
      var eventNpcCount = path.where((id) {
        final t = ctx.typeMap[id];
        return t == RoomType.event || t == RoomType.npc;
      }).length;

      while (eventNpcCount < minEvents) {
        final candidates = path
            .where((id) =>
                !ctx.fixedIds.contains(id) &&
                !ctx.preBossIds.contains(id) &&
                ctx.typeMap[id] != RoomType.elite &&
                ctx.typeMap[id] != RoomType.shop &&
                ctx.typeMap[id] != RoomType.event &&
                ctx.typeMap[id] != RoomType.npc)
            .toList();

        if (candidates.isEmpty) break;

        // 1순위: 미할당 노드
        final unassigned =
            candidates.where((id) => !ctx.typeMap.containsKey(id)).toList();
        if (unassigned.isNotEmpty) {
          ctx.typeMap[unassigned[ctx.random.nextInt(unassigned.length)]] =
              RoomType.event;
          eventNpcCount++;
          continue;
        }

        // 2순위: combat/mystery 덮어쓰기
        final overwritable = candidates
            .where((id) =>
                ctx.typeMap[id] == RoomType.combat ||
                ctx.typeMap[id] == RoomType.mystery)
            .toList();
        if (overwritable.isNotEmpty) {
          ctx.typeMap[overwritable[ctx.random.nextInt(overwritable.length)]] =
              RoomType.event;
          eventNpcCount++;
          continue;
        }

        break;
      }
    }
  }

  static RoomType _weightedRandom(Random random, DungeonBalanceConfig config) {
    final total = config.combatWeight + config.mysteryWeight + config.eventWeight;
    final roll = random.nextInt(total > 0 ? total : 100);
    if (roll < config.combatWeight) return RoomType.combat;
    if (roll < config.combatWeight + config.mysteryWeight) return RoomType.mystery;
    return RoomType.event;
  }
}

/// 방 배치 과정의 공유 상태를 묶는 컨텍스트.
class _PlacementContext {
  final FloorMap map;
  final Map<String, RoomType> typeMap;
  final Set<String> fixedIds;
  final Set<String> preBossIds;
  final List<List<String>> allPaths;
  final Random random;

  const _PlacementContext({
    required this.map,
    required this.typeMap,
    required this.fixedIds,
    required this.preBossIds,
    required this.allPaths,
    required this.random,
  });
}
