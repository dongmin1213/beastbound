import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/domain/combat/logic/combat_defeat_handler.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/core/models/player_run_state.dart';

void main() {
  group('CombatDefeatHandler', () {
    const config = CombatBalanceConfig(
      normalDefeatHpLoss: 30,
      eliteDefeatHpLoss: 50,
    );

    test('calculateHpLoss returns eliteDefeatHpLoss for elite rooms', () {
      final loss = CombatDefeatHandler.calculateHpLoss(RoomType.elite, config);
      expect(loss, 50);
    });

    test('calculateHpLoss returns normalDefeatHpLoss for non-elite rooms', () {
      final loss = CombatDefeatHandler.calculateHpLoss(RoomType.combat, config);
      expect(loss, 30);
    });

    // === Story 3-8: 보스 패배 HP 손실 ===

    test('calculateHpLoss returns bossDefeatHpLoss for boss rooms', () {
      const bossConfig = CombatBalanceConfig(
        normalDefeatHpLoss: 30,
        eliteDefeatHpLoss: 50,
        bossDefeatHpLoss: 9999,
      );
      final loss = CombatDefeatHandler.calculateHpLoss(RoomType.boss, bossConfig);
      expect(loss, 9999);
    });

    test('applyDamage reduces HP correctly', () {
      final state = PlayerRunState(currentHp: 100, maxHp: 100);
      final result = CombatDefeatHandler.applyDamage(state, 30);
      expect(result.currentHp, 70);
      expect(result.maxHp, 100);
    });

    test('applyDamage clamps HP to 0 when loss equals currentHp', () {
      final state = PlayerRunState(currentHp: 30, maxHp: 100);
      final result = CombatDefeatHandler.applyDamage(state, 30);
      expect(result.currentHp, 0);
    });

    test('applyDamage clamps HP to 0 when loss exceeds currentHp', () {
      final state = PlayerRunState(currentHp: 20, maxHp: 100);
      final result = CombatDefeatHandler.applyDamage(state, 30);
      expect(result.currentHp, 0);
    });

    test('applyDamage survival when HP remains 1', () {
      final state = PlayerRunState(currentHp: 31, maxHp: 100);
      final result = CombatDefeatHandler.applyDamage(state, 30);
      expect(result.currentHp, 1);
      expect(result.isAlive, true);
    });

    test('isPermadeath returns true when not alive', () {
      final dead = PlayerRunState(currentHp: 0, maxHp: 100);
      final alive = PlayerRunState(currentHp: 1, maxHp: 100);

      expect(CombatDefeatHandler.isPermadeath(dead), true);
      expect(CombatDefeatHandler.isPermadeath(alive), false);
    });
  });

  group('CombatDefeatHandler.hpNarrationTier', () {
    test('returns healthy for 70%+ HP', () {
      final state = PlayerRunState(currentHp: 71, maxHp: 100);
      expect(
        CombatDefeatHandler.hpNarrationTier(state),
        HpNarrationTier.healthy,
      );
    });

    test('returns wounded for 50-70% HP', () {
      final state = PlayerRunState(currentHp: 70, maxHp: 100);
      expect(
        CombatDefeatHandler.hpNarrationTier(state),
        HpNarrationTier.wounded,
      );

      final state2 = PlayerRunState(currentHp: 51, maxHp: 100);
      expect(
        CombatDefeatHandler.hpNarrationTier(state2),
        HpNarrationTier.wounded,
      );
    });

    test('returns critical for 30-50% HP', () {
      final state = PlayerRunState(currentHp: 50, maxHp: 100);
      expect(
        CombatDefeatHandler.hpNarrationTier(state),
        HpNarrationTier.critical,
      );

      final state2 = PlayerRunState(currentHp: 31, maxHp: 100);
      expect(
        CombatDefeatHandler.hpNarrationTier(state2),
        HpNarrationTier.critical,
      );
    });

    test('returns danger for 0-30% HP (but alive)', () {
      final state = PlayerRunState(currentHp: 30, maxHp: 100);
      expect(
        CombatDefeatHandler.hpNarrationTier(state),
        HpNarrationTier.danger,
      );

      final state2 = PlayerRunState(currentHp: 1, maxHp: 100);
      expect(
        CombatDefeatHandler.hpNarrationTier(state2),
        HpNarrationTier.danger,
      );
    });

    test('returns dead for 0% HP', () {
      final state = PlayerRunState(currentHp: 0, maxHp: 100);
      expect(
        CombatDefeatHandler.hpNarrationTier(state),
        HpNarrationTier.dead,
      );
    });
  });
}
