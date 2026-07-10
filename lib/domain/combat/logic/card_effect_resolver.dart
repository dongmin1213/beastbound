import 'dart:math';

import 'package:soul_dungeon/domain/combat/logic/damage_calculator.dart';
import 'package:soul_dungeon/domain/combat/logic/deck_manager.dart';
import 'package:soul_dungeon/domain/combat/logic/status_effect_processor.dart';
import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/domain/combat/models/combat_damage.dart';
import 'package:soul_dungeon/domain/combat/models/deck_state.dart';
import 'package:soul_dungeon/domain/combat/models/status_effect.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 카드 효과 해석 — CardData + CombatState → 결과. 순수 함수.
class CardEffectResolver {
  CardEffectResolver._();

  /// 카드 플레이 결과 계산.
  static CardPlayResult resolve({
    required CardData card,
    required int playerStrength,
    required int playerDexterity,
    required List<StatusEffect> playerStatuses,
    required List<StatusEffect> enemyStatuses,
    required int enemyBlock,
    required DeckState deckState,
    required int momentumTier,
    int playerHp = 100,
    int playerMaxHp = 100,
    int currentTurn = 0,
    int attacksPlayedThisTurn = 0,
    bool doubleNextAttack = false,
    int playerBlock = 0,
    int enemyHp = 100,
    int enemyMaxHp = 100,
    int skillsPlayedThisTurn = 0,
    int handIndex = -1,
    Random? random,
  }) {
    DamageResult? damageResult;
    int blockGained = 0;
    int selfDamage = 0;
    int healAmount = 0;
    int drawCount = 0;
    int apGain = 0;
    bool setImmuneThisTurn = false;
    bool setDoubleNextAttack = false;
    bool requestCopyLastAttack = false;
    int apModifierNextTurn = 0;
    bool setExhaustHandAtTurnEnd = false;
    int poisonPerTurnStart = 0;
    bool requestCleanse = false;
    int blockPerTurnStart = 0;
    int conditionalBlockPerTurnStart = 0;
    int blockRetainPercent = 0;
    int retrievePerTurn = 0;
    int mimicEnemyMultiplier = 0;
    int generateCardCount = 0;
    int blockPerCardPlayedValue = 0;
    int randomDebuffCount = 0;
    int executeHpPercent = 0;
    int healOnKill = 0;
    int selfDamagePerTurn = 0;
    int strengthPerTurn = 0;
    int absorbStrengthValue = 0;
    int generateAttackPerTurn = 0;
    int replayLastCardCount = 0;
    int boostLowestStatValue = 0;
    bool setAllTypesApBonus = false;
    bool setTransformHand = false;
    int adaptiveDamageHigh = 0;
    int adaptiveDamageLow = 0;
    int regenNullifyTurns = 0;
    int stunEnemyTurns = 0;
    bool resetEnemyBuff = false;
    int drainNullifyTurns = 0;
    int momentumGainAmount = 0;
    bool setFleeGuaranteed = false;
    int dodgeChancePercent = 0;
    int lostHpToBlockPerTurnPercent = 0;
    int remainingApBlockValue = 0;
    int reflectDamageChancePercent = 0;
    bool requestSwapStrDex = false;
    int healPerTurnValue = 0;
    int drawPerTurnValue = 0;
    // ── Phase 3-B 신규 효과 ──
    int lifestealOnAllAttacksPercent = 0;
    int healPerTurnConditionalValue = 0;
    String? healPerTurnCondition;
    int nextSkillApDiscountValue = 0;
    int overflowToBlockPercent = 0;
    int cooldownTurns = 0;
    int momentumGainOnDodgeValue = 0;
    int poisonDamageReductionValue = 0;
    int poisonDamageReductionCap = 0;
    int immuneNextHitsCount = 0;
    int damageReductionWhenBlockValue = 0;
    int damageReductionWhenBlockThreshold = 0;
    int healOnDamageTakenValue = 0;
    int healOnReflectValue = 0;
    int nextHitDamageReductionPercent = 0;
    bool setAllAttackPiercing = false;
    int allSkillApDiscountValue = 0;
    int randomBuffCount = 0;
    final rng = random ?? Random();
    final newPlayerStatuses = <StatusEffect>[];
    final newEnemyStatuses = <StatusEffect>[];
    var updatedDeck = deckState;

    // 관통 체크 (적 블록 무시)
    final hasIgnoreBlock =
        card.effects.any((e) => e.type == CardEffectType.ignoreBlock);
    final effectiveEnemyBlock = hasIgnoreBlock ? 0 : enemyBlock;

    // 기본 데미지 처리
    if (card.damage != null) {
      var baseDmg = card.damage!;
      if (doubleNextAttack && card.type == CardType.attack) baseDmg *= 2;
      damageResult = _calcDamage(
        baseDamage: baseDmg,
        strength: playerStrength,
        playerStatuses: playerStatuses,
        enemyStatuses: enemyStatuses,
        targetBlock: effectiveEnemyBlock,
      );
    }

    // 기본 블록 처리
    if (card.block != null) {
      blockGained = card.block! + playerDexterity;
      if (blockGained < 0) blockGained = 0;
    }

    // 효과 처리
    for (final effect in card.effects) {
      switch (effect.type) {
        case CardEffectType.nothing:
          // 저주 카드: 아무 효과 없음
          break;
        case CardEffectType.damage:
          // 추가 데미지 (기본 데미지와 별개)
          break;
        case CardEffectType.block:
          blockGained += effect.value + playerDexterity;
          break;
        case CardEffectType.draw:
          drawCount += effect.value;
          break;
        case CardEffectType.apGain:
          apGain += effect.value;
          break;
        case CardEffectType.heal:
          healAmount += effect.value;
          break;
        case CardEffectType.selfDamage:
          selfDamage += effect.value;
          break;
        case CardEffectType.applyPoison:
          newEnemyStatuses.add(StatusEffect(
            type: StatusEffectType.poison,
            stacks: effect.value,
            turnsRemaining: effect.duration,
          ));
          break;
        case CardEffectType.applyBurn:
          newEnemyStatuses.add(StatusEffect(
            type: StatusEffectType.burn,
            stacks: effect.value,
          ));
          break;
        case CardEffectType.applyWeak:
          newEnemyStatuses.add(StatusEffect(
            type: StatusEffectType.weak,
            stacks: 1,
            turnsRemaining: effect.duration ?? effect.value,
          ));
          break;
        case CardEffectType.applyVulnerable:
          newEnemyStatuses.add(StatusEffect(
            type: StatusEffectType.vulnerable,
            stacks: 1,
            turnsRemaining: effect.duration ?? effect.value,
          ));
          break;
        case CardEffectType.gainStrength:
          if (_checkCondition(
            effect.condition,
            momentumTier: momentumTier,
            currentTurn: currentTurn,
            playerHp: playerHp,
            playerMaxHp: playerMaxHp,
          )) {
            newPlayerStatuses.add(StatusEffect(
              type: StatusEffectType.strength,
              stacks: effect.value,
            ));
          }
          break;
        case CardEffectType.gainDexterity:
          newPlayerStatuses.add(StatusEffect(
            type: StatusEffectType.dexterity,
            stacks: effect.value,
          ));
          break;
        case CardEffectType.gainThorn:
          newPlayerStatuses.add(StatusEffect(
            type: StatusEffectType.thorn,
            stacks: effect.value,
          ));
          break;
        case CardEffectType.gainRegenerate:
          newPlayerStatuses.add(StatusEffect(
            type: StatusEffectType.regenerate,
            stacks: effect.value,
            turnsRemaining: effect.duration,
          ));
          break;
        case CardEffectType.conditionalDamage:
          if (effect.condition == 'momentumTier') {
            // 기세 티어 × value 데미지
            damageResult = _calcDamage(
              baseDamage: momentumTier * effect.value,
              strength: playerStrength,
              playerStatuses: playerStatuses,
              enemyStatuses: enemyStatuses,
              targetBlock: effectiveEnemyBlock,
            );
          } else if (effect.condition == 'lowHp') {
            // 플레이어 HP ≤50%: value 데미지, 아니면 duration 데미지
            final isLowHp = playerHp < (playerMaxHp * 0.5).toInt();
            final highDmg = effect.value;
            final lowDmg = effect.duration ?? (effect.value ~/ 2);
            var baseDmg = isLowHp ? highDmg : lowDmg;
            if (doubleNextAttack && card.type == CardType.attack) baseDmg *= 2;
            damageResult = _calcDamage(
              baseDamage: baseDmg,
              strength: playerStrength,
              playerStatuses: playerStatuses,
              enemyStatuses: enemyStatuses,
              targetBlock: effectiveEnemyBlock,
            );
          }
          break;
        case CardEffectType.discardAndDraw:
          // 현재 카드는 라인 574에서 exhaust/discard 처리 → 여기선 나머지만 버림
          final discardOthers = updatedDeck.hand
              .where((c) => c.id != card.id)
              .toList();
          final discardCurrent = updatedDeck.hand
              .where((c) => c.id == card.id)
              .take(1)
              .toList();
          updatedDeck = DeckState(
            drawPile: updatedDeck.drawPile,
            hand: discardCurrent,
            discardPile: [...updatedDeck.discardPile, ...discardOthers],
            exhaustPile: updatedDeck.exhaustPile,
          );
          drawCount += effect.value;
          break;
        case CardEffectType.immuneThisTurn:
          setImmuneThisTurn = true;
          break;
        case CardEffectType.doubleNextAttack:
          setDoubleNextAttack = true;
          break;
        case CardEffectType.copyLastAttack:
          requestCopyLastAttack = true;
          break;
        case CardEffectType.apPenaltyNextTurn:
          apModifierNextTurn -= effect.value;
          break;
        case CardEffectType.poisonMultiplierDamage:
          // 적 독 수치 × value 데미지
          final poisonStacks = StatusEffectProcessor.stacks(
            enemyStatuses,
            StatusEffectType.poison,
          );
          if (poisonStacks > 0) {
            var baseDmg = poisonStacks * effect.value;
            if (doubleNextAttack && card.type == CardType.attack) baseDmg *= 2;
            damageResult = _calcDamage(
              baseDamage: baseDmg,
              strength: playerStrength,
              playerStatuses: playerStatuses,
              enemyStatuses: enemyStatuses,
              targetBlock: effectiveEnemyBlock,
            );
          }
          break;
        case CardEffectType.damagePerHandCard:
          // 손패 수 × value 데미지
          final handCount = updatedDeck.handCount;
          if (handCount > 0) {
            var baseDmg = handCount * effect.value;
            if (doubleNextAttack && card.type == CardType.attack) baseDmg *= 2;
            damageResult = _calcDamage(
              baseDamage: baseDmg,
              strength: playerStrength,
              playerStatuses: playerStatuses,
              enemyStatuses: enemyStatuses,
              targetBlock: effectiveEnemyBlock,
            );
          }
          break;
        case CardEffectType.multiHit:
          // value 데미지 × duration 회 — 히트별 블록 적용
          final hits = effect.duration ?? 3;
          var remainingBlock = effectiveEnemyBlock;
          int totalHpLost = 0;
          int totalBlockAbsorbed = 0;
          int totalFinalDmg = 0;
          for (var i = 0; i < hits; i++) {
            var hitBaseDmg = effect.value;
            if (doubleNextAttack && card.type == CardType.attack) hitBaseDmg *= 2;
            final hitResult = _calcDamage(
              baseDamage: hitBaseDmg,
              strength: playerStrength,
              playerStatuses: playerStatuses,
              enemyStatuses: enemyStatuses,
              targetBlock: remainingBlock,
            );
            totalHpLost += hitResult.hpLost;
            totalBlockAbsorbed += hitResult.blockAbsorbed;
            totalFinalDmg += hitResult.finalDamage;
            remainingBlock =
                (remainingBlock - hitResult.blockAbsorbed).clamp(0, 99999);
          }
          final multiHitWeakened = StatusEffectProcessor.hasActive(
            playerStatuses,
            StatusEffectType.weak,
          );
          final multiHitVulnerable = StatusEffectProcessor.hasActive(
            enemyStatuses,
            StatusEffectType.vulnerable,
          );
          damageResult = DamageResult(
            rawDamage: effect.value * hits,
            strengthBonus: playerStrength * hits,
            isWeakened: multiHitWeakened,
            isVulnerable: multiHitVulnerable,
            finalDamage: totalFinalDmg,
            blockAbsorbed: totalBlockAbsorbed,
            hpLost: totalHpLost,
          );
          break;
        case CardEffectType.retrieveFromDiscard:
          // 버림 더미에서 N장 손패로 복귀
          final count = effect.value.clamp(0, updatedDeck.discardPile.length);
          if (count > 0) {
            final retrieved = updatedDeck.discardPile.take(count).toList();
            updatedDeck = DeckState(
              drawPile: updatedDeck.drawPile,
              hand: [...updatedDeck.hand, ...retrieved],
              discardPile: updatedDeck.discardPile.skip(count).toList(),
              exhaustPile: updatedDeck.exhaustPile,
            );
          }
          break;
        case CardEffectType.sprintExhaust:
          // AP +value, 턴 종료 시 손패 Exhaust
          apGain += effect.value;
          setExhaustHandAtTurnEnd = true;
          break;
        case CardEffectType.exhaustAndDraw:
          // 손패 1장 Exhaust → value장 드로우
          if (updatedDeck.hand.length > 1) {
            // 현재 카드 제외한 첫 번째 카드 Exhaust
            final targetCard = updatedDeck.hand
                .where((c) => c.id != card.id)
                .firstOrNull;
            if (targetCard != null) {
              updatedDeck = DeckManager.exhaustFromHand(
                updatedDeck,
                targetCard.id,
              );
              drawCount += effect.value;
            }
          }
          break;
        case CardEffectType.hpPercentDamage:
          // 플레이어 현재 HP의 value% 데미지
          final hpDmg = (playerHp * effect.value / 100).toInt();
          if (hpDmg > 0) {
            damageResult = _calcDamage(
              baseDamage: hpDmg,
              strength: 0,
              playerStatuses: playerStatuses,
              enemyStatuses: enemyStatuses,
              targetBlock: effectiveEnemyBlock,
            );
          }
          break;
        case CardEffectType.enemyMaxHpPercentDamage:
          // 적 최대 HP의 value% 데미지
          final enemyHpDmg = (enemyMaxHp * effect.value / 100).toInt();
          if (enemyHpDmg > 0) {
            damageResult = _calcDamage(
              baseDamage: enemyHpDmg,
              strength: 0,
              playerStatuses: playerStatuses,
              enemyStatuses: enemyStatuses,
              targetBlock: effectiveEnemyBlock,
            );
          }
          break;
        case CardEffectType.highMomentumBonus:
          // 기세 High(3)일 때 데미지 2배 → 기본 데미지에 반영
          if (momentumTier >= 3 && card.damage != null) {
            var baseDmg = card.damage! * 2;
            if (doubleNextAttack && card.type == CardType.attack) baseDmg *= 2;
            damageResult = _calcDamage(
              baseDamage: baseDmg,
              strength: playerStrength,
              playerStatuses: playerStatuses,
              enemyStatuses: enemyStatuses,
              targetBlock: effectiveEnemyBlock,
            );
          }
          break;
        case CardEffectType.ignoreBlock:
          // 관통 — 위에서 effectiveEnemyBlock으로 처리 완료
          break;
        case CardEffectType.cycleHand:
          // 현재 카드는 라인 574에서 exhaust/discard 처리 → 여기선 나머지만 버림
          final cycleOthers = updatedDeck.hand
              .where((c) => c.id != card.id)
              .toList();
          final cycleCurrent = updatedDeck.hand
              .where((c) => c.id == card.id)
              .take(1)
              .toList();
          updatedDeck = DeckState(
            drawPile: updatedDeck.drawPile,
            hand: cycleCurrent,
            discardPile: [...updatedDeck.discardPile, ...cycleOthers],
            exhaustPile: updatedDeck.exhaustPile,
          );
          drawCount += cycleOthers.length + effect.value;
          break;
        case CardEffectType.revealIntent:
          // 적 의도 공개 — CombatBloc에서 처리
          break;
        case CardEffectType.momentumGain:
          // 기세 증가 — CombatBloc에서 GameEventBus 경유
          momentumGainAmount += effect.value;
          break;
        case CardEffectType.setFleeGuaranteed:
          // 도주 보장 — CombatBloc에서 처리
          setFleeGuaranteed = true;
          break;
        case CardEffectType.setPoisonPerTurn:
          // 독안개 Power: 매 턴 시작 시 적에게 독 부여
          poisonPerTurnStart += effect.value;
          break;
        case CardEffectType.playRestriction:
          // 사용 제한 마커 — CombatBloc에서 처리
          break;
        // ── 성자 카드 효과 ──
        case CardEffectType.cleanse:
          // 모든 디버프 제거 — CombatBloc에서 처리
          requestCleanse = true;
          break;
        case CardEffectType.retribution:
          // 현재 플레이어 블록 × (value/100) = 데미지
          if (playerBlock > 0) {
            damageResult = _calcDamage(
              baseDamage: (playerBlock * effect.value / 100).toInt(),
              strength: playerStrength,
              playerStatuses: playerStatuses,
              enemyStatuses: enemyStatuses,
              targetBlock: effectiveEnemyBlock,
            );
          }
          break;
        case CardEffectType.blockPerTurnStart:
          // Power: 매 턴 시작 시 value 블록 획득 — CombatBloc에서 처리
          blockPerTurnStart += effect.value;
          break;
        // ── 수호자 카드 효과 ──
        case CardEffectType.blockRetain:
          // 다음 턴 블록 유지 %
          blockRetainPercent += effect.value;
          break;
        case CardEffectType.thornMultiplierDamage:
          // 현재 가시 스택 × value 데미지
          final thornStacks = StatusEffectProcessor.stacks(
            playerStatuses,
            StatusEffectType.thorn,
          );
          if (thornStacks > 0) {
            var baseDmg = thornStacks * effect.value;
            if (doubleNextAttack && card.type == CardType.attack) baseDmg *= 2;
            damageResult = _calcDamage(
              baseDamage: baseDmg,
              strength: playerStrength,
              playerStatuses: playerStatuses,
              enemyStatuses: enemyStatuses,
              targetBlock: effectiveEnemyBlock,
            );
          }
          break;
        case CardEffectType.blockPerTurnStartConditional:
          // 조건부(criticalHp: HP <30%) 매 턴 블록 — CombatBloc에서 조건 체크 후 적용
          conditionalBlockPerTurnStart += effect.value;
          break;
        // ── 방랑자 카드 효과 ──
        case CardEffectType.randomDamage:
          // min=value, max=duration, Random 데미지
          final minDmg = effect.value;
          final maxDmg = effect.duration ?? effect.value;
          var baseDmg = minDmg + rng.nextInt(maxDmg - minDmg + 1);
          if (doubleNextAttack && card.type == CardType.attack) baseDmg *= 2;
          damageResult = _calcDamage(
            baseDamage: baseDmg,
            strength: playerStrength,
            playerStatuses: playerStatuses,
            enemyStatuses: enemyStatuses,
            targetBlock: effectiveEnemyBlock,
          );
          break;
        case CardEffectType.coinFlip:
          // 성공/실패 판정. 기본 50%, 업그레이드 60%
          final successChance = card.upgraded ? 60 : 50;
          final roll = rng.nextInt(100);
          if (roll < successChance) {
            drawCount += effect.value;
          } else {
            selfDamage += effect.duration ?? 0;
          }
          break;
        case CardEffectType.retrieveRandomPerTurn:
          // 매 턴 버림 더미 복귀 — CombatBloc에서 처리
          retrievePerTurn += effect.value;
          break;
        case CardEffectType.mimicEnemyDamage:
          // 적 마지막 행동 × multiplier — CombatBloc에서 처리
          mimicEnemyMultiplier += effect.value;
          break;
        case CardEffectType.generateRandomCard:
          // 랜덤 카드 생성 — CombatBloc에서 처리
          generateCardCount += effect.value;
          break;
        case CardEffectType.blockPerCardPlayed:
          // 카드 수 × value 블록 — CombatBloc에서 처리
          blockPerCardPlayedValue += effect.value;
          break;
        case CardEffectType.randomDebuffs:
          // 랜덤 디버프 N개 — CombatBloc에서 처리
          randomDebuffCount += effect.value;
          break;
        // ── 환경 카드 효과 ──
        case CardEffectType.fixedDamage:
          // 고정 데미지 (방어 무시)
          damageResult = DamageResult(
            rawDamage: effect.value,
            finalDamage: effect.value,
            blockAbsorbed: 0,
            hpLost: effect.value,
          );
          break;
        // ── 사신 카드 효과 ──
        case CardEffectType.executeHpPercent:
          executeHpPercent = effect.value;
          break;
        case CardEffectType.healOnKill:
          healOnKill += effect.value;
          break;
        case CardEffectType.damageEqualLostHp:
          // 잃은 HP만큼 데미지
          final lostHp = playerMaxHp - playerHp;
          if (lostHp > 0) {
            damageResult = _calcDamage(
              baseDamage: lostHp,
              strength: playerStrength,
              playerStatuses: playerStatuses,
              enemyStatuses: enemyStatuses,
              targetBlock: effectiveEnemyBlock,
            );
          }
          break;
        case CardEffectType.splitHpToBlock:
          // HP의 value% → 블록, 동량 셀프 데미지
          final hpToConvert = (playerHp * effect.value / 100).toInt();
          blockGained += hpToConvert;
          selfDamage += hpToConvert;
          break;
        case CardEffectType.conditionalBlock:
          if (_checkCondition(
            effect.condition,
            momentumTier: momentumTier,
            currentTurn: currentTurn,
            playerHp: playerHp,
            playerMaxHp: playerMaxHp,
          )) {
            blockGained += effect.value + playerDexterity;
          }
          break;
        case CardEffectType.selfDamagePerTurn:
          selfDamagePerTurn += effect.value;
          break;
        case CardEffectType.strengthPerTurn:
          strengthPerTurn += effect.value;
          break;
        // ── 환술사 카드 효과 ──
        case CardEffectType.transformHandPerTurn:
          setTransformHand = true;
          break;
        case CardEffectType.replayLastCard:
          replayLastCardCount += effect.value;
          break;
        case CardEffectType.generateAttackPerTurn:
          generateAttackPerTurn += effect.value;
          break;
        // ── 조율사 카드 효과 ──
        case CardEffectType.absorbStrength:
          absorbStrengthValue += effect.value;
          break;
        case CardEffectType.adaptiveDamage:
          // value=적 공격 시 데미지, duration=적 비공격 시 데미지
          adaptiveDamageHigh = effect.value;
          adaptiveDamageLow = effect.duration ?? (effect.value ~/ 2);
          break;
        case CardEffectType.allTypesApBonus:
          setAllTypesApBonus = true;
          break;
        case CardEffectType.equalizeHpBlock:
          // HP와 블록 평균 → 블록 설정 (HP 변경은 CombatBloc)
          final avg = ((playerHp + playerBlock) / 2).toInt();
          blockGained = avg - playerBlock;
          if (blockGained < 0) blockGained = 0;
          selfDamage += (playerHp - avg).clamp(0, playerHp);
          break;
        case CardEffectType.boostLowestStat:
          boostLowestStatValue += effect.value;
          break;
        // ── 환경 카드 효과 ──
        case CardEffectType.regenNullify:
          // 재생 무효 — CombatBloc에서 처리
          regenNullifyTurns += effect.value;
          break;
        case CardEffectType.stunEnemy:
          // 적 행동 차단 — CombatBloc에서 처리
          stunEnemyTurns += effect.value;
          break;
        case CardEffectType.resetEnemyBuff:
          // 적 강화 초기화 — CombatBloc에서 처리
          resetEnemyBuff = true;
          break;
        case CardEffectType.drainNullify:
          // 흡혈 무효 — CombatBloc에서 처리
          drainNullifyTurns += effect.value;
          break;
        // ── 콘텐츠 확장 신규 효과 ──
        case CardEffectType.lifesteal:
          // 데미지 결과의 N% HP 회복 — 데미지 계산 후 적용
          if (damageResult != null) {
            healAmount += (damageResult.hpLost * effect.value / 100).toInt();
          }
          break;
        case CardEffectType.poisonBurst:
          // 적 독 스택 전부 즉시 데미지로 전환 후 독 제거
          final poisonStacks = StatusEffectProcessor.stacks(
            enemyStatuses,
            StatusEffectType.poison,
          );
          if (poisonStacks > 0) {
            var baseDmg = poisonStacks;
            if (doubleNextAttack && card.type == CardType.attack) baseDmg *= 2;
            damageResult = _calcDamage(
              baseDamage: baseDmg,
              strength: playerStrength,
              playerStatuses: playerStatuses,
              enemyStatuses: enemyStatuses,
              targetBlock: effectiveEnemyBlock,
            );
            // 독 제거 — 적에게 독 -전량 적용 (CombatBloc에서 처리)
            newEnemyStatuses.add(StatusEffect(
              type: StatusEffectType.poison,
              stacks: -poisonStacks,
            ));
          }
          break;
        case CardEffectType.dodgeChance:
          // N% 회피 확률 — CombatBloc에서 처리
          dodgeChancePercent += effect.value;
          break;
        case CardEffectType.healPerAttackPlayed:
          // 이번 턴 Attack 사용 수 × value HP 회복
          healAmount += attacksPlayedThisTurn * effect.value;
          break;
        case CardEffectType.lostHpToBlockPerTurn:
          // Power: (maxHp - currentHp) × value% 매 턴 블록 — CombatBloc에서 처리
          lostHpToBlockPerTurnPercent += effect.value;
          break;
        case CardEffectType.conditionalDamageEnemyHp:
          // 적 HP ≤50%: value 데미지, else duration 데미지
          final highDmg = effect.value;
          final lowDmg = effect.duration ?? (effect.value ~/ 2);
          final isEnemyLowHp = enemyHp <= (enemyMaxHp * 0.5).toInt();
          var baseDmg = isEnemyLowHp ? highDmg : lowDmg;
          if (doubleNextAttack && card.type == CardType.attack) baseDmg *= 2;
          damageResult = _calcDamage(
            baseDamage: baseDmg,
            strength: playerStrength,
            playerStatuses: playerStatuses,
            enemyStatuses: enemyStatuses,
            targetBlock: effectiveEnemyBlock,
          );
          break;
        case CardEffectType.damagePerExhaust:
          // 소진 파일 카드 수 × value 데미지
          final exhaustCount = updatedDeck.exhaustPile.length;
          if (exhaustCount > 0) {
            var baseDmg = exhaustCount * effect.value;
            if (doubleNextAttack && card.type == CardType.attack) baseDmg *= 2;
            damageResult = _calcDamage(
              baseDamage: baseDmg,
              strength: playerStrength,
              playerStatuses: playerStatuses,
              enemyStatuses: enemyStatuses,
              targetBlock: effectiveEnemyBlock,
            );
          }
          break;
        case CardEffectType.handSizeBlock:
          // 현재 손패 수 × value 추가 블록
          blockGained += updatedDeck.handCount * effect.value;
          break;
        case CardEffectType.skillCountDamage:
          // 이번 턴 Skill 사용 수 × value 데미지
          if (skillsPlayedThisTurn > 0) {
            var baseDmg = skillsPlayedThisTurn * effect.value;
            if (doubleNextAttack && card.type == CardType.attack) baseDmg *= 2;
            damageResult = _calcDamage(
              baseDamage: baseDmg,
              strength: playerStrength,
              playerStatuses: playerStatuses,
              enemyStatuses: enemyStatuses,
              targetBlock: effectiveEnemyBlock,
            );
          }
          break;
        case CardEffectType.remainingApBlock:
          // 턴 종료 시 남은 AP × value 블록 — CombatBloc에서 처리
          remainingApBlockValue += effect.value;
          break;
        case CardEffectType.retrieveFromExhaust:
          // 소진 파일에서 N장 손패로 복귀
          final count = effect.value.clamp(0, updatedDeck.exhaustPile.length);
          if (count > 0) {
            final retrieved = updatedDeck.exhaustPile.take(count).toList();
            updatedDeck = DeckState(
              drawPile: updatedDeck.drawPile,
              hand: [...updatedDeck.hand, ...retrieved],
              discardPile: updatedDeck.discardPile,
              exhaustPile: updatedDeck.exhaustPile.skip(count).toList(),
            );
          }
          break;
        case CardEffectType.reflectDamageChance:
          // 피격 시 N% 확률 데미지 반사 — CombatBloc에서 처리
          reflectDamageChancePercent += effect.value;
          break;
        case CardEffectType.swapStrDex:
          // 힘 ↔ 민첩 교환 — CombatBloc에서 처리
          requestSwapStrDex = true;
          break;
        case CardEffectType.statSumDamage:
          // (힘 + 민첩) × value / 100 데미지, condition으로 추가 스탯
          var statSum = playerStrength + playerDexterity;
          if (effect.condition == 'withBlock') {
            statSum += playerBlock;
          } else if (effect.condition == 'withThorn') {
            statSum += StatusEffectProcessor.stacks(
              playerStatuses,
              StatusEffectType.thorn,
            );
          } else if (effect.condition == 'withBlockAndThorn') {
            statSum += playerBlock;
            statSum += StatusEffectProcessor.stacks(
              playerStatuses,
              StatusEffectType.thorn,
            );
          }
          var baseDmg = (statSum * effect.value / 100).toInt();
          if (baseDmg > 0) {
            if (doubleNextAttack && card.type == CardType.attack) baseDmg *= 2;
            damageResult = _calcDamage(
              baseDamage: baseDmg,
              strength: 0, // 힘은 이미 합산에 포함
              playerStatuses: playerStatuses,
              enemyStatuses: enemyStatuses,
              targetBlock: effectiveEnemyBlock,
            );
          }
          break;
        case CardEffectType.healPerTurn:
          // 매 턴 HP N 회복 Power — CombatBloc에서 처리
          healPerTurnValue += effect.value;
          break;
        case CardEffectType.drawPerTurn:
          // 매 턴 드로우 +N Power — CombatBloc에서 처리
          drawPerTurnValue += effect.value;
          break;
        // ── Phase 3-B 신규 효과 ──
        case CardEffectType.lifestealOnAllAttacks:
          // Power: 모든 Attack 카드에 N% 흡혈 — CombatBloc에서 처리
          lifestealOnAllAttacksPercent += effect.value;
          break;
        case CardEffectType.healPerTurnConditional:
          // Power: 조건부 매 턴 HP 회복 — CombatBloc에서 조건 체크
          healPerTurnConditionalValue += effect.value;
          healPerTurnCondition = effect.condition;
          break;
        case CardEffectType.excessDamageLifesteal:
          // 초과(오버킬) 데미지의 N% HP 회복
          final overkillResult = damageResult;
          if (overkillResult != null && overkillResult.hpLost > enemyHp) {
            final excess = overkillResult.hpLost - enemyHp;
            healAmount += (excess * effect.value / 100).toInt();
          }
          break;
        case CardEffectType.nextSkillApDiscount:
          // 다음 Skill 카드 AP 감소 — CombatBloc에서 처리
          nextSkillApDiscountValue += effect.value;
          break;
        case CardEffectType.overflowToBlock:
          // Power: 오버킬 데미지의 N%를 블록으로 전환 — CombatBloc에서 처리
          overflowToBlockPercent += effect.value;
          break;
        case CardEffectType.cooldownAfterUse:
          // 사용 후 N턴 쿨다운 — CombatBloc에서 처리
          cooldownTurns = effect.value;
          break;
        case CardEffectType.momentumGainOnDodge:
          // Power: 회피 성공 시 기세 N — CombatBloc에서 처리
          momentumGainOnDodgeValue += effect.value;
          break;
        case CardEffectType.poisonDamageReduction:
          // Power: 적 독 스택 N당 피해 -1, 최대값 condition — CombatBloc에서 처리
          poisonDamageReductionValue += effect.value;
          poisonDamageReductionCap =
              int.tryParse(effect.condition ?? '') ?? 999;
          break;
        case CardEffectType.immuneNextHits:
          // 다음 N회 피격 무효 — CombatBloc에서 처리
          immuneNextHitsCount += effect.value;
          break;
        case CardEffectType.damageReductionWhenBlock:
          // Power: 블록 ≥ threshold 시 피해 -N — CombatBloc에서 처리
          damageReductionWhenBlockValue += effect.value;
          damageReductionWhenBlockThreshold =
              int.tryParse(effect.condition ?? '') ?? 0;
          break;
        case CardEffectType.healOnDamageTaken:
          // Power: 피격 턴 종료 시 HP N 회복 — CombatBloc에서 처리
          healOnDamageTakenValue += effect.value;
          break;
        case CardEffectType.healOnReflect:
          // Power: 반사 성공 시 HP N 회복 — CombatBloc에서 처리
          healOnReflectValue += effect.value;
          break;
        case CardEffectType.nextHitDamageReduction:
          // 다음 피격 데미지 N% 감소 — CombatBloc에서 처리
          nextHitDamageReductionPercent += effect.value;
          break;

        // ── Phase 4: 2차 전직 신규 효과 ──

        case CardEffectType.poisonEffectivenessBoost:
          // Power: 독 효과 N% 증폭 — CombatBloc에서 처리
          break;
        case CardEffectType.blockRetainFull:
          // 블록 100% 유지 — blockRetainPercent를 100으로 설정
          blockRetainPercent = 100;
          break;
        case CardEffectType.reflectDamagePercent:
          // 이번 턴 받는 데미지의 N% 반사 — CombatBloc에서 처리
          break;
        case CardEffectType.blockToDamageKeepBlock:
          // 현재 블록의 N%를 데미지, 블록 유지
          if (playerBlock > 0) {
            var baseDmg = (playerBlock * effect.value / 100).toInt();
            if (doubleNextAttack && card.type == CardType.attack) baseDmg *= 2;
            damageResult = _calcDamage(
              baseDamage: baseDmg,
              strength: playerStrength,
              playerStatuses: playerStatuses,
              enemyStatuses: enemyStatuses,
              targetBlock: effectiveEnemyBlock,
            );
          }
          break;
        case CardEffectType.blockPerTurnFixed:
          // Power: 매 턴 블록 +N — CombatBloc에서 처리
          blockPerTurnStart += effect.value;
          break;
        case CardEffectType.damageReductionAtBlock:
          // Power: 블록 ≥ condition 시 피해 -value — CombatBloc에서 처리
          damageReductionWhenBlockValue += effect.value;
          damageReductionWhenBlockThreshold =
              int.tryParse(effect.condition ?? '') ?? 0;
          break;
        case CardEffectType.randomBuff:
          // 랜덤 버프 1개 부여 — CombatBloc에서 처리
          randomBuffCount += effect.value;
          break;
        case CardEffectType.retrieveFromExhaustPile:
          // 소진 파일에서 N장 복원 (retrieveFromExhaust 별칭)
          final count = effect.value.clamp(0, updatedDeck.exhaustPile.length);
          if (count > 0) {
            final retrieved = updatedDeck.exhaustPile.take(count).toList();
            updatedDeck = DeckState(
              drawPile: updatedDeck.drawPile,
              hand: [...updatedDeck.hand, ...retrieved],
              discardPile: updatedDeck.discardPile,
              exhaustPile: updatedDeck.exhaustPile.skip(count).toList(),
            );
          }
          break;
        case CardEffectType.exhaustPileCountDamage:
          // 소진된 카드 수 × N 데미지
          final exhaustCount = updatedDeck.exhaustPile.length;
          if (exhaustCount > 0) {
            var baseDmg = exhaustCount * effect.value;
            if (doubleNextAttack && card.type == CardType.attack) baseDmg *= 2;
            damageResult = _calcDamage(
              baseDamage: baseDmg,
              strength: playerStrength,
              playerStatuses: playerStatuses,
              enemyStatuses: enemyStatuses,
              targetBlock: effectiveEnemyBlock,
            );
          }
          break;
        case CardEffectType.generateRandomCardAndHealPerTurn:
          // Power: 매 턴 랜덤 카드 + HP N 회복 — CombatBloc에서 처리
          generateCardCount += 1;
          healPerTurnValue += effect.value;
          break;
        case CardEffectType.executeHpPercentInstantKill:
          // 적 HP ≤ N%: 즉사 (즉사 확장)
          executeHpPercent = effect.value;
          break;
        case CardEffectType.lifestealWithSelfDamage:
          // 자해 포함 흡혈 — lifesteal과 동일 처리
          if (damageResult != null) {
            healAmount += (damageResult.hpLost * effect.value / 100).toInt();
          }
          break;
        case CardEffectType.lostHpMultiplierDamage:
          // 잃은 HP × (value/100) 데미지
          final lostHp = playerMaxHp - playerHp;
          if (lostHp > 0) {
            var baseDmg = (lostHp * effect.value / 100).toInt();
            if (doubleNextAttack && card.type == CardType.attack) baseDmg *= 2;
            damageResult = _calcDamage(
              baseDamage: baseDmg,
              strength: playerStrength,
              playerStatuses: playerStatuses,
              enemyStatuses: enemyStatuses,
              targetBlock: effectiveEnemyBlock,
            );
          }
          break;
        case CardEffectType.emergencyBlockAndHeal:
          // HP < condition%일 때 value 블록 + duration HP 회복
          final threshold = int.tryParse(effect.condition ?? '') ?? 20;
          if (playerHp < (playerMaxHp * threshold / 100).toInt()) {
            blockGained += effect.value;
            healAmount += effect.duration ?? 0;
          }
          break;
        case CardEffectType.copyLastAttackToHand:
          // 마지막 Attack 카드 복제 — CombatBloc에서 처리
          requestCopyLastAttack = true;
          break;
        case CardEffectType.copyLastCardMultiple:
          // 마지막 카드 N회 복제 — CombatBloc에서 처리
          replayLastCardCount += effect.value;
          break;
        case CardEffectType.allAttackPiercing:
          // Power: 모든 Attack 관통 — CombatBloc에서 처리
          setAllAttackPiercing = true;
          break;
        case CardEffectType.handCountBlock:
          // 손패 수 × N 추가 블록 (handSizeBlock 별칭)
          blockGained += updatedDeck.handCount * effect.value;
          break;
        case CardEffectType.drawPerTurnAndSkillDiscount:
          // 매 턴 드로우 +N + Skill AP 할인 — CombatBloc에서 처리
          drawPerTurnValue += effect.value;
          break;
        case CardEffectType.allSkillApDiscount:
          // Power: 모든 Skill AP -N — CombatBloc에서 처리
          allSkillApDiscountValue += effect.value;
          break;
        case CardEffectType.lifestealOnAllAttacksPercent:
          // Power: 모든 Attack에 N% 흡혈 — lifestealOnAllAttacks와 동일
          lifestealOnAllAttacksPercent += effect.value;
          break;
        case CardEffectType.healPercentOfDamageDealt:
          // 준 데미지의 N% HP 회복
          if (damageResult != null) {
            healAmount += (damageResult.hpLost * effect.value / 100).toInt();
          }
          break;
        case CardEffectType.nextAttackDamageBoost:
          // 다음 Attack 데미지 +N% — doubleNextAttack 유사 처리
          setDoubleNextAttack = true;
          break;
        case CardEffectType.poisonPerTurnAndDraw:
          // Power: 매 턴 독 value + 드로우 +duration — CombatBloc에서 처리
          poisonPerTurnStart += effect.value;
          drawPerTurnValue += (effect.duration ?? 0);
          break;
        case CardEffectType.blockToDamagePartialRetain:
          // 블록 × value% 데미지, 블록 duration% 유지
          if (playerBlock > 0) {
            var baseDmg = (playerBlock * effect.value / 100).toInt();
            if (doubleNextAttack && card.type == CardType.attack) baseDmg *= 2;
            damageResult = _calcDamage(
              baseDamage: baseDmg,
              strength: playerStrength,
              playerStatuses: playerStatuses,
              enemyStatuses: enemyStatuses,
              targetBlock: effectiveEnemyBlock,
            );
            blockRetainPercent = effect.duration ?? 50;
          }
          break;
        case CardEffectType.blockRetainPercentAndStrength:
          // Power: 블록 유지 condition% + 힘 +value — CombatBloc에서 처리
          blockRetainPercent = int.tryParse(effect.condition ?? '') ?? 60;
          newPlayerStatuses.add(StatusEffect(
            type: StatusEffectType.strength,
            stacks: effect.value,
          ));
          break;
        case CardEffectType.convertPoisonToDamageAndHeal:
          // 적 독 스택 → 데미지 + HP 회복 전환
          final poisonStacks = StatusEffectProcessor.stacks(
            enemyStatuses,
            StatusEffectType.poison,
          );
          if (poisonStacks > 0) {
            final multiplier = effect.value > 1 ? effect.value / 100.0 : 1.0;
            var baseDmg = (poisonStacks * multiplier).toInt();
            if (doubleNextAttack && card.type == CardType.attack) baseDmg *= 2;
            damageResult = _calcDamage(
              baseDamage: baseDmg,
              strength: playerStrength,
              playerStatuses: playerStatuses,
              enemyStatuses: enemyStatuses,
              targetBlock: effectiveEnemyBlock,
            );
            healAmount += poisonStacks;
            // 독 제거
            newEnemyStatuses.add(StatusEffect(
              type: StatusEffectType.poison,
              stacks: -poisonStacks,
            ));
          }
          break;
        case CardEffectType.damageOnCleanse:
          // Power: 정화 시 적에게 N 데미지 — CombatBloc에서 처리
          break;
        case CardEffectType.multiHitPiercing:
          // 다회 관통 공격: value 데미지 × duration 회 (블록 무시)
          final hits = effect.duration ?? 3;
          int totalHpLost = 0;
          int totalFinalDmg = 0;
          for (var i = 0; i < hits; i++) {
            var hitBaseDmg = effect.value;
            if (doubleNextAttack && card.type == CardType.attack) hitBaseDmg *= 2;
            final hitResult = _calcDamage(
              baseDamage: hitBaseDmg,
              strength: playerStrength,
              playerStatuses: playerStatuses,
              enemyStatuses: enemyStatuses,
              targetBlock: 0, // 관통: 블록 무시
            );
            totalHpLost += hitResult.hpLost;
            totalFinalDmg += hitResult.finalDamage;
          }
          damageResult = DamageResult(
            rawDamage: effect.value * hits,
            strengthBonus: playerStrength * hits,
            finalDamage: totalFinalDmg,
            blockAbsorbed: 0,
            hpLost: totalHpLost,
          );
          break;
        case CardEffectType.allStatsDamage:
          // (힘+민첩+가시) × value 데미지
          final thornStacks = StatusEffectProcessor.stacks(
            playerStatuses,
            StatusEffectType.thorn,
          );
          var baseDmg = (playerStrength + playerDexterity + thornStacks) * effect.value;
          if (baseDmg > 0) {
            if (doubleNextAttack && card.type == CardType.attack) baseDmg *= 2;
            damageResult = _calcDamage(
              baseDamage: baseDmg,
              strength: 0, // 이미 합산에 포함
              playerStatuses: playerStatuses,
              enemyStatuses: enemyStatuses,
              targetBlock: effectiveEnemyBlock,
            );
          }
          break;
        case CardEffectType.boostLowestStatPerTurn:
          // Power: 매 턴 최저 스탯 +N — CombatBloc에서 처리
          boostLowestStatValue += effect.value;
          break;
        case CardEffectType.cardsPlayedDamage:
          // 이번 턴 사용 카드 수 × N 데미지
          final cardsPlayed = attacksPlayedThisTurn + skillsPlayedThisTurn;
          if (cardsPlayed > 0) {
            var baseDmg = cardsPlayed * effect.value;
            if (doubleNextAttack && card.type == CardType.attack) baseDmg *= 2;
            damageResult = _calcDamage(
              baseDamage: baseDmg,
              strength: playerStrength,
              playerStatuses: playerStatuses,
              enemyStatuses: enemyStatuses,
              targetBlock: effectiveEnemyBlock,
            );
          }
          break;
        case CardEffectType.equalizeHpAndBlock:
          // HP와 블록 균등화
          final avg = ((playerHp + playerBlock) / 2).toInt();
          blockGained = avg - playerBlock;
          if (blockGained < 0) blockGained = 0;
          selfDamage += (playerHp - avg).clamp(0, playerHp);
          break;
        case CardEffectType.revealIntentAndDraw:
          // 적 의도 공개 + N장 드로우
          drawCount += effect.value;
          break;
        case CardEffectType.poisonPerTurnAndDodge:
          // Power: 매 턴 독 value + 회피 condition% — CombatBloc에서 처리
          poisonPerTurnStart += effect.value;
          dodgeChancePercent += int.tryParse(effect.condition ?? '') ?? 0;
          break;
        case CardEffectType.poisonStackMultiplierDamage:
          // 적 독 스택 × N 데미지
          final poisonStacks = StatusEffectProcessor.stacks(
            enemyStatuses,
            StatusEffectType.poison,
          );
          if (poisonStacks > 0) {
            var baseDmg = poisonStacks * effect.value;
            if (doubleNextAttack && card.type == CardType.attack) baseDmg *= 2;
            damageResult = _calcDamage(
              baseDamage: baseDmg,
              strength: playerStrength,
              playerStatuses: playerStatuses,
              enemyStatuses: enemyStatuses,
              targetBlock: effectiveEnemyBlock,
            );
          }
          break;
        case CardEffectType.multiHitWithPoison:
          // 다회 공격 + 각 히트마다 독 N
          final hits = effect.duration ?? 4;
          final poisonPerHit = int.tryParse(effect.condition ?? '') ?? 2;
          var remainingBlock = effectiveEnemyBlock;
          int totalHpLost = 0;
          int totalBlockAbsorbed = 0;
          int totalFinalDmg = 0;
          for (var i = 0; i < hits; i++) {
            var hitBaseDmg = effect.value;
            if (doubleNextAttack && card.type == CardType.attack) hitBaseDmg *= 2;
            final hitResult = _calcDamage(
              baseDamage: hitBaseDmg,
              strength: playerStrength,
              playerStatuses: playerStatuses,
              enemyStatuses: enemyStatuses,
              targetBlock: remainingBlock,
            );
            totalHpLost += hitResult.hpLost;
            totalBlockAbsorbed += hitResult.blockAbsorbed;
            totalFinalDmg += hitResult.finalDamage;
            remainingBlock =
                (remainingBlock - hitResult.blockAbsorbed).clamp(0, 99999);
          }
          damageResult = DamageResult(
            rawDamage: effect.value * hits,
            strengthBonus: playerStrength * hits,
            finalDamage: totalFinalDmg,
            blockAbsorbed: totalBlockAbsorbed,
            hpLost: totalHpLost,
          );
          // 독 총량 적용
          newEnemyStatuses.add(StatusEffect(
            type: StatusEffectType.poison,
            stacks: poisonPerHit * hits,
          ));
          break;
      }
    }

    // Exhaust 처리: Power 카드는 장르 관례상 사용 후 소진 (버림 더미 미진입)
    if (card.isExhaust || card.type == CardType.power) {
      updatedDeck = DeckManager.exhaustFromHand(updatedDeck, card.id, handIndex: handIndex);
    } else {
      updatedDeck = DeckManager.discardFromHand(updatedDeck, card.id, handIndex: handIndex);
    }

    return CardPlayResult(
      card: card,
      damageResult: damageResult,
      blockGained: blockGained,
      selfDamage: selfDamage,
      healAmount: healAmount,
      drawCount: drawCount,
      apGain: apGain,
      newPlayerStatuses: newPlayerStatuses,
      newEnemyStatuses: newEnemyStatuses,
      updatedDeck: updatedDeck,
      setImmuneThisTurn: setImmuneThisTurn,
      setDoubleNextAttack: setDoubleNextAttack,
      requestCopyLastAttack: requestCopyLastAttack,
      apModifierNextTurn: apModifierNextTurn,
      setExhaustHandAtTurnEnd: setExhaustHandAtTurnEnd,
      poisonPerTurnStart: poisonPerTurnStart,
      requestCleanse: requestCleanse,
      blockPerTurnStart: blockPerTurnStart,
      conditionalBlockPerTurnStart: conditionalBlockPerTurnStart,
      blockRetainPercent: blockRetainPercent,
      retrievePerTurn: retrievePerTurn,
      mimicEnemyMultiplier: mimicEnemyMultiplier,
      generateCardCount: generateCardCount,
      blockPerCardPlayedValue: blockPerCardPlayedValue,
      randomDebuffCount: randomDebuffCount,
      executeHpPercent: executeHpPercent,
      healOnKill: healOnKill,
      selfDamagePerTurn: selfDamagePerTurn,
      strengthPerTurn: strengthPerTurn,
      absorbStrengthValue: absorbStrengthValue,
      generateAttackPerTurn: generateAttackPerTurn,
      replayLastCardCount: replayLastCardCount,
      boostLowestStatValue: boostLowestStatValue,
      setAllTypesApBonus: setAllTypesApBonus,
      setTransformHand: setTransformHand,
      adaptiveDamageHigh: adaptiveDamageHigh,
      adaptiveDamageLow: adaptiveDamageLow,
      regenNullifyTurns: regenNullifyTurns,
      stunEnemyTurns: stunEnemyTurns,
      resetEnemyBuff: resetEnemyBuff,
      drainNullifyTurns: drainNullifyTurns,
      momentumGainAmount: momentumGainAmount,
      setFleeGuaranteed: setFleeGuaranteed,
      dodgeChancePercent: dodgeChancePercent,
      lostHpToBlockPerTurnPercent: lostHpToBlockPerTurnPercent,
      remainingApBlockValue: remainingApBlockValue,
      reflectDamageChancePercent: reflectDamageChancePercent,
      requestSwapStrDex: requestSwapStrDex,
      healPerTurnValue: healPerTurnValue,
      drawPerTurnValue: drawPerTurnValue,
      lifestealOnAllAttacksPercent: lifestealOnAllAttacksPercent,
      healPerTurnConditionalValue: healPerTurnConditionalValue,
      healPerTurnCondition: healPerTurnCondition,
      nextSkillApDiscountValue: nextSkillApDiscountValue,
      overflowToBlockPercent: overflowToBlockPercent,
      cooldownTurns: cooldownTurns,
      momentumGainOnDodgeValue: momentumGainOnDodgeValue,
      poisonDamageReductionValue: poisonDamageReductionValue,
      poisonDamageReductionCap: poisonDamageReductionCap,
      immuneNextHitsCount: immuneNextHitsCount,
      damageReductionWhenBlockValue: damageReductionWhenBlockValue,
      damageReductionWhenBlockThreshold: damageReductionWhenBlockThreshold,
      healOnDamageTakenValue: healOnDamageTakenValue,
      healOnReflectValue: healOnReflectValue,
      nextHitDamageReductionPercent: nextHitDamageReductionPercent,
      setAllAttackPiercing: setAllAttackPiercing,
      allSkillApDiscountValue: allSkillApDiscountValue,
      randomBuffCount: randomBuffCount,
    );
  }

  /// 약화/취약 반영 데미지 계산 — resolve 내부 반복 패턴 추출.
  static DamageResult _calcDamage({
    required int baseDamage,
    required int strength,
    required List<StatusEffect> playerStatuses,
    required List<StatusEffect> enemyStatuses,
    required int targetBlock,
  }) {
    final isWeakened = StatusEffectProcessor.hasActive(
      playerStatuses,
      StatusEffectType.weak,
    );
    final isVulnerable = StatusEffectProcessor.hasActive(
      enemyStatuses,
      StatusEffectType.vulnerable,
    );
    return DamageCalculator.calculatePlayerDamage(
      baseDamage: baseDamage,
      strength: strength,
      isWeakened: isWeakened,
      targetIsVulnerable: isVulnerable,
      targetBlock: targetBlock,
    );
  }

  static bool _checkCondition(
    String? condition, {
    int momentumTier = 1,
    int currentTurn = 0,
    int attacksPlayedThisTurn = 0,
    int playerHp = 100,
    int playerMaxHp = 100,
  }) {
    if (condition == null) return true;
    switch (condition) {
      case 'momentumTier':
        return true; // conditionalDamage에서 별도 처리
      case 'lowHp':
        return playerHp < (playerMaxHp * 0.5).toInt();
      case 'firstTurnOnly':
        return currentTurn == 0;
      case 'chainAttackOnly':
        return attacksPlayedThisTurn > 0;
      case 'highMomentum':
        return momentumTier >= 3;
      case 'criticalHp':
        return playerHp < (playerMaxHp * 0.3).toInt();
      default:
        return true;
    }
  }
}

/// 카드 플레이 결과.
class CardPlayResult {
  final CardData card;
  final DamageResult? damageResult;
  final int blockGained;
  final int selfDamage;
  final int healAmount;
  final int drawCount;
  final int apGain;
  final List<StatusEffect> newPlayerStatuses;
  final List<StatusEffect> newEnemyStatuses;
  final DeckState updatedDeck;

  /// CombatBloc에서 처리할 플래그.
  final bool setImmuneThisTurn;
  final bool setDoubleNextAttack;
  final bool requestCopyLastAttack;
  final int apModifierNextTurn;
  final bool setExhaustHandAtTurnEnd;
  final int poisonPerTurnStart;
  final bool requestCleanse;
  final int blockPerTurnStart;
  final int conditionalBlockPerTurnStart;

  /// 수호자/방랑자 카드 효과 플래그.
  final int blockRetainPercent;
  final int retrievePerTurn;
  final int mimicEnemyMultiplier;
  final int generateCardCount;
  final int blockPerCardPlayedValue;
  final int randomDebuffCount;

  /// 히든 직업 카드 효과 플래그.
  final int executeHpPercent;
  final int healOnKill;
  final int selfDamagePerTurn;
  final int strengthPerTurn;
  final int absorbStrengthValue;
  final int generateAttackPerTurn;
  final int replayLastCardCount;
  final int boostLowestStatValue;
  final bool setAllTypesApBonus;
  final bool setTransformHand;
  final int adaptiveDamageHigh;
  final int adaptiveDamageLow;

  /// 보스 환경카드 효과 플래그.
  final int regenNullifyTurns;
  final int stunEnemyTurns;
  final bool resetEnemyBuff;
  final int drainNullifyTurns;

  /// 무색 카드 효과 플래그.
  final int momentumGainAmount;
  final bool setFleeGuaranteed;

  /// 콘텐츠 확장 카드 효과 플래그.
  final int dodgeChancePercent;
  final int lostHpToBlockPerTurnPercent;
  final int remainingApBlockValue;
  final int reflectDamageChancePercent;
  final bool requestSwapStrDex;
  final int healPerTurnValue;
  final int drawPerTurnValue;

  /// Phase 3-B 신규 효과 플래그.
  final int lifestealOnAllAttacksPercent;
  final int healPerTurnConditionalValue;
  final String? healPerTurnCondition;
  final int nextSkillApDiscountValue;
  final int overflowToBlockPercent;
  final int cooldownTurns;
  final int momentumGainOnDodgeValue;
  final int poisonDamageReductionValue;
  final int poisonDamageReductionCap;
  final int immuneNextHitsCount;
  final int damageReductionWhenBlockValue;
  final int damageReductionWhenBlockThreshold;
  final int healOnDamageTakenValue;
  final int healOnReflectValue;
  final int nextHitDamageReductionPercent;

  /// Phase 4 Power 효과 플래그.
  final bool setAllAttackPiercing;
  final int allSkillApDiscountValue;
  final int randomBuffCount;

  const CardPlayResult({
    required this.card,
    this.damageResult,
    this.blockGained = 0,
    this.selfDamage = 0,
    this.healAmount = 0,
    this.drawCount = 0,
    this.apGain = 0,
    this.newPlayerStatuses = const [],
    this.newEnemyStatuses = const [],
    required this.updatedDeck,
    this.setImmuneThisTurn = false,
    this.setDoubleNextAttack = false,
    this.requestCopyLastAttack = false,
    this.apModifierNextTurn = 0,
    this.setExhaustHandAtTurnEnd = false,
    this.poisonPerTurnStart = 0,
    this.requestCleanse = false,
    this.blockPerTurnStart = 0,
    this.conditionalBlockPerTurnStart = 0,
    this.blockRetainPercent = 0,
    this.retrievePerTurn = 0,
    this.mimicEnemyMultiplier = 0,
    this.generateCardCount = 0,
    this.blockPerCardPlayedValue = 0,
    this.randomDebuffCount = 0,
    this.executeHpPercent = 0,
    this.healOnKill = 0,
    this.selfDamagePerTurn = 0,
    this.strengthPerTurn = 0,
    this.absorbStrengthValue = 0,
    this.generateAttackPerTurn = 0,
    this.replayLastCardCount = 0,
    this.boostLowestStatValue = 0,
    this.setAllTypesApBonus = false,
    this.setTransformHand = false,
    this.adaptiveDamageHigh = 0,
    this.adaptiveDamageLow = 0,
    this.regenNullifyTurns = 0,
    this.stunEnemyTurns = 0,
    this.resetEnemyBuff = false,
    this.drainNullifyTurns = 0,
    this.momentumGainAmount = 0,
    this.setFleeGuaranteed = false,
    this.dodgeChancePercent = 0,
    this.lostHpToBlockPerTurnPercent = 0,
    this.remainingApBlockValue = 0,
    this.reflectDamageChancePercent = 0,
    this.requestSwapStrDex = false,
    this.healPerTurnValue = 0,
    this.drawPerTurnValue = 0,
    this.lifestealOnAllAttacksPercent = 0,
    this.healPerTurnConditionalValue = 0,
    this.healPerTurnCondition,
    this.nextSkillApDiscountValue = 0,
    this.overflowToBlockPercent = 0,
    this.cooldownTurns = 0,
    this.momentumGainOnDodgeValue = 0,
    this.poisonDamageReductionValue = 0,
    this.poisonDamageReductionCap = 0,
    this.immuneNextHitsCount = 0,
    this.damageReductionWhenBlockValue = 0,
    this.damageReductionWhenBlockThreshold = 0,
    this.healOnDamageTakenValue = 0,
    this.healOnReflectValue = 0,
    this.nextHitDamageReductionPercent = 0,
    this.setAllAttackPiercing = false,
    this.allSkillApDiscountValue = 0,
    this.randomBuffCount = 0,
  });
}
