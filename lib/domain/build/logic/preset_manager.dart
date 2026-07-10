import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:soul_dungeon/domain/build/models/run_preset.dart';

/// 프리셋 관리자 — 런 프리셋의 CRUD 로직.
///
/// SharedPreferences 기반 영속 저장. 최대 3개 프리셋 유지.
class PresetManager {
  static const maxPresets = 3;
  static const _storageKey = 'run_presets';

  final List<RunPreset> _presets = [];

  List<RunPreset> get presets => List.unmodifiable(_presets);

  /// SharedPreferences에서 프리셋 로드.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return;

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      _presets.clear();
      for (final item in list) {
        _presets.add(RunPreset.fromJson(item as Map<String, dynamic>));
      }
    } on Object {
      // 파싱 실패 시 기본값 유지
    }
  }

  /// 프리셋 저장. 최대치 초과 시 가장 오래된 것 제거.
  Future<void> savePreset(RunPreset preset) async {
    // 중복 ID 제거
    _presets.removeWhere((p) => p.id == preset.id);
    _presets.add(preset);

    // 최대치 초과 시 가장 오래된 것 제거
    while (_presets.length > maxPresets) {
      _presets.removeAt(0);
    }

    await _persist();
  }

  /// 프리셋 삭제.
  Future<bool> removePreset(String id) async {
    final before = _presets.length;
    _presets.removeWhere((p) => p.id == id);
    if (_presets.length < before) {
      await _persist();
      return true;
    }
    return false;
  }

  /// ID로 프리셋 조회.
  RunPreset? findById(String id) {
    for (final p in _presets) {
      if (p.id == id) return p;
    }
    return null;
  }

  /// 프리셋 전체 초기화.
  Future<void> clear() async {
    _presets.clear();
    await _persist();
  }

  /// 마지막 런의 선택으로 자동 프리셋 생성.
  RunPreset createFromLastRun(String prepChoiceId) {
    final now = DateTime.now();
    return RunPreset(
      id: 'preset_${now.millisecondsSinceEpoch}',
      name: '최근 빌드 #${_presets.length + 1}',
      prepChoiceId: prepChoiceId,
      createdAt: now,
    );
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(_presets.map((p) => p.toJson()).toList());
    await prefs.setString(_storageKey, json);
  }
}
