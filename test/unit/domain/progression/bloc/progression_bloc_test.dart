import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/core/save/save_data.dart';
import 'package:soul_dungeon/domain/progression/bloc/progression_bloc.dart';
import 'package:soul_dungeon/domain/progression/bloc/progression_event.dart';
import 'package:soul_dungeon/domain/progression/bloc/progression_state.dart';

/// Helper: add event and wait for Bloc to process it.
Future<void> _tick() => Future<void>.delayed(Duration.zero);

void main() {
  late GameEventBus gameEventBus;
  late ProgressionBloc bloc;

  /// Default EconomyConfig has soulBaseGain = 8.
  const economyConfig = EconomyConfig();

  setUp(() {
    gameEventBus = GameEventBus();
    bloc = ProgressionBloc(
      gameEventBus: gameEventBus,
      economyConfig: economyConfig,
    );
  });

  tearDown(() {
    bloc.close();
    gameEventBus.dispose();
  });

  // ── 1. Initial state ──────────────────────────────────────────────

  group('initial state', () {
    test('initial state is ProgressionInitial', () {
      expect(bloc.state, isA<ProgressionInitial>());
    });
  });

  // ── 2. initialize() ───────────────────────────────────────────────

  group('initialize()', () {
    test('sets ProgressionLoaded with given MetaSaveData', () async {
      const meta = MetaSaveData(soulCount: 42, totalRuns: 3);
      bloc.initialize(meta);
      await _tick();

      expect(bloc.state, isA<ProgressionLoaded>());
      final loaded = bloc.state as ProgressionLoaded;
      expect(loaded.soulCount, 42);
      expect(loaded.totalRuns, 3);
    });
  });

  // ── 3. GainSoul ───────────────────────────────────────────────────

  group('GainSoul', () {
    test('increases soulCount by given amount', () async {
      bloc.initialize(const MetaSaveData(soulCount: 10));
      await _tick();

      bloc.add(const GainSoul(25));
      await _tick();

      final loaded = bloc.state as ProgressionLoaded;
      expect(loaded.soulCount, 35);
    });
  });

  // ── 4. RecordDeath ────────────────────────────────────────────────

  group('RecordDeath', () {
    test(
      'at floor 3 adds 24 souls (3 x soulBaseGain=8), '
      'increments deathCount and totalRuns',
      () async {
        bloc.initialize(const MetaSaveData(soulCount: 0));
        await _tick();

        bloc.add(const RecordDeath(floorReached: 3));
        await _tick();

        final loaded = bloc.state as ProgressionLoaded;
        // soulCount: 0 + (3 * 8) = 24
        expect(loaded.soulCount, 24);
        expect(loaded.deathCount, 1);
        expect(loaded.totalRuns, 1);
      },
    );
  });

  // ── 5. RecordRunCompletion ────────────────────────────────────────

  group('RecordRunCompletion', () {
    test(
      'adds 80 souls (soulBaseGain=8 x 10), '
      'increments clearCount and totalRuns, records ending',
      () async {
        bloc.initialize(const MetaSaveData(soulCount: 0));
        await _tick();

        bloc.add(const RecordRunCompletion(endingName: 'true_ending'));
        await _tick();

        final loaded = bloc.state as ProgressionLoaded;
        // soulCount: 0 + (8 * 10) = 80
        expect(loaded.soulCount, 80);
        expect(loaded.clearCount, 1);
        expect(loaded.totalRuns, 1);
        expect(loaded.endingsReached, contains('true_ending'));
      },
    );
  });

  // ── 6. PurchaseUpgrade — success ──────────────────────────────────

  group('PurchaseUpgrade', () {
    test('with enough souls deducts price and increases level', () async {
      // soul_starting_deck_upgrade: basePrice=30, maxLevel=1
      // At currentLevel=0 price = (30 * (0+1)^1.5).toInt() = 30
      bloc.initialize(const MetaSaveData(soulCount: 100));
      await _tick();

      bloc.add(const PurchaseUpgrade('soul_starting_deck_upgrade'));
      await _tick();

      final loaded = bloc.state as ProgressionLoaded;
      expect(loaded.soulCount, 70); // 100 - 30
      expect(loaded.upgradeLevels['soul_starting_deck_upgrade'], 1);
    });

    // ── 7. PurchaseUpgrade — insufficient souls ─────────────────────

    test('with insufficient souls keeps state unchanged', () async {
      bloc.initialize(const MetaSaveData(soulCount: 10));
      await _tick();

      final stateBefore = bloc.state as ProgressionLoaded;

      bloc.add(const PurchaseUpgrade('soul_starting_deck_upgrade'));
      await _tick();

      final stateAfter = bloc.state as ProgressionLoaded;
      expect(stateAfter.soulCount, stateBefore.soulCount);
      expect(stateAfter.upgradeLevels, stateBefore.upgradeLevels);
    });

    // ── 8. PurchaseUpgrade — already maxed ──────────────────────────

    test('on maxed upgrade keeps state unchanged', () async {
      // Pre-set upgrade to maxLevel (1 for soul_starting_deck_upgrade)
      bloc.initialize(const MetaSaveData(
        soulCount: 200,
        upgradeLevels: {'soul_starting_deck_upgrade': 1},
        purchasedUpgradeIds: {'soul_starting_deck_upgrade'},
      ));
      await _tick();

      final stateBefore = bloc.state as ProgressionLoaded;

      bloc.add(const PurchaseUpgrade('soul_starting_deck_upgrade'));
      await _tick();

      final stateAfter = bloc.state as ProgressionLoaded;
      expect(stateAfter.soulCount, stateBefore.soulCount);
      expect(stateAfter.upgradeLevels, stateBefore.upgradeLevels);
    });
  });

  // ── 9. UnlockMemory ───────────────────────────────────────────────

  group('UnlockMemory', () {
    test('adds memoryId to unlockedMemoryIds', () async {
      bloc.initialize(const MetaSaveData());
      await _tick();

      bloc.add(const UnlockMemory('memory_001'));
      await _tick();

      final loaded = bloc.state as ProgressionLoaded;
      expect(loaded.unlockedMemoryIds, contains('memory_001'));
    });

    // ── 10. UnlockMemory — duplicate ────────────────────────────────

    test('duplicate memoryId does not change state', () async {
      bloc.initialize(const MetaSaveData(
        unlockedMemoryIds: {'memory_001'},
      ));
      await _tick();

      final stateBefore = bloc.state as ProgressionLoaded;
      final memoryCountBefore = stateBefore.unlockedMemoryIds.length;

      bloc.add(const UnlockMemory('memory_001'));
      await _tick();

      final stateAfter = bloc.state as ProgressionLoaded;
      expect(stateAfter.unlockedMemoryIds.length, memoryCountBefore);
      expect(stateAfter.unlockedMemoryIds, contains('memory_001'));
    });
  });

  // ── 11. ResetAllProgression ─────────────────────────────────────

  group('ResetAllProgression', () {
    test('resets all meta data to defaults', () async {
      bloc.initialize(const MetaSaveData(
        soulCount: 500,
        totalRuns: 20,
        deathCount: 15,
        clearCount: 5,
        endingsReached: {'slay', 'liberate'},
        upgradeLevels: {'soul_max_hp_1': 3},
        purchasedUpgradeIds: {'soul_max_hp_1'},
        unlockedCardIds: {'whirlwind'},
        unlockedMemoryIds: {'first_run', 'reach_floor_2'},
        unlockedHiddenJobIds: {'reaper'},
        winsByJob: {'warrior': 3},
      ));
      await _tick();

      // 초기화 전 확인
      final before = bloc.state as ProgressionLoaded;
      expect(before.soulCount, 500);

      bloc.add(const ResetAllProgression());
      await _tick();

      final after = bloc.state as ProgressionLoaded;
      expect(after.soulCount, 0);
      expect(after.totalRuns, 0);
      expect(after.deathCount, 0);
      expect(after.clearCount, 0);
      expect(after.endingsReached, isEmpty);
      expect(after.upgradeLevels, isEmpty);
      expect(after.purchasedUpgradeIds, isEmpty);
      expect(after.unlockedCardIds, isEmpty);
      expect(after.unlockedMemoryIds, isEmpty);
      expect(after.unlockedHiddenJobIds, isEmpty);
      expect(after.winsByJob, isEmpty);
    });

    test('ignored when state is not ProgressionLoaded', () async {
      // ProgressionInitial 상태에서는 무시
      expect(bloc.state, isA<ProgressionInitial>());

      bloc.add(const ResetAllProgression());
      await _tick();

      expect(bloc.state, isA<ProgressionInitial>());
    });
  });
}
