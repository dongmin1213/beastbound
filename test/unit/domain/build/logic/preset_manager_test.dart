import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soul_dungeon/domain/build/logic/preset_manager.dart';
import 'package:soul_dungeon/domain/build/models/run_preset.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PresetManager manager;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    manager = PresetManager();
  });

  group('PresetManager', () {
    test('초기 상태 — 프리셋 없음', () {
      expect(manager.presets, isEmpty);
    });

    test('프리셋 저장', () async {
      final preset = RunPreset(
        id: 'p1',
        name: '테스트',
        prepChoiceId: 'prep_gold',
        createdAt: DateTime(2025, 1, 1),
      );
      await manager.savePreset(preset);
      expect(manager.presets.length, 1);
      expect(manager.presets[0].id, 'p1');
    });

    test('중복 ID → 기존 것 교체', () async {
      final preset1 = RunPreset(
        id: 'p1',
        name: '첫번째',
        prepChoiceId: 'prep_gold',
        createdAt: DateTime(2025, 1, 1),
      );
      final preset2 = RunPreset(
        id: 'p1',
        name: '두번째',
        prepChoiceId: 'prep_hp',
        createdAt: DateTime(2025, 1, 2),
      );
      await manager.savePreset(preset1);
      await manager.savePreset(preset2);
      expect(manager.presets.length, 1);
      expect(manager.presets[0].name, '두번째');
    });

    test('최대 3개 유지 — 4번째 저장 시 첫 번째 제거', () async {
      for (int i = 0; i < 4; i++) {
        await manager.savePreset(RunPreset(
          id: 'p$i',
          name: 'Preset $i',
          prepChoiceId: 'prep_gold',
          createdAt: DateTime(2025, 1, i + 1),
        ));
      }
      expect(manager.presets.length, 3);
      expect(manager.presets[0].id, 'p1'); // p0 제거됨
      expect(manager.presets[2].id, 'p3');
    });

    test('프리셋 삭제', () async {
      await manager.savePreset(RunPreset(
        id: 'p1',
        name: '테스트',
        prepChoiceId: 'prep_gold',
        createdAt: DateTime(2025, 1, 1),
      ));
      expect(await manager.removePreset('p1'), isTrue);
      expect(manager.presets, isEmpty);
    });

    test('존재하지 않는 ID 삭제 → false', () async {
      expect(await manager.removePreset('nonexistent'), isFalse);
    });

    test('findById — 존재하면 반환', () async {
      await manager.savePreset(RunPreset(
        id: 'p1',
        name: '테스트',
        prepChoiceId: 'prep_hp',
        createdAt: DateTime(2025, 1, 1),
      ));
      final found = manager.findById('p1');
      expect(found, isNotNull);
      expect(found!.prepChoiceId, 'prep_hp');
    });

    test('findById — 존재하지 않으면 null', () {
      expect(manager.findById('nonexistent'), isNull);
    });

    test('clear — 전체 초기화', () async {
      for (int i = 0; i < 3; i++) {
        await manager.savePreset(RunPreset(
          id: 'p$i',
          name: 'Preset $i',
          prepChoiceId: 'prep_gold',
          createdAt: DateTime(2025, 1, i + 1),
        ));
      }
      await manager.clear();
      expect(manager.presets, isEmpty);
    });

    test('createFromLastRun — 자동 프리셋 생성', () {
      final preset = manager.createFromLastRun('prep_blessing');
      expect(preset.prepChoiceId, 'prep_blessing');
      expect(preset.id, startsWith('preset_'));
      expect(preset.name, contains('최근 빌드'));
    });
  });

  group('RunPreset', () {
    test('JSON 직렬화/역직렬화', () {
      final preset = RunPreset(
        id: 'p1',
        name: '테스트',
        prepChoiceId: 'prep_gold',
        createdAt: DateTime(2025, 6, 15, 12, 30),
      );
      final json = preset.toJson();
      final restored = RunPreset.fromJson(json);
      expect(restored.id, 'p1');
      expect(restored.name, '테스트');
      expect(restored.prepChoiceId, 'prep_gold');
      expect(restored.createdAt, DateTime(2025, 6, 15, 12, 30));
    });

    test('equality by ID', () {
      final a = RunPreset(
        id: 'p1',
        name: 'A',
        prepChoiceId: 'prep_gold',
        createdAt: DateTime(2025, 1, 1),
      );
      final b = RunPreset(
        id: 'p1',
        name: 'B',
        prepChoiceId: 'prep_hp',
        createdAt: DateTime(2025, 1, 2),
      );
      expect(a, equals(b)); // same ID
    });
  });
}
