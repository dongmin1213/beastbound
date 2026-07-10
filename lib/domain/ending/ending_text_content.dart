import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:soul_dungeon/core/logging/game_logger.dart';
import 'package:soul_dungeon/domain/ending/ending_types.dart';

/// 엔딩 텍스트 중앙 관리.
///
/// JSON 에셋(assets/content/endings.json)에서 로드. 실패 시 기본값 폴백.
/// meta_text.json의 ending_* 엔트리와 동기화 유지.
class EndingTextContent {
  EndingTextContent._();

  static Map<EndingType, String> _texts = _defaults;

  /// JSON 에셋에서 로드. 실패 시 기본값 폴백.
  static Future<void> load({
    AssetBundle? bundle,
    String path = 'assets/content/endings.json',
  }) async {
    try {
      final assetBundle = bundle ?? rootBundle;
      final jsonString = await assetBundle.loadString(path);
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final endings = json['endings'] as List;
      final loaded = <EndingType, String>{};
      for (final entry in endings) {
        final map = entry as Map<String, dynamic>;
        final type = EndingType.values.byName(map['type'] as String);
        loaded[type] = map['text'] as String;
      }
      _texts = loaded;
      GameLogger.info(LogSystem.core, 'EndingTextContent loaded: ${_texts.length} endings');
    } catch (e) {
      GameLogger.error(LogSystem.core, 'Failed to load endings.json, using defaults', e);
      _texts = _defaults;
    }
  }

  // ── 기본값 (JSON 로드 실패 시 폴백) ──

  static const _defaults = <EndingType, String>{
    EndingType.slay:
        '투쟁의 길을 걸었다. 모든 수호자를 쓰러뜨렸지만, '
            '그 대가로 이 던전에 새로운 어둠이 깃든다.',
    EndingType.liberate:
        '자비의 길을 걸었다. 수호자들을 구속에서 풀어주었고, '
            '그들의 감사가 던전에 따뜻한 바람을 불러온다.',
    EndingType.coexist:
        '조화의 길을 걸었다. 수호자들과 나란히 서며, '
            '이 던전은 더 이상 적대적이지 않은 곳이 되었다.',
    EndingType.hidden:
        '모든 존재를 이해했다. 처치하고, 해방하고, 함께했다.\n'
            '그 누구도 하지 못한 선택의 균형을 찾아낸 것이다.',
    EndingType.transcend:
        '던전의 근원과 하나가 되었다. 모든 선택, 모든 존재, 모든 가능성이\n'
            '하나의 진실로 수렴한다. 당신은 더 이상 탐험자가 아닌, 세계 그 자체다.',
  };

  /// 엔딩 타입에 해당하는 본문 텍스트.
  static String textFor(EndingType ending) =>
      _texts[ending] ?? _defaults[ending]!;

  /// 엔딩 타입에 해당하는 전체 표시 텍스트 (본문 + 엔딩명).
  static String displayTextFor(EndingType ending) =>
      '${textFor(ending)}\n\n— ${ending.displayName} 엔딩: ${ending.toneDescription} —';
}
