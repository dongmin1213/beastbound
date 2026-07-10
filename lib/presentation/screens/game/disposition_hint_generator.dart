import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/logging/game_logger.dart';
import 'package:soul_dungeon/core/models/disposition_axis.dart';

/// 현재 성향 경향을 암시하는 분위기 텍스트 생성.
///
/// presentation 레이어 전용 — domain 값(disposition)을 읽어
/// 표시용 텍스트를 생성. domain 값 변경 없음.
/// JSON 에셋(assets/content/disposition_hints.json)에서 로드. 실패 시 기본값 폴백.
class DispositionHintGenerator {
  const DispositionHintGenerator._();

  static List<String> _harmonyHints = _defaultHarmonyHints;
  static Map<DispositionAxis, List<String>> _hintTexts = _defaultHintTexts;

  /// JSON 에셋에서 로드. 실패 시 기본값 폴백.
  static Future<void> load({
    AssetBundle? bundle,
    String path = 'assets/content/disposition_hints.json',
  }) async {
    try {
      final assetBundle = bundle ?? rootBundle;
      final jsonString = await assetBundle.loadString(path);
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      _harmonyHints = (json['harmony'] as List).cast<String>();
      final axes = json['axes'] as Map<String, dynamic>;
      final loaded = <DispositionAxis, List<String>>{};
      for (final entry in axes.entries) {
        final axis = DispositionAxis.values.byName(entry.key);
        loaded[axis] = (entry.value as List).cast<String>();
      }
      _hintTexts = loaded;
      GameLogger.info(LogSystem.core, 'DispositionHintGenerator loaded');
    } catch (e) {
      GameLogger.error(LogSystem.core, 'Failed to load disposition_hints.json, using defaults', e);
      _harmonyHints = _defaultHarmonyHints;
      _hintTexts = _defaultHintTexts;
    }
  }

  // ── 기본값 (JSON 로드 실패 시 폴백) ──

  static const _defaultHarmonyHints = [
    '모든 것이 조화로운 균형 속에서 빛나고 있다.',
    '영혼의 모든 면이 고르게 깨어나고 있다.',
    '어떤 한쪽으로도 치우치지 않는 고요한 힘이 감돈다.',
  ];

  static const _defaultHintTexts = <DispositionAxis, List<String>>{
    DispositionAxis.struggle: [
      '영혼 속에서 싸움의 불꽃이 희미하게 타오르고 있다.',
      '주먹을 쥐는 손에 힘이 들어간다. 무언가에 맞서고 싶은 충동.',
      '발걸음이 무겁지만 단호하다. 투쟁의 기운이 감돈다.',
    ],
    DispositionAxis.mercy: [
      '가슴 한편에서 따뜻한 빛이 희미하게 깃들고 있다.',
      '어둠 속에서도 손끝이 부드럽게 빛나고 있다.',
      '마음속 깊은 곳에서 자비로운 울림이 퍼져 나간다.',
    ],
    DispositionAxis.wisdom: [
      '눈앞의 어둠이 조금 더 선명하게 보이기 시작한다.',
      '던전의 속삭임이 귓가에 닿는다. 무언가를 깨달아가고 있다.',
      '세계의 이치가 서서히 눈앞에 펼쳐지고 있다.',
    ],
    DispositionAxis.shadow: [
      '당신의 발걸음이 어둠에 젖어가고 있다.',
      '그림자가 당신의 뒤를 조용히 따르고 있다.',
      '어둠이 당신을 두렵게 하지 않는다. 오히려 편안하다.',
    ],
    DispositionAxis.will: [
      '흔들리지 않는 무언가가 영혼 깊숙이 자리 잡고 있다.',
      '결의에 찬 기운이 발걸음을 이끌고 있다.',
      '어떤 유혹에도 굴하지 않겠다는 의지가 타오른다.',
    ],
  };

  /// 우세 축 판정 — harmony 제외, 동점 시 null.
  static DispositionAxis? getDominantAxis(
    Map<DispositionAxis, int> disposition,
  ) {
    DispositionAxis? dominant;
    int maxValue = 0;
    bool tied = false;

    for (final entry in disposition.entries) {
      if (entry.key == DispositionAxis.harmony) continue;
      if (entry.value > maxValue) {
        maxValue = entry.value;
        dominant = entry.key;
        tied = false;
      } else if (entry.value == maxValue && entry.value > 0) {
        tied = true;
      }
    }

    if (maxValue == 0 || tied) return null;
    return dominant;
  }

  /// 5축 균형 판정 — non-zero 3개 이상 AND 편차 <= maxDeviation.
  static bool isBalanced(
    Map<DispositionAxis, int> disposition,
    int maxDeviation,
  ) {
    final mainAxes = DispositionAxis.values
        .where((a) => a != DispositionAxis.harmony);
    final values = mainAxes.map((a) => disposition[a] ?? 0).toList();
    final nonZero = values.where((v) => v > 0).toList();

    if (nonZero.length < 3) return false;

    final maxVal = nonZero.reduce((a, b) => a > b ? a : b);
    final minVal = nonZero.reduce((a, b) => a < b ? a : b);
    return maxVal - minVal <= maxDeviation;
  }

  /// harmony 힌트 발동 최소 합계.
  /// 너무 이른 시점에 "균형" 힌트가 나오는 것을 방지.
  static const _harmonyMinTotal = 5;

  /// 조건 충족 시 힌트 텍스트 반환, 미충족 시 null.
  ///
  /// [floor]는 확장용 — 현재 미사용.
  /// [harmonyMaxDeviation]은 방랑자 경로 힌트용 — BuildConfig.wandererMaxDeviation 전달.
  static String? generateHint({
    required Map<DispositionAxis, int> disposition,
    required int roomsSinceLastHint,
    required int hintIndex,
    int floor = 1,
    required DispositionConfig config,
    int harmonyMaxDeviation = 2,
  }) {
    if (roomsSinceLastHint < config.hintCooldownRooms) return null;

    final dominant = getDominantAxis(disposition);
    if (dominant != null) {
      if (disposition[dominant]! < config.hintMinThreshold) return null;
      final texts = _hintTexts[dominant]!;
      return texts[hintIndex % texts.length];
    }

    // dominant null — harmony 분기 (최소 합계 체크)
    if (isBalanced(disposition, harmonyMaxDeviation)) {
      final mainAxes = DispositionAxis.values
          .where((a) => a != DispositionAxis.harmony);
      final total = mainAxes
          .map((a) => disposition[a] ?? 0)
          .fold(0, (a, b) => a + b);
      if (total < _harmonyMinTotal) return null;
      return _harmonyHints[hintIndex % _harmonyHints.length];
    }

    return null;
  }
}
