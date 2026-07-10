import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/logging/game_logger.dart';
import 'package:soul_dungeon/domain/dungeon/mystery/mystery_outcome.dart';

/// 미스터리 방 결과 생성기 — static 유틸리티 (ShopItemGenerator 패턴).
/// 가중치 누적합 방식으로 결과 선택, 시드 기반 PRNG 지원.
/// JSON 에셋(assets/content/mystery_texts.json)에서 텍스트 로드. 실패 시 기본값 폴백.
class MysteryResultGenerator {
  MysteryResultGenerator._();

  static List<String> _treasureTexts = _defaultTreasureTexts;
  static List<String> _trapTexts = _defaultTrapTexts;
  static List<String> _combatTexts = _defaultCombatTexts;
  static List<String> _eventTexts = _defaultEventTexts;
  static List<String> _minorTexts = _defaultMinorTexts;

  /// JSON 에셋에서 텍스트 로드. 실패 시 기본값 폴백.
  static Future<void> load({
    AssetBundle? bundle,
    String path = 'assets/content/mystery_texts.json',
  }) async {
    try {
      final assetBundle = bundle ?? rootBundle;
      final jsonString = await assetBundle.loadString(path);
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      _treasureTexts = (json['treasure'] as List).cast<String>();
      _trapTexts = (json['trap'] as List).cast<String>();
      _combatTexts = (json['combat'] as List).cast<String>();
      _eventTexts = (json['event'] as List).cast<String>();
      _minorTexts = (json['minor'] as List).cast<String>();
      GameLogger.info(LogSystem.core, 'MysteryResultGenerator loaded');
    } catch (e) {
      GameLogger.error(LogSystem.core, 'Failed to load mystery_texts.json, using defaults', e);
      _treasureTexts = _defaultTreasureTexts;
      _trapTexts = _defaultTrapTexts;
      _combatTexts = _defaultCombatTexts;
      _eventTexts = _defaultEventTexts;
      _minorTexts = _defaultMinorTexts;
    }
  }

  // ── 기본값 (JSON 로드 실패 시 폴백) ──

  static const _defaultTreasureTexts = [
    '빛나는 보물 상자를 발견했다! 금화가 가득 들어있다.',
    '벽감 속에 숨겨진 금고를 찾았다. 잠금장치가 녹슬어 쉽게 열렸다.',
    '바닥 타일 아래에 보물이 묻혀 있었다. 누군가 급히 숨긴 듯하다.',
    '천장에서 떨어진 돌 뒤로 반짝이는 것이 보인다. 금화 주머니다!',
    '해골이 쥐고 있던 주머니를 열자 금화가 쏟아져 나온다.',
  ];
  static const _defaultTrapTexts = [
    '바닥이 갑자기 무너졌다! 깊은 구멍에서 간신히 빠져나왔다.',
    '벽에서 독침이 날아왔다! 가까스로 피했지만 스쳤다.',
    '문을 열자 날카로운 칼날이 휘둘러졌다. 피가 스며든다.',
    '발밑의 압력판을 밟았다. 천장에서 돌덩이가 떨어진다!',
  ];
  static const _defaultCombatTexts = [
    '그림자 속에서 적이 나타났다! 짧은 격전 끝에 물리쳤다.',
    '웅크린 그림자가 갑자기 덤벼왔다! 격렬한 접전 끝에 승리했다.',
    '벽 뒤에서 기습을 당했다! 반격에 성공하고 전리품을 얻었다.',
    '잠들어 있던 수호자가 깨어났다. 힘겹지만 쓰러뜨렸다.',
  ];
  static const _defaultEventTexts = [
    '벽에 새겨진 고대 문자를 발견했다. 무언가를 깨달은 것 같다.',
    '바닥에 그려진 마법진이 희미하게 빛난다. 새로운 지식이 스며든다.',
    '기둥에 감긴 두루마리를 발견했다. 잊혀진 지혜가 떠오른다.',
    '공중에 떠 있는 빛 조각을 만졌다. 정신이 맑아진다.',
  ];
  static const _defaultMinorTexts = [
    '먼지 쌓인 선반에서 잔돈 몇 닢을 발견했다.',
    '바닥에 굴러다니던 동전 몇 개를 주웠다. 대단한 건 아니다.',
    '빈 방이다. 구석에 약간의 금화가 떨어져 있다.',
    '누군가 두고 간 낡은 지갑을 발견했다. 소량의 금화가 남아있다.',
    '깨진 항아리 속에서 동전 몇 닢이 나왔다.',
  ];

  /// 미스터리 방 결과 생성.
  /// [floor] 현재 층 (향후 난이도 보정용).
  /// [mysteryConfig] 보상/페널티 값 및 가중치.
  /// [seed] PRNG 시드 — 같은 시드 = 같은 결과.
  static MysteryOutcome generate({
    required int floor,
    required MysteryConfig mysteryConfig,
    int? seed,
  }) {
    final totalWeight = mysteryConfig.weightTreasure +
        mysteryConfig.weightTrap +
        mysteryConfig.weightCombat +
        mysteryConfig.weightEvent +
        mysteryConfig.weightMinor;

    final random = Random(seed);

    // 방어 가드: 모든 가중치 0 → 기본 MinorOutcome 반환
    if (totalWeight <= 0) {
      return MinorOutcome(
        goldReward: mysteryConfig.minorGold,
        narrativeText: _minorTexts[random.nextInt(_minorTexts.length)],
      );
    }

    final roll = random.nextInt(totalWeight);

    var cumulative = 0;

    cumulative += mysteryConfig.weightTreasure;
    if (roll < cumulative) {
      return TreasureOutcome(
        goldReward: mysteryConfig.treasureGold,
        narrativeText: _treasureTexts[random.nextInt(_treasureTexts.length)],
      );
    }

    cumulative += mysteryConfig.weightTrap;
    if (roll < cumulative) {
      return TrapOutcome(
        hpLoss: mysteryConfig.trapHpLoss,
        narrativeText: _trapTexts[random.nextInt(_trapTexts.length)],
      );
    }

    cumulative += mysteryConfig.weightCombat;
    if (roll < cumulative) {
      return EncounterOutcome(
        goldReward: mysteryConfig.combatGold,
        narrativeText: _combatTexts[random.nextInt(_combatTexts.length)],
      );
    }

    cumulative += mysteryConfig.weightEvent;
    if (roll < cumulative) {
      return EventOutcome(
        goldReward: mysteryConfig.eventGold,
        narrativeText: _eventTexts[random.nextInt(_eventTexts.length)],
      );
    }

    return MinorOutcome(
      goldReward: mysteryConfig.minorGold,
      narrativeText: _minorTexts[random.nextInt(_minorTexts.length)],
    );
  }
}
