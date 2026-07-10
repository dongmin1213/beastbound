import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/narrative/models/text_block_schema.dart';

/// 모든 콘텐츠 JSON 파일 경로.
const _allContentFiles = [
  'assets/content/floor_1.json',
  'assets/content/floor_2.json',
  'assets/content/floor_3.json',
  'assets/content/floor_4.json',
  'assets/content/floor_5.json',
  'assets/content/boss_text.json',
  'assets/content/meta_text.json',
  'assets/content/combat_text.json',
];

/// 실제 assets/content/ JSON 파일이 TextBlockSchema 스키마를 준수하는지 검증.
void main() {
  group('JSON 스키마 검증', () {
    for (final path in _allContentFiles) {
      final fileName = path.split('/').last;

      test('$fileName 파싱 성공', () {
        _validateContentFile(path);
      });

      test('$fileName textId 고유성', () {
        _validateUniqueIds(path);
      });
    }

    test('전체 파일 간 textId 고유성', () {
      final allIds = <String>{};
      for (final path in _allContentFiles) {
        final entries = _loadEntries(path);
        for (final entry in entries) {
          expect(
            allIds.add(entry.textId),
            isTrue,
            reason: 'Duplicate textId: ${entry.textId} in $path',
          );
        }
      }
    });

    test('전체 콘텐츠 80+ 엔트리', () {
      var totalCount = 0;
      for (final path in _allContentFiles) {
        totalCount += _loadEntries(path).length;
      }
      expect(
        totalCount,
        greaterThanOrEqualTo(80),
        reason: '전체 콘텐츠 엔트리 수가 80 이상이어야 함 (현재: $totalCount)',
      );
    });

    test('floor_1.json 모든 엔트리 floor==1', () {
      final entries = _loadEntries('assets/content/floor_1.json');
      for (final e in entries) {
        expect(e.floor, 1, reason: '${e.textId} floor should be 1');
      }
    });

    test('floor_2.json 모든 엔트리 floor==2', () {
      final entries = _loadEntries('assets/content/floor_2.json');
      for (final e in entries) {
        expect(e.floor, 2, reason: '${e.textId} floor should be 2');
      }
    });

    test('floor_3.json 모든 엔트리 floor==3', () {
      final entries = _loadEntries('assets/content/floor_3.json');
      for (final e in entries) {
        expect(e.floor, 3, reason: '${e.textId} floor should be 3');
      }
    });

    test('floor_4.json 모든 엔트리 floor==4', () {
      final entries = _loadEntries('assets/content/floor_4.json');
      for (final e in entries) {
        expect(e.floor, 4, reason: '${e.textId} floor should be 4');
      }
    });

    test('floor_5.json 모든 엔트리 floor==5', () {
      final entries = _loadEntries('assets/content/floor_5.json');
      for (final e in entries) {
        expect(e.floor, 5, reason: '${e.textId} floor should be 5');
      }
    });

    test('boss_text.json 모든 엔트리 roomType==boss', () {
      final entries = _loadEntries('assets/content/boss_text.json');
      for (final e in entries) {
        expect(e.roomType.name, 'boss', reason: '${e.textId} should be boss room');
      }
    });

    test('모든 엔트리 weight > 0', () {
      for (final path in _allContentFiles) {
        final entries = _loadEntries(path);
        for (final e in entries) {
          expect(
            e.weight,
            greaterThan(0),
            reason: '${e.textId} in $path weight should be > 0',
          );
        }
      }
    });

    test('TextBlockSchema fromJson/toJson 라운드트립', () {
      for (final path in _allContentFiles) {
        final entries = _loadEntries(path);
        for (final original in entries) {
          final json = original.toJson();
          final restored = TextBlockSchema.fromJson(json);
          expect(restored.textId, original.textId);
          expect(restored.text, original.text);
          expect(restored.floor, original.floor);
          expect(restored.roomType, original.roomType);
          expect(restored.reliable, original.reliable);
          expect(restored.layer, original.layer);
          expect(restored.priority, original.priority);
          expect(restored.weight, original.weight);
          expect(restored.tags, original.tags);
        }
      }
    });

    test('4/5층 reliable:false 엔트리 존재', () {
      final f4 = _loadEntries('assets/content/floor_4.json');
      final f4Unreliable = f4.where((e) => !e.reliable).toList();
      expect(f4Unreliable, isNotEmpty,
          reason: '4층에는 서술자 왜곡(reliable:false) 엔트리가 있어야 함');

      final f5 = _loadEntries('assets/content/floor_5.json');
      final f5Unreliable = f5.where((e) => !e.reliable).toList();
      expect(f5Unreliable, isNotEmpty,
          reason: '5층에는 서술자 왜곡(reliable:false) 엔트리가 있어야 함');
    });

    test('combat_text.json 전층 공통(floor:0) 엔트리 존재', () {
      final entries = _loadEntries('assets/content/combat_text.json');
      final globalEntries = entries.where((e) => e.floor == 0).toList();
      expect(globalEntries, isNotEmpty,
          reason: 'combat_text.json에 floor:0 전층 공통 엔트리가 있어야 함');
    });

    test('combat_text.json 전투 태그 카테고리 분포', () {
      final entries = _loadEntries('assets/content/combat_text.json');
      final tags = entries.expand((e) => e.tags).toSet();
      expect(tags, contains('attack'),
          reason: 'combat_text에 attack 태그 필요');
      expect(tags, contains('skill'),
          reason: 'combat_text에 skill 태그 필요');
      expect(tags, contains('power'),
          reason: 'combat_text에 power 태그 필요');
      expect(tags, contains('victory'),
          reason: 'combat_text에 victory 태그 필요');
      expect(tags, contains('defeat'),
          reason: 'combat_text에 defeat 태그 필요');
    });

    test('템플릿 플레이스홀더 포함 엔트리 존재', () {
      var templateCount = 0;
      for (final path in _allContentFiles) {
        final entries = _loadEntries(path);
        for (final e in entries) {
          if (e.text.contains('{')) {
            templateCount++;
          }
        }
      }
      expect(templateCount, greaterThan(0),
          reason: '플레이스홀더({cardName} 등) 포함 엔트리가 있어야 함');
    });

    test('층별 쿼리 — 각 층에 최소 1개 엔트리', () {
      final allEntries = <TextBlockSchema>[];
      for (final path in _allContentFiles) {
        allEntries.addAll(_loadEntries(path));
      }

      for (var floor = 1; floor <= 5; floor++) {
        final floorEntries = allEntries.where((e) => e.floor == floor).toList();
        expect(floorEntries, isNotEmpty,
            reason: '$floor층 엔트리가 최소 1개 있어야 함');
      }
    });

    test('boss_text.json 보스 10개 엔트리', () {
      final entries = _loadEntries('assets/content/boss_text.json');
      expect(entries.length, 10);
    });

    test('meta_text.json 12개 엔트리', () {
      final entries = _loadEntries('assets/content/meta_text.json');
      expect(entries.length, 12);
    });

    test('combat_text.json 18개 엔트리', () {
      final entries = _loadEntries('assets/content/combat_text.json');
      expect(entries.length, 18);
    });
  });
}

List<TextBlockSchema> _loadEntries(String path) {
  final file = File(path);
  final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  final rawEntries = json['entries'] as List<dynamic>;
  return rawEntries
      .map((e) => TextBlockSchema.fromJson(e as Map<String, dynamic>))
      .toList();
}

void _validateContentFile(String path) {
  final entries = _loadEntries(path);
  expect(entries, isNotEmpty, reason: '$path should have entries');
  for (final entry in entries) {
    expect(entry.textId, isNotEmpty, reason: 'textId should not be empty');
    expect(entry.text, isNotEmpty, reason: 'text should not be empty');
  }
}

void _validateUniqueIds(String path) {
  final entries = _loadEntries(path);
  final ids = entries.map((e) => e.textId).toSet();
  expect(ids.length, entries.length, reason: '$path has duplicate textIds');
}
