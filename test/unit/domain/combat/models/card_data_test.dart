import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

void main() {
  group('CardData', () {
    const strike = CardData(
      id: 'strike_1',
      name: '타격',
      type: CardType.attack,
      apCost: 1,
      damage: 6,
      description: '6 데미지',
    );

    const defend = CardData(
      id: 'defend_1',
      name: '방어',
      type: CardType.skill,
      apCost: 1,
      block: 5,
      description: '블록 5',
    );

    const warCry = CardData(
      id: 'war_cry',
      name: '전쟁함성',
      jobId: 'warrior',
      type: CardType.power,
      apCost: 1,
      description: '힘 +2 (영구)',
      effects: [
        CardEffect(type: CardEffectType.gainStrength, value: 2),
      ],
    );

    const bloodOath = CardData(
      id: 'blood_oath',
      name: '피의 맹세',
      jobId: 'warrior',
      type: CardType.skill,
      apCost: 0,
      description: 'HP -6, 힘 +3, 1장 드로우. 소진',
      keywords: {CardKeyword.exhaust},
      effects: [
        CardEffect(type: CardEffectType.selfDamage, value: 6),
        CardEffect(type: CardEffectType.gainStrength, value: 3),
        CardEffect(type: CardEffectType.draw, value: 1),
      ],
    );

    test('기본 필드 생성', () {
      expect(strike.id, 'strike_1');
      expect(strike.name, '타격');
      expect(strike.type, CardType.attack);
      expect(strike.apCost, 1);
      expect(strike.damage, 6);
      expect(strike.block, isNull);
      expect(strike.upgraded, false);
      expect(strike.keywords, isEmpty);
      expect(strike.effects, isEmpty);
    });

    test('방어 카드 — block 값 설정', () {
      expect(defend.block, 5);
      expect(defend.damage, isNull);
      expect(defend.type, CardType.skill);
    });

    test('파워 카드 — 효과 목록', () {
      expect(warCry.type, CardType.power);
      expect(warCry.effects, hasLength(1));
      expect(warCry.effects.first.type, CardEffectType.gainStrength);
      expect(warCry.effects.first.value, 2);
    });

    test('isColorless — jobId null이면 true', () {
      expect(strike.isColorless, true);
      expect(warCry.isColorless, false);
    });

    test('키워드 편의 getter', () {
      expect(bloodOath.isExhaust, true);
      expect(bloodOath.isInnate, false);
      expect(bloodOath.isEthereal, false);
      expect(bloodOath.isRetain, false);
      expect(bloodOath.hasKeyword, true);
      expect(strike.hasKeyword, false);
    });

    test('copyWith — 업그레이드 버전 생성', () {
      final upgraded = strike.copyWith(
        id: 'strike_1+',
        damage: 8,
        description: '8 데미지',
        upgraded: true,
      );
      expect(upgraded.id, 'strike_1+');
      expect(upgraded.damage, 8);
      expect(upgraded.upgraded, true);
      expect(upgraded.name, '타격'); // 변경 안 된 필드 유지
    });

    test('Equatable 동등성', () {
      const strike2 = CardData(
        id: 'strike_1',
        name: '타격',
        type: CardType.attack,
        apCost: 1,
        damage: 6,
        description: '6 데미지',
      );
      expect(strike, equals(strike2));
    });

    test('Equatable 비동등성 — 다른 id', () {
      const strike2 = CardData(
        id: 'strike_2',
        name: '타격',
        type: CardType.attack,
        apCost: 1,
        damage: 6,
        description: '6 데미지',
      );
      expect(strike, isNot(equals(strike2)));
    });
  });

  group('CardEffect', () {
    test('기본 생성', () {
      const effect = CardEffect(type: CardEffectType.draw, value: 10);
      expect(effect.type, CardEffectType.draw);
      expect(effect.value, 10);
      expect(effect.condition, isNull);
      expect(effect.duration, isNull);
    });

    test('조건부 효과', () {
      const effect = CardEffect(
        type: CardEffectType.conditionalDamage,
        value: 16,
        condition: 'firstTurn',
      );
      expect(effect.condition, 'firstTurn');
    });

    test('상태 효과 지속 시간', () {
      const effect = CardEffect(
        type: CardEffectType.applyWeak,
        value: 1,
        duration: 2,
      );
      expect(effect.duration, 2);
    });

    test('Equatable 동등성', () {
      const e1 = CardEffect(type: CardEffectType.draw, value: 1);
      const e2 = CardEffect(type: CardEffectType.draw, value: 1);
      expect(e1, equals(e2));
    });
  });
}
