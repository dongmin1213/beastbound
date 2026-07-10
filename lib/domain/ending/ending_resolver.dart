import 'package:soul_dungeon/domain/ending/ending_types.dart';
import 'package:soul_dungeon/core/models/boss_choice.dart';

/// 보스 선택 누적 → 엔딩 유형 결정.
///
/// 규칙:
/// - 전원 처치 → slay, 전원 해방 → liberate, 전원 공존 → coexist
/// - 최다 선택 유형 → 해당 엔딩
/// - 동점 → 4층 보스(안) 선택 우선
/// - 히든 엔딩: 각 유형 최소 1개 + 5보스 완료 + 다수결 없음(최대 2개)
/// - 초월 엔딩: 히든 직업 + 히든 엔딩 조건 + 기억 12개+
class EndingResolver {
  EndingResolver._();

  /// 보스 선택 목록 → 엔딩 유형 결정.
  ///
  /// [isHiddenJob] 히든 직업 사용 여부.
  /// [unlockedMemoryCount] 해금된 기억 수.
  static EndingType resolve(
    List<BossChoice> choices, {
    bool isHiddenJob = false,
    int unlockedMemoryCount = 0,
  }) {
    // 보스를 한 번도 처치/선택하지 않은 경우 기본값 slay (튜토리얼 중단·엣지케이스 대비).
    if (choices.isEmpty) return EndingType.slay;

    // 6→3 엔딩 카테고리로 집계 (slay/consume→slay, liberate/protect→liberate, coexist/study→coexist)
    final counts = <BossChoiceType, int>{};
    for (final choice in choices) {
      final category = choice.choiceType.endingCategory;
      counts[category] = (counts[category] ?? 0) + 1;
    }

    // 최다 투표 찾기
    final maxCount = counts.values.reduce((a, b) => a > b ? a : b);

    // 히든 엔딩 조건: 3가지 카테고리 모두 1개 이상 + 5보스 완료 + 다수결 없음
    final meetsHiddenCondition = choices.length >= 5 &&
        counts.containsKey(BossChoiceType.slay) &&
        counts.containsKey(BossChoiceType.liberate) &&
        counts.containsKey(BossChoiceType.coexist) &&
        maxCount <= 2;

    // 초월 엔딩: 히든 직업 + 히든 엔딩 조건 + 기억 12개+
    if (meetsHiddenCondition && isHiddenJob && unlockedMemoryCount >= 12) {
      return EndingType.transcend;
    }

    // 히든 엔딩
    if (meetsHiddenCondition) {
      return EndingType.hidden;
    }

    final topTypes = counts.entries
        .where((e) => e.value == maxCount)
        .map((e) => e.key)
        .toList();

    // 단독 최다 → 해당 엔딩
    if (topTypes.length == 1) {
      return _toEndingType(topTypes.first);
    }

    // 동점 → 4층 보스(안) 선택 카테고리 우선
    final floor4Choice = choices
        .where((c) => c.floor == 4)
        .toList();
    if (floor4Choice.isNotEmpty &&
        topTypes.contains(floor4Choice.first.choiceType.endingCategory)) {
      return _toEndingType(floor4Choice.first.choiceType.endingCategory);
    }

    // 4층 선택 없거나 동점에 포함 안 됨 → 마지막 보스 선택 카테고리
    return _toEndingType(choices.last.choiceType.endingCategory);
  }

  static EndingType _toEndingType(BossChoiceType type) {
    return switch (type) {
      BossChoiceType.slay || BossChoiceType.consume => EndingType.slay,
      BossChoiceType.liberate || BossChoiceType.protect => EndingType.liberate,
      BossChoiceType.coexist || BossChoiceType.study => EndingType.coexist,
    };
  }
}
