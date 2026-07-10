import 'dart:convert';

import 'package:soul_dungeon/core/error/game_error.dart';
import 'package:soul_dungeon/core/error/result.dart';
import 'package:soul_dungeon/core/logging/game_logger.dart';
import 'package:soul_dungeon/core/save/save_data.dart';
import 'package:soul_dungeon/core/save/save_encryptor.dart';
import 'package:soul_dungeon/core/models/boss_choice.dart';
import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/core/models/disposition_axis.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/core/models/player_run_state.dart';

/// 세이브 데이터 JSON 직렬화/역직렬화.
class SaveSerializer {
  SaveSerializer._();

  // ── Run ──

  /// RunSaveData → JSON 문자열 (deviceKey 있으면 암호화).
  static String serializeRun(RunSaveData data, {String? deviceKey}) {
    final json = {
      'schemaVersion': data.schemaVersion,
      'savedAt': data.savedAt.toIso8601String(),
      'playerRunState': _playerRunStateToJson(data.playerRunState),
      if (data.cardCombatStateRaw != null)
        'cardCombatStateRaw': data.cardCombatStateRaw,
    };
    final jsonString = jsonEncode(json);
    if (deviceKey != null) {
      return SaveEncryptor.encrypt(jsonString, deviceKey);
    }
    return jsonString;
  }

  /// JSON 문자열 → RunSaveData (암호화 자동 감지).
  ///
  /// [cardResolver]를 전달하면 저장된 카드 ID를 CardData로 복원한다.
  static Result<RunSaveData> deserializeRun(
    String jsonString, {
    String? deviceKey,
    CardData? Function(String id)? cardResolver,
  }) {
    try {
      String plaintext = jsonString;
      if (SaveEncryptor.isEncrypted(jsonString)) {
        if (deviceKey == null) {
          return Failure(const GameError(
            message: 'Encrypted data but no device key',
            severity: ErrorSeverity.recoverable,
            system: 'save',
          ));
        }
        final decryptResult = SaveEncryptor.decrypt(jsonString, deviceKey);
        if (decryptResult case Failure(:final error)) {
          return Failure(error);
        }
        plaintext = (decryptResult as Success<String>).data;
      }
      final json = jsonDecode(plaintext) as Map<String, dynamic>;
      final stateJson = json['playerRunState'] as Map<String, dynamic>;
      final state = _playerRunStateFromJson(stateJson, cardResolver: cardResolver);
      return Success(RunSaveData(
        playerRunState: state,
        schemaVersion: json['schemaVersion'] as int? ?? 1,
        savedAt: DateTime.parse(json['savedAt'] as String),
        cardCombatStateRaw: json['cardCombatStateRaw'] != null
            ? Map<String, dynamic>.from(
                json['cardCombatStateRaw'] as Map)
            : null,
      ));
    } catch (e) {
      return Failure(GameError(
        message: 'Failed to deserialize run save: $e',
        severity: ErrorSeverity.recoverable,
        system: 'save',
        cause: e,
      ));
    }
  }

  // ── Meta ──

  /// MetaSaveData → JSON 문자열 (deviceKey 있으면 암호화).
  static String serializeMeta(MetaSaveData data, {String? deviceKey}) {
    final json = {
      'schemaVersion': data.schemaVersion,
      'totalRuns': data.totalRuns,
      'deathCount': data.deathCount,
      'endingsReached': data.endingsReached.toList(),
      'soulCount': data.soulCount,
      'purchasedUpgradeIds': data.purchasedUpgradeIds.toList(),
      'upgradeLevels': data.upgradeLevels,
      'unlockedCardIds': data.unlockedCardIds.toList(),
      'ghostNpcPoolRaw': data.ghostNpcPoolRaw,
      'unlockedMemoryIds': data.unlockedMemoryIds.toList(),
      'clearCount': data.clearCount,
      'unlockedHiddenJobIds': data.unlockedHiddenJobIds.toList(),
      'winsByJob': data.winsByJob,
    };
    final jsonString = jsonEncode(json);
    if (deviceKey != null) {
      return SaveEncryptor.encrypt(jsonString, deviceKey);
    }
    return jsonString;
  }

  /// JSON 문자열 → MetaSaveData (암호화 자동 감지).
  static Result<MetaSaveData> deserializeMeta(
    String jsonString, {
    String? deviceKey,
  }) {
    try {
      String plaintext = jsonString;
      if (SaveEncryptor.isEncrypted(jsonString)) {
        if (deviceKey == null) {
          return Failure(const GameError(
            message: 'Encrypted data but no device key',
            severity: ErrorSeverity.recoverable,
            system: 'save',
          ));
        }
        final decryptResult = SaveEncryptor.decrypt(jsonString, deviceKey);
        if (decryptResult case Failure(:final error)) {
          return Failure(error);
        }
        plaintext = (decryptResult as Success<String>).data;
      }
      final json = jsonDecode(plaintext) as Map<String, dynamic>;
      return Success(MetaSaveData(
        schemaVersion: json['schemaVersion'] as int? ?? 1,
        totalRuns: json['totalRuns'] as int? ?? 0,
        deathCount: json['deathCount'] as int? ?? 0,
        endingsReached: (json['endingsReached'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toSet() ??
            {},
        soulCount: json['soulCount'] as int? ?? 0,
        purchasedUpgradeIds: _parseStringSet(json['purchasedUpgradeIds']),
        upgradeLevels: _parseIntMap(json['upgradeLevels']),
        unlockedCardIds: _parseStringSet(json['unlockedCardIds']),
        ghostNpcPoolRaw: _parseMapList(json['ghostNpcPoolRaw']),
        unlockedMemoryIds: _parseStringSet(json['unlockedMemoryIds']),
        clearCount: json['clearCount'] as int? ?? 0,
        unlockedHiddenJobIds: _parseStringSet(json['unlockedHiddenJobIds']),
        winsByJob: _parseIntMap(json['winsByJob']),
      ));
    } catch (e) {
      return Failure(GameError(
        message: 'Failed to deserialize meta save: $e',
        severity: ErrorSeverity.recoverable,
        system: 'save',
        cause: e,
      ));
    }
  }

  // ── PlayerRunState helpers ──

  static Map<String, dynamic> _playerRunStateToJson(PlayerRunState state) {
    return {
      'currentHp': state.currentHp,
      'maxHp': state.maxHp,
      'gold': state.gold,
      'disposition': state.disposition.map(
        (k, v) => MapEntry(k.name, v),
      ),
      'currentJobId': state.currentJobId,
      'ownedBlessingIds': state.ownedBlessingIds,
      'ownedRelicIds': state.ownedRelicIds,
      'activeCurseIds': state.activeCurseIds,
      'currentFloor': state.currentFloor,
      'bossChoices': state.bossChoices
          .map((c) => {
                'floor': c.floor,
                'bossId': c.bossId,
                'choiceType': c.choiceType.name,
              })
          .toList(),
      'completedFloors': state.completedFloors.toList(),
      'masterDeckIds': state.masterDeck.map((c) => c.id).toList(),
      'removedCardIds': state.removedCardIds.toList(),
      'tempStrengthBonus': state.tempStrengthBonus,
      'tempBlockBonus': state.tempBlockBonus,
      'tempMomentumBonus': state.tempMomentumBonus,
      'dungeonSeed': state.dungeonSeed,
      'dungeonNodeId': state.dungeonNodeId,
      'dungeonVisitedNodeIds': state.dungeonVisitedNodeIds.toList(),
      'currentRoomType': state.currentRoomType?.name,
      'momentumValue': state.momentumValue,
      'momentumConsecutiveCount': state.momentumConsecutiveCount,
      'bossVictoryPending': state.bossVictoryPending,
    };
  }

  static PlayerRunState _playerRunStateFromJson(
    Map<String, dynamic> json, {
    CardData? Function(String id)? cardResolver,
  }) {
    final maxHp = (json['maxHp'] as int?) ?? 100;
    final currentHp = (json['currentHp'] as int?) ?? maxHp;

    // masterDeck 복원: cardResolver가 있으면 ID → CardData 변환
    final masterDeckIds = _parseStringList(json['masterDeckIds']);
    final masterDeck = cardResolver != null
        ? () {
            final resolved = masterDeckIds
                .map((id) => cardResolver(id))
                .whereType<CardData>()
                .toList();
            if (resolved.length != masterDeckIds.length) {
              final missing = masterDeckIds
                  .where((id) => cardResolver(id) == null)
                  .toList();
              GameLogger.warning(
                LogSystem.save,
                'masterDeck load: ${missing.length}개 카드 ID 미해결 → 제거됨: $missing',
              );
            }
            return resolved;
          }()
        : <CardData>[];

    return PlayerRunState(
      currentHp: currentHp.clamp(0, maxHp),
      maxHp: maxHp,
      gold: (json['gold'] as int?) ?? 0,
      disposition: _parseDisposition(json['disposition']),
      currentJobId: json['currentJobId'] as String?,
      ownedBlessingIds: _parseStringList(json['ownedBlessingIds']),
      ownedRelicIds: _parseStringList(json['ownedRelicIds']),
      activeCurseIds: _parseStringList(json['activeCurseIds']),
      currentFloor: (json['currentFloor'] as int?) ?? 1,
      bossChoices: _parseBossChoices(json['bossChoices']),
      completedFloors: _parseIntSet(json['completedFloors']),
      masterDeck: masterDeck,
      removedCardIds: _parseStringSet(json['removedCardIds']),
      tempStrengthBonus: (json['tempStrengthBonus'] as int?) ?? 0,
      tempBlockBonus: (json['tempBlockBonus'] as int?) ?? 0,
      tempMomentumBonus: (json['tempMomentumBonus'] as int?) ?? 0,
      dungeonSeed: json['dungeonSeed'] as int?,
      dungeonNodeId: json['dungeonNodeId'] as String?,
      dungeonVisitedNodeIds: _parseStringSet(json['dungeonVisitedNodeIds']),
      currentRoomType: _parseRoomType(json['currentRoomType']),
      momentumValue: json['momentumValue'] as int?,
      momentumConsecutiveCount: (json['momentumConsecutiveCount'] as int?) ?? 0,
      bossVictoryPending: json['bossVictoryPending'] as bool? ?? false,
    );
  }

  static Map<DispositionAxis, int> _parseDisposition(dynamic raw) {
    if (raw == null || raw is! Map) {
      return {for (final axis in DispositionAxis.values) axis: 0};
    }
    final map = raw as Map<String, dynamic>;
    return {
      for (final axis in DispositionAxis.values)
        axis: (map[axis.name] as int?) ?? 0,
    };
  }

  static List<String> _parseStringList(dynamic raw) {
    if (raw == null || raw is! List) return [];
    return raw.map((e) => e as String).toList();
  }

  static List<BossChoice> _parseBossChoices(dynamic raw) {
    if (raw == null || raw is! List) return [];
    return raw.map((e) {
      final m = e as Map<String, dynamic>;
      return BossChoice(
        floor: (m['floor'] as num?)?.toInt() ?? 0,
        bossId: m['bossId'] as String? ?? '',
        choiceType: BossChoiceType.values.firstWhere(
          (t) => t.name == m['choiceType'],
          orElse: () => BossChoiceType.slay,
        ),
      );
    }).toList();
  }

  static Set<int> _parseIntSet(dynamic raw) {
    if (raw == null || raw is! List) return {};
    return raw.map((e) => (e as num).toInt()).toSet();
  }

  static Set<String> _parseStringSet(dynamic raw) {
    if (raw == null || raw is! List) return {};
    return raw.map((e) => e as String).toSet();
  }

  static Map<String, int> _parseIntMap(dynamic raw) {
    if (raw == null || raw is! Map) return {};
    return Map<String, dynamic>.from(raw)
        .map((k, v) => MapEntry(k, (v as num).toInt()));
  }

  static RoomType? _parseRoomType(dynamic raw) {
    if (raw == null || raw is! String) return null;
    return RoomType.values.where((r) => r.name == raw).firstOrNull;
  }

  static List<Map<String, dynamic>> _parseMapList(dynamic raw) {
    if (raw == null || raw is! List) return const [];
    return raw
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }
}
