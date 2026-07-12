import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:soul_dungeon/core/logging/game_logger.dart';
import 'package:soul_dungeon/core/models/relic_data.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 유물 풀 — 게임 내 모든 유물 정의.
///
/// JSON 에셋(assets/content/relics.json)에서 로드. 실패 시 기본값 폴백.
class RelicPool {
  RelicPool._();

  static List<RelicData> _items = _defaults;

  /// 현재 로드된 유물 전체 목록.
  static List<RelicData> get relics => _items;

  /// JSON 에셋에서 로드. 실패 시 기본값 폴백.
  static Future<void> load({
    AssetBundle? bundle,
    String path = 'assets/content/relics.json',
  }) async {
    try {
      final assetBundle = bundle ?? rootBundle;
      final jsonString = await assetBundle.loadString(path);
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final items = (json['relics'] as List)
          .map((e) => RelicData.fromJson(e as Map<String, dynamic>))
          .toList();
      _items = items;
      GameLogger.info(LogSystem.core, 'RelicPool loaded: ${_items.length} relics');
    } catch (e) {
      GameLogger.error(LogSystem.core, 'Failed to load relics.json, using defaults', e);
      _items = _defaults;
    }
  }

  // ── 기본값 (JSON 로드 실패 시 폴백) ──

  static const _defaults = <RelicData>[
    // === 일반 유물 (common) ===
    RelicData(id: 'relic_001', name: '녹슨 부적', description: '전투 시작 시 야성 5 회복', rarity: Rarity.common, conditionType: 'combatStart', passiveEffect: 'momentumGain', effectValue: 5),
    RelicData(id: 'relic_002', name: '치유의 돌', description: '방 이동 시 HP 2 회복', rarity: Rarity.common, conditionType: 'roomEnter', passiveEffect: 'hpRegen', effectValue: 2),
    RelicData(id: 'relic_003', name: '행운의 동전', description: '전투 승리 시 골드 5 추가 획득', rarity: Rarity.common, conditionType: 'combatEnd', passiveEffect: 'goldBonus', effectValue: 5),
    RelicData(id: 'relic_004', name: '강화 가죽', description: '전투 시작 시 블록 3 획득', rarity: Rarity.common, conditionType: 'combatStart', passiveEffect: 'defenseBonus', effectValue: 3),
    // === 희귀 유물 (rare) ===
    RelicData(id: 'relic_005', name: '바람의 깃털', description: '야성 60 이상일 때 공격력 8 증가', rarity: Rarity.rare, conditionType: 'momentumThreshold', passiveEffect: 'attackBonus', effectValue: 8),
    RelicData(id: 'relic_006', name: '치유의 샘물', description: '층 이동 시 HP 10 회복', rarity: Rarity.rare, conditionType: 'floorTransition', passiveEffect: 'hpRegen', effectValue: 10),
    RelicData(id: 'relic_007', name: '탐험가의 나침반', description: '방 이동 시 야성 3 회복', rarity: Rarity.rare, conditionType: 'roomEnter', passiveEffect: 'momentumGain', effectValue: 3),
    RelicData(id: 'relic_008', name: '고대 주화 주머니', description: '전투 승리 시 골드 10 추가 획득', rarity: Rarity.rare, conditionType: 'combatEnd', passiveEffect: 'goldBonus', effectValue: 10),
    // === 전설 유물 (legendary) ===
    RelicData(id: 'relic_009', name: '불사조의 깃털', description: 'HP 20% 이하일 때 피해 15 감소', rarity: Rarity.legendary, conditionType: 'hpThreshold', passiveEffect: 'damageReduction', effectValue: 15),
    RelicData(id: 'relic_010', name: '고대의 반지', description: '전투 시작 시 야성 15 회복', rarity: Rarity.legendary, conditionType: 'combatStart', passiveEffect: 'momentumGain', effectValue: 15),
    // === 추가 희귀 유물 ===
    RelicData(id: 'relic_011', name: '모험가의 지도', description: '미스터리 방 결과 2개 중 선택', rarity: Rarity.rare, conditionType: 'mysteryRoom', passiveEffect: 'mysteryChoice', effectValue: 2),
    RelicData(id: 'relic_012', name: '장인의 망치', description: '상점 카드 업그레이드 비용 -50%', rarity: Rarity.rare, conditionType: 'shop', passiveEffect: 'upgradeDiscount', effectValue: 50),
    // === 추가 전설 유물 ===
    RelicData(id: 'relic_013', name: '차원의 주머니', description: '상점 카드 제거 비용 무료 (1회/층)', rarity: Rarity.legendary, conditionType: 'shop', passiveEffect: 'freeRemoval', effectValue: 1),
    RelicData(id: 'relic_014', name: '영원의 심장', description: '매 층 시작 시 최대HP +3', rarity: Rarity.legendary, conditionType: 'floorTransition', passiveEffect: 'maxHpPerFloor', effectValue: 3),
  ];

  /// ID로 유물 조회.
  static RelicData? findById(String id) {
    for (final r in relics) {
      if (r.id == id) return r;
    }
    return null;
  }

  /// 유물 ID 목록 → RelicData 목록 (존재하는 것만).
  static List<RelicData> resolveIds(List<String> ids) {
    return ids.map(findById).whereType<RelicData>().toList();
  }

  /// 희귀도별 유물 필터.
  static List<RelicData> byRarity(Rarity rarity) {
    return relics.where((r) => r.rarity == rarity).toList();
  }
}
