import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:soul_dungeon/core/logging/game_logger.dart';
import 'package:soul_dungeon/core/models/blessing_data.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 축복 풀 — 게임 내 모든 런레벨 축복 정의.
///
/// JSON 에셋(assets/content/blessings.json)에서 로드. 실패 시 기본값 폴백.
class BlessingPool {
  BlessingPool._();

  static List<BlessingData> _items = _defaults;

  /// 현재 로드된 축복 전체 목록.
  static List<BlessingData> get blessings => _items;

  /// JSON 에셋에서 로드. 실패 시 기본값 폴백.
  static Future<void> load({
    AssetBundle? bundle,
    String path = 'assets/content/blessings.json',
  }) async {
    try {
      final assetBundle = bundle ?? rootBundle;
      final jsonString = await assetBundle.loadString(path);
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final items = (json['blessings'] as List)
          .map((e) => BlessingData.fromJson(e as Map<String, dynamic>))
          .toList();
      _items = items;
      GameLogger.info(LogSystem.core, 'BlessingPool loaded: ${_items.length} blessings');
    } catch (e) {
      GameLogger.error(LogSystem.core, 'Failed to load blessings.json, using defaults', e);
      _items = _defaults;
    }
  }

  // ── 기본값 (JSON 로드 실패 시 폴백) ──

  static const _defaults = <BlessingData>[
    // 기본 축복 (상점 공통)
    BlessingData(id: 'blessing_001', name: '힘의 축복', description: '전투 시작 시 힘 +1', rarity: Rarity.common, effectType: 'attackBonus', effectValue: 1),
    BlessingData(id: 'blessing_002', name: '방어의 축복', description: '전투 시작 시 블록 +3', rarity: Rarity.common, effectType: 'defenseBonus', effectValue: 3),
    BlessingData(id: 'blessing_003', name: '속도의 축복', description: '전투 시작 시 드로우 +1', rarity: Rarity.common, effectType: 'bonusDraw', effectValue: 1),
    BlessingData(id: 'blessing_004', name: '생명의 축복', description: '전투 시작 시 HP 5 회복', rarity: Rarity.common, effectType: 'healOnCombatStart', effectValue: 5),
    // 희귀 축복 (상점)
    BlessingData(id: 'blessing_005', name: '기세의 축복', description: '전투 시작 시 기세 +10', rarity: Rarity.rare, effectType: 'momentumOnCombatStart', effectValue: 10),
    BlessingData(id: 'blessing_006', name: '회피의 축복', description: '첫 피격 시 데미지 50% 감소', rarity: Rarity.rare, effectType: 'firstHitReduction', effectValue: 50),
    BlessingData(id: 'blessing_007', name: '집중의 축복', description: '전투 시작 시 AP +1 (첫 턴만)', rarity: Rarity.rare, effectType: 'bonusApFirstTurn', effectValue: 1),
    BlessingData(id: 'blessing_008', name: '재생의 축복', description: '매 턴 시작 시 HP 2 회복', rarity: Rarity.rare, effectType: 'healPerTurn', effectValue: 2),
    // NPC 전용 축복
    BlessingData(id: 'npc_blessing_001', name: '은둔자의 부적', description: '전투 시작 시 블록 +2', rarity: Rarity.rare, effectType: 'defenseBonus', effectValue: 2),
    BlessingData(id: 'npc_blessing_002', name: '여행자의 부적', description: '전투 시작 시 기세 +5', rarity: Rarity.rare, effectType: 'momentumBonus', effectValue: 5),
    BlessingData(id: 'npc_blessing_003', name: '전사의 완장', description: '전투 시작 시 힘 +1', rarity: Rarity.rare, effectType: 'attackBonus', effectValue: 1),
    BlessingData(id: 'npc_blessing_004', name: '치유의 부적', description: '전투 시작 시 HP 3 회복', rarity: Rarity.rare, effectType: 'healBonus', effectValue: 3),
    BlessingData(id: 'npc_blessing_005', name: '행운의 동전', description: '전투 시작 시 카드 1장 추가 드로우', rarity: Rarity.rare, effectType: 'bonusDraw', effectValue: 1),
    BlessingData(id: 'npc_blessing_006', name: '인내의 반지', description: '블록 25% 다음 턴 유지', rarity: Rarity.rare, effectType: 'retainBlock', effectValue: 25),
    // 악마의 축복 (devil deal 전용)
    BlessingData(id: 'devil_blessing_001', name: '피의 계약', description: '전투 시작 시 힘 +3', rarity: Rarity.cursed, effectType: 'attackBonus', effectValue: 3),
    BlessingData(id: 'devil_blessing_002', name: '그림자 갑옷', description: '전투 시작 시 블록 +5', rarity: Rarity.cursed, effectType: 'defenseBonus', effectValue: 5),
    BlessingData(id: 'devil_blessing_003', name: '심연의 눈', description: '전투 시작 시 기세 +10', rarity: Rarity.cursed, effectType: 'momentumBonus', effectValue: 10),
    BlessingData(id: 'devil_blessing_004', name: '광기의 힘', description: '전투 시작 시 힘 +2, 블록 +3', rarity: Rarity.cursed, effectType: 'attackAndDefenseBonus', effectValue: 2),
  ];

  /// ID로 축복 조회. 없으면 null.
  static BlessingData? findById(String id) {
    for (final b in blessings) {
      if (b.id == id) return b;
    }
    return null;
  }

  /// 상점 전용 축복 (NPC/악마 축복 제외).
  static List<BlessingData> get shopBlessings =>
      blessings.where((b) => b.id.startsWith('blessing_')).toList();

  /// 축복 ID 목록 → BlessingData 목록 (존재하는 것만).
  static List<BlessingData> resolveIds(List<String> ids) {
    return ids.map(findById).whereType<BlessingData>().toList();
  }
}
