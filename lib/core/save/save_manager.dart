import 'package:soul_dungeon/core/error/game_error.dart';
import 'package:soul_dungeon/core/error/result.dart';
import 'package:soul_dungeon/core/logging/game_logger.dart';
import 'package:soul_dungeon/core/save/save_data.dart';
import 'package:soul_dungeon/core/save/save_serializer.dart';
import 'package:soul_dungeon/core/save/save_storage.dart';
import 'package:soul_dungeon/core/save/save_validator.dart';
import 'package:soul_dungeon/core/models/card_data.dart';

/// 더블 버퍼 세이브 매니저.
///
/// 저장: 비활성 슬롯 쓰기 → SHA-256 체크섬 → active_slot 스왑 (커밋 포인트).
/// 로드: active_slot → 검증 → 실패 시 비활성 폴백 → 양쪽 실패 → 새 게임.
class SaveManager {
  final SaveStorage _storage;
  final String? _deviceKey;
  final CardData? Function(String id)? _cardResolver;

  static const _runKeyA = 'save_run_a';
  static const _runKeyB = 'save_run_b';
  static const _metaKeyA = 'save_meta_a';
  static const _metaKeyB = 'save_meta_b';
  static const _activeSlotKey = 'save_active_slot';
  static const _emergencyKey = 'save_emergency';

  SaveManager(
    this._storage, {
    String? deviceKey,
    CardData? Function(String id)? cardResolver,
  })  : _deviceKey = deviceKey,
        _cardResolver = cardResolver;

  // ── Active Slot ──

  Future<String> _getActiveSlot() async {
    final slot = await _storage.read(_activeSlotKey) ?? 'a';
    return (slot == 'a' || slot == 'b') ? slot : 'a';
  }

  String _inactiveSlot(String active) => active == 'a' ? 'b' : 'a';

  // ── Run Save/Load ──

  /// 런 데이터 저장 — 비활성 슬롯 쓰기 → 체크섬 → 슬롯 스왑.
  Future<Result<void>> saveRun(RunSaveData data) async {
    try {
      final activeSlot = await _getActiveSlot();
      final inactive = _inactiveSlot(activeSlot);
      final key = inactive == 'a' ? _runKeyA : _runKeyB;

      final json = SaveSerializer.serializeRun(data, deviceKey: _deviceKey);
      final hash = SaveValidator.checksum(json);

      await _storage.write(key, json);
      await _storage.write('${key}_checksum', hash);
      await _storage.write(_activeSlotKey, inactive);

      GameLogger.info(LogSystem.save, 'Run saved to slot $inactive');
      return const Success(null);
    } catch (e) {
      GameLogger.error(LogSystem.save, 'Save run failed', e);
      return Failure(GameError(
        message: 'Save run failed: $e',
        severity: ErrorSeverity.recoverable,
        system: 'save',
        cause: e,
      ));
    }
  }

  /// 런 데이터 로드 — active → fallback → 양쪽 실패 시 Failure.
  Future<Result<RunSaveData>> loadRun() async {
    final activeSlot = await _getActiveSlot();

    final activeResult = await _loadRunFromSlot(activeSlot);
    if (activeResult is Success<RunSaveData>) return activeResult;

    GameLogger.warning(
      LogSystem.save,
      'Active slot $activeSlot failed, trying fallback',
    );
    final fallback = _inactiveSlot(activeSlot);
    final fallbackResult = await _loadRunFromSlot(fallback);
    if (fallbackResult is Success<RunSaveData>) return fallbackResult;

    GameLogger.error(LogSystem.save, 'Both run save slots corrupted');
    return Failure(const GameError(
      message: 'Both run save slots corrupted',
      severity: ErrorSeverity.recoverable,
      system: 'save',
    ));
  }

  Future<Result<RunSaveData>> _loadRunFromSlot(String slot) async {
    final key = slot == 'a' ? _runKeyA : _runKeyB;
    final json = await _storage.read(key);
    if (json == null) {
      return Failure(GameError(
        message: 'No run save in slot $slot',
        severity: ErrorSeverity.recoverable,
        system: 'save',
      ));
    }

    final hash = await _storage.read('${key}_checksum');
    if (hash == null || !SaveValidator.validate(json, hash)) {
      return Failure(GameError(
        message: 'Checksum mismatch in run slot $slot',
        severity: ErrorSeverity.recoverable,
        system: 'save',
      ));
    }

    return SaveSerializer.deserializeRun(json, deviceKey: _deviceKey, cardResolver: _cardResolver);
  }

  /// 런 세이브 존재 여부 — 양쪽 슬롯 모두 확인 (loadRun 폴백과 일관).
  Future<bool> hasRunSave() async {
    final activeSlot = await _getActiveSlot();
    final activeKey = activeSlot == 'a' ? _runKeyA : _runKeyB;
    final inactiveKey = activeSlot == 'a' ? _runKeyB : _runKeyA;
    return await _storage.read(activeKey) != null ||
        await _storage.read(inactiveKey) != null;
  }

  /// 런 세이브 삭제 (퍼마데스).
  Future<void> deleteRun() async {
    await _storage.delete(_runKeyA);
    await _storage.delete(_runKeyB);
    await _storage.delete('${_runKeyA}_checksum');
    await _storage.delete('${_runKeyB}_checksum');
    GameLogger.info(LogSystem.save, 'Run save deleted (permadeath)');
  }

  // ── Meta Save/Load ──

  /// 메타 데이터 저장 — 양쪽 슬롯에 동시 저장 (독립 관리).
  Future<Result<void>> saveMeta(MetaSaveData data) async {
    try {
      final json = SaveSerializer.serializeMeta(data, deviceKey: _deviceKey);
      final hash = SaveValidator.checksum(json);

      // 양쪽 슬롯에 동시 저장 — 한쪽 손상 시 다른 쪽 폴백
      await _storage.write(_metaKeyA, json);
      await _storage.write('${_metaKeyA}_checksum', hash);
      await _storage.write(_metaKeyB, json);
      await _storage.write('${_metaKeyB}_checksum', hash);

      GameLogger.info(LogSystem.save, 'Meta saved to both slots');
      return const Success(null);
    } catch (e) {
      GameLogger.error(LogSystem.save, 'Save meta failed', e);
      return Failure(GameError(
        message: 'Save meta failed: $e',
        severity: ErrorSeverity.recoverable,
        system: 'save',
        cause: e,
      ));
    }
  }

  /// 메타 데이터 로드 — 양쪽 슬롯 시도.
  Future<Result<MetaSaveData>> loadMeta() async {
    // 메타는 양쪽 슬롯 모두 시도 (a → b)
    final resultA = await _loadMetaFromSlot('a');
    if (resultA is Success<MetaSaveData>) return resultA;

    final resultB = await _loadMetaFromSlot('b');
    if (resultB is Success<MetaSaveData>) return resultB;

    // 양쪽 없음 → 초기 메타 반환
    return const Success(MetaSaveData());
  }

  Future<Result<MetaSaveData>> _loadMetaFromSlot(String slot) async {
    final key = slot == 'a' ? _metaKeyA : _metaKeyB;
    final json = await _storage.read(key);
    if (json == null) {
      return Failure(GameError(
        message: 'No meta save in slot $slot',
        severity: ErrorSeverity.recoverable,
        system: 'save',
      ));
    }

    final hash = await _storage.read('${key}_checksum');
    if (hash == null || !SaveValidator.validate(json, hash)) {
      return Failure(GameError(
        message: 'Checksum mismatch in meta slot $slot',
        severity: ErrorSeverity.recoverable,
        system: 'save',
      ));
    }

    return SaveSerializer.deserializeMeta(json, deviceKey: _deviceKey);
  }

  // ── Emergency ──

  /// 긴급 세이브 — 3번째 슬롯 (critical 에러 시).
  Future<void> emergencySave(RunSaveData data) async {
    try {
      final json = SaveSerializer.serializeRun(data, deviceKey: _deviceKey);
      final hash = SaveValidator.checksum(json);
      await _storage.write(_emergencyKey, json);
      await _storage.write('${_emergencyKey}_checksum', hash);
      GameLogger.warning(LogSystem.save, 'Emergency save created');
    } catch (e) {
      GameLogger.error(LogSystem.save, 'Emergency save failed', e);
    }
  }

  /// 긴급 세이브 로드 시도.
  Future<Result<RunSaveData>> loadEmergency() async {
    final json = await _storage.read(_emergencyKey);
    if (json == null) {
      return const Failure(GameError(
        message: 'No emergency save',
        severity: ErrorSeverity.recoverable,
        system: 'save',
      ));
    }

    final hash = await _storage.read('${_emergencyKey}_checksum');
    if (hash == null || !SaveValidator.validate(json, hash)) {
      GameLogger.warning(LogSystem.save, 'Emergency save checksum invalid');
      return const Failure(GameError(
        message: 'Emergency save checksum mismatch',
        severity: ErrorSeverity.recoverable,
        system: 'save',
      ));
    }

    return SaveSerializer.deserializeRun(json, deviceKey: _deviceKey, cardResolver: _cardResolver);
  }

  /// 긴급 세이브 삭제.
  Future<void> deleteEmergency() async {
    await _storage.delete(_emergencyKey);
    await _storage.delete('${_emergencyKey}_checksum');
  }

  /// 모든 세이브 데이터 삭제 (완전 초기화).
  Future<void> deleteAllData() async {
    await deleteRun();
    await _storage.delete(_metaKeyA);
    await _storage.delete(_metaKeyB);
    await _storage.delete('${_metaKeyA}_checksum');
    await _storage.delete('${_metaKeyB}_checksum');
    await deleteEmergency();
    await _storage.delete(_activeSlotKey);
    GameLogger.info(LogSystem.save, 'All save data deleted (full reset)');
  }
}
