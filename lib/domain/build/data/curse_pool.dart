import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:soul_dungeon/core/logging/game_logger.dart';
import 'package:soul_dungeon/core/models/blessing_data.dart';
import 'package:soul_dungeon/core/models/curse_data.dart';
import 'package:soul_dungeon/core/models/devil_deal_data.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 저주 풀 + 악마의 거래 페어링 정의.
///
/// JSON 에셋(assets/content/curses.json)에서 로드. 실패 시 기본값 폴백.
class CursePool {
  CursePool._();

  static List<CurseData> _curseItems = _defaultCurses;
  static List<BlessingData> _devilBlessingItems = _defaultDevilBlessings;
  static List<DevilDealData> _dealItems = _defaultDeals;

  /// 현재 로드된 저주 전체 목록.
  static List<CurseData> get curses => _curseItems;

  /// 현재 로드된 악마 축복 전체 목록.
  static List<BlessingData> get devilBlessings => _devilBlessingItems;

  /// 현재 로드된 악마 거래 전체 목록.
  static List<DevilDealData> get deals => _dealItems;

  /// JSON 에셋에서 로드. 실패 시 기본값 폴백.
  static Future<void> load({
    AssetBundle? bundle,
    String path = 'assets/content/curses.json',
  }) async {
    try {
      final assetBundle = bundle ?? rootBundle;
      final jsonString = await assetBundle.loadString(path);
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      _curseItems = (json['curses'] as List)
          .map((e) => CurseData.fromJson(e as Map<String, dynamic>))
          .toList();
      _devilBlessingItems = (json['devil_blessings'] as List)
          .map((e) => BlessingData.fromJson(e as Map<String, dynamic>))
          .toList();
      _dealItems = (json['devil_deals'] as List)
          .map((e) => DevilDealData.fromJson(e as Map<String, dynamic>))
          .toList();
      GameLogger.info(LogSystem.core,
          'CursePool loaded: ${_curseItems.length} curses, '
          '${_devilBlessingItems.length} devil blessings, '
          '${_dealItems.length} deals');
    } catch (e) {
      GameLogger.error(LogSystem.core, 'Failed to load curses.json, using defaults', e);
      _curseItems = _defaultCurses;
      _devilBlessingItems = _defaultDevilBlessings;
      _dealItems = _defaultDeals;
    }
  }

  // ── 기본값 (JSON 로드 실패 시 폴백) ──

  static const _defaultCurses = <CurseData>[
    CurseData(id: 'curse_001', name: '약화', description: '최대 HP 10% 감소', effectType: 'maxHpPenalty', effectValue: 10),
    CurseData(id: 'curse_002', name: '둔감', description: '야성 획득량 20% 감소', effectType: 'momentumGainPenalty', effectValue: 20),
    CurseData(id: 'curse_003', name: '불운', description: '상점 가격 15% 상승', effectType: 'shopPricePenalty', effectValue: 15),
    CurseData(id: 'curse_004', name: '적의', description: '적 공격력 10% 증가', effectType: 'enemyDamageBonus', effectValue: 10),
    CurseData(id: 'curse_005', name: '혼란', description: '서술자 신뢰도 감소', effectType: 'narratorReliabilityPenalty', effectValue: 15),
    CurseData(id: 'curse_006', name: '소모', description: '야성 감쇠 속도 50% 증가', effectType: 'momentumDecayPenalty', effectValue: 50),
    CurseData(id: 'curse_007', name: '무거운 발', description: '매 전투 드로우 -1', effectType: 'drawPenalty', effectValue: 1),
    CurseData(id: 'curse_008', name: '저주받은 손', description: '첫 턴 AP -1', effectType: 'firstTurnApPenalty', effectValue: 1),
    CurseData(id: 'curse_009', name: '그림자 추적', description: '매 전투 시작 시 HP -3', effectType: 'combatStartHpLoss', effectValue: 3),
    CurseData(id: 'curse_010', name: '망각', description: '카드 업그레이드 비용 +50%', effectType: 'upgradeCostIncrease', effectValue: 50),
  ];

  static const _defaultDevilBlessings = <BlessingData>[
    BlessingData(id: 'devil_blessing_001', name: '피의 계약', description: '전투 시작 시 힘 +3', rarity: Rarity.cursed, effectType: 'attackBonus', effectValue: 3),
    BlessingData(id: 'devil_blessing_002', name: '그림자 갑옷', description: '전투 시작 시 블록 +5', rarity: Rarity.cursed, effectType: 'defenseBonus', effectValue: 5),
    BlessingData(id: 'devil_blessing_003', name: '심연의 눈', description: '전투 시작 시 야성 +10', rarity: Rarity.cursed, effectType: 'momentumBonus', effectValue: 10),
    BlessingData(id: 'devil_blessing_004', name: '광기의 힘', description: '전투 시작 시 힘 +2, 블록 +3', rarity: Rarity.cursed, effectType: 'attackAndDefenseBonus', effectValue: 2),
  ];

  static const _defaultDeals = <DevilDealData>[
    DevilDealData(id: 'deal_001', blessingId: 'devil_blessing_001', curseId: 'curse_001', flavorText: '힘을 원하는가? 대가는 육체의 쇠약.'),
    DevilDealData(id: 'deal_002', blessingId: 'devil_blessing_002', curseId: 'curse_002', flavorText: '단단해지고 싶은가? 대신 둔해질 것이다.'),
    DevilDealData(id: 'deal_003', blessingId: 'devil_blessing_003', curseId: 'curse_005', flavorText: '진실을 보고 싶은가? 그 눈은 혼란을 부른다.'),
    DevilDealData(id: 'deal_004', blessingId: 'devil_blessing_004', curseId: 'curse_004', cost: 10, flavorText: '절대적 힘... 하지만 적도 강해진다.'),
    DevilDealData(id: 'deal_005', blessingId: 'devil_blessing_001', curseId: 'curse_006', flavorText: '공격의 극한. 대가는 야성의 소모.'),
    DevilDealData(id: 'deal_006', blessingId: 'devil_blessing_002', curseId: 'curse_003', flavorText: '방어는 얻으나, 금화가 새어나간다.'),
    DevilDealData(id: 'deal_007', blessingId: 'devil_blessing_003', curseId: 'curse_006', flavorText: '눈은 열리지만, 야성가 모래처럼 흩어진다.'),
    DevilDealData(id: 'deal_008', blessingId: 'devil_blessing_004', curseId: 'curse_001', flavorText: '전장의 왕이 되리라. 육체가 버틸 수 있다면.'),
    DevilDealData(id: 'deal_009', blessingId: 'devil_blessing_001', curseId: 'curse_003', cost: 5, flavorText: '저렴한 거래라고? 세상에 공짜는 없다네.'),
    DevilDealData(id: 'deal_010', blessingId: 'devil_blessing_003', curseId: 'curse_004', flavorText: '진실을 보는 눈... 적도 당신을 더 잘 보게 되지.'),
    DevilDealData(id: 'deal_011', blessingId: 'devil_blessing_001', curseId: 'curse_007', flavorText: '힘을 원하느냐? 대가는 둔한 손놀림.'),
    DevilDealData(id: 'deal_012', blessingId: 'devil_blessing_002', curseId: 'curse_008', flavorText: '방어를 얻되, 첫 순간의 주저함을 받아들여라.'),
    DevilDealData(id: 'deal_013', blessingId: 'devil_blessing_003', curseId: 'curse_009', flavorText: '통찰의 눈... 하지만 어둠이 네 생명을 갉아먹는다.'),
    DevilDealData(id: 'deal_014', blessingId: 'devil_blessing_004', curseId: 'curse_010', flavorText: '강해지리라. 다만 과거의 기술은 잊혀지리니.'),
  ];

  /// ID로 저주 조회.
  static CurseData? findCurseById(String id) {
    for (final c in curses) {
      if (c.id == id) return c;
    }
    return null;
  }

  /// ID로 악마 축복 조회.
  static BlessingData? findDevilBlessingById(String id) {
    for (final b in devilBlessings) {
      if (b.id == id) return b;
    }
    return null;
  }

  /// ID로 거래 조회.
  static DevilDealData? findDealById(String id) {
    for (final d in deals) {
      if (d.id == id) return d;
    }
    return null;
  }

  /// 저주 ID 목록 → CurseData 목록 (존재하는 것만).
  static List<CurseData> resolveCurseIds(List<String> ids) {
    return ids.map(findCurseById).whereType<CurseData>().toList();
  }
}
