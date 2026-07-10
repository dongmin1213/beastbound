import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/models/job_path.dart';
import 'package:soul_dungeon/core/models/disposition_axis.dart';

/// 직업 분화 판정 순수 함수.
///
/// 1차 전직 평가 순서:
/// 1. 5주축(harmony 제외) 단일 축 >= threshold → 해당 non-hidden (또는 해금된 hidden) JobPath
/// 2. 방랑자 조건: non-zero 3개+ AND total >= minTotal AND deviation <= maxDeviation
/// 3. 조건 불충족 → null (미분화 유지)
///
/// 2차 전직 평가 순서:
/// 1. 상위직: 현재 1차 직업의 축이 advancedJobThreshold 이상 → 해당 상위직
/// 2. 조합직: 주축 >= comboJobPrimaryThreshold AND 부축 >= comboJobSecondaryThreshold
/// 3. 상위직이 조합직보다 우선
class ClassChangeDetector {
  const ClassChangeDetector._();

  /// [unlockedHiddenJobIds]: 해금된 히든 직업 ID Set (해금된 직업은 분화 대상에 포함).
  ///
  /// 후보가 2개 이상이면 [evaluateCandidates]를 사용해 전부 반환.
  /// 이 메서드는 하위 호환을 위해 첫 번째 후보만 반환.
  static JobPath? evaluate(
    Map<DispositionAxis, int> disposition,
    BuildConfig config, {
    Set<String> unlockedHiddenJobIds = const {},
  }) {
    final candidates = evaluateCandidates(
      disposition,
      config,
      unlockedHiddenJobIds: unlockedHiddenJobIds,
    );
    return candidates.isEmpty ? null : candidates.first;
  }

  /// 1차 전직 후보 리스트 반환.
  ///
  /// 히든 직업 해금 + 같은 축 기본 직업 존재 → [기본, 히든] 둘 다 반환.
  /// 방랑자/조율사도 동일: 조율사 해금 시 [방랑자, 조율사] 반환.
  /// 후보 없으면 빈 리스트.
  static List<JobPath> evaluateCandidates(
    Map<DispositionAxis, int> disposition,
    BuildConfig config, {
    Set<String> unlockedHiddenJobIds = const {},
  }) {
    // 1. 축별 검사 (harmony 제외)
    for (final axis in DispositionAxis.values) {
      if (axis == DispositionAxis.harmony) continue;
      final value = disposition[axis] ?? 0;
      if (value < config.classChangeThreshold) continue;

      final baseJob = JobPath.values.firstWhere(
        (j) => !j.isHidden && !j.isAdvanced && !j.isCombination && j.dominantAxis == axis,
        orElse: () => const Wanderer(),
      );
      final hiddenJob = JobPath.values.cast<JobPath?>().firstWhere(
        (j) => j!.isHidden && j.dominantAxis == axis && unlockedHiddenJobIds.contains(j.id),
        orElse: () => null,
      );

      if (hiddenJob != null) {
        return [baseJob, hiddenJob];
      }
      return [baseJob];
    }

    // 2. 균형 조건 검사 → 방랑자 또는 [방랑자, 조율사]
    final mainAxes = DispositionAxis.values
        .where((a) => a != DispositionAxis.harmony);
    final values = mainAxes.map((a) => disposition[a] ?? 0).toList();
    final nonZero = values.where((v) => v > 0).toList();

    if (nonZero.length < 3) return const [];

    final total = values.fold(0, (a, b) => a + b);
    if (total < config.wandererMinTotal) return const [];

    final maxVal = nonZero.reduce((a, b) => a > b ? a : b);
    final minVal = nonZero.reduce((a, b) => a < b ? a : b);
    if (maxVal - minVal <= config.wandererMaxDeviation) {
      if (unlockedHiddenJobIds.contains('harmonist')) {
        return const [Wanderer(), Harmonist()];
      }
      return const [Wanderer()];
    }

    return const [];
  }

  // ═══════════════════════════════════════════════════════════
  // 2차 전직 판정
  // ═══════════════════════════════════════════════════════════

  /// 2차 전직 후보 리스트 반환.
  ///
  /// [currentJob]: 현재 1차 전직된 직업.
  /// [disposition]: 현재 성향 맵.
  /// [config]: 밸런스 설정.
  ///
  /// 반환 우선순위: 상위직 > 조합직.
  /// 상위직: 현재 직업의 축이 advancedJobThreshold 이상.
  /// 조합직: 주축 >= comboJobPrimaryThreshold AND 부축 >= comboJobSecondaryThreshold.
  /// 후보 없으면 빈 리스트.
  static List<JobPath> evaluateSecondClassCandidates(
    JobPath currentJob,
    Map<DispositionAxis, int> disposition,
    BuildConfig config,
  ) {
    // 상위직 체크: 현재 직업의 주축이 상위직 임계값에 도달했는지
    final advancedCandidates = _evaluateAdvanced(currentJob, disposition, config);
    if (advancedCandidates.isNotEmpty) return advancedCandidates;

    // 조합직 체크: 두 축의 조합 요건 충족 여부
    final comboCandidates = _evaluateCombination(disposition, config);
    if (comboCandidates.isNotEmpty) return comboCandidates;

    return const [];
  }

  /// 상위직 판정 — 현재 직업의 축이 advancedJobThreshold 이상이면 해당 상위직 반환.
  static List<JobPath> _evaluateAdvanced(
    JobPath currentJob,
    Map<DispositionAxis, int> disposition,
    BuildConfig config,
  ) {
    // 1차 전직 직업만 2차 전직 가능 (이미 2차면 스킵)
    if (currentJob.isAdvanced || currentJob.isCombination) return const [];

    final dominantValue = disposition[currentJob.dominantAxis] ?? 0;
    if (dominantValue < config.advancedJobThreshold) return const [];

    // 현재 직업을 전제 조건으로 하는 상위직 찾기
    final advanced = JobPath.tier2Values
        .where((j) => j.isAdvanced && j.requiredPrimaryJobId == currentJob.id)
        .toList();

    return advanced;
  }

  /// 조합직 판정 — 두 축의 조합 요건 충족 시 해당 조합직 반환.
  static List<JobPath> _evaluateCombination(
    Map<DispositionAxis, int> disposition,
    BuildConfig config,
  ) {
    final candidates = <JobPath>[];

    for (final job in JobPath.tier2Values) {
      if (!job.isCombination) continue;
      final axes = job.requiredAxes;
      if (axes == null) continue;

      final primaryValue = disposition[axes.primary] ?? 0;
      final secondaryValue = disposition[axes.secondary] ?? 0;

      if (primaryValue >= config.comboJobPrimaryThreshold &&
          secondaryValue >= config.comboJobSecondaryThreshold) {
        candidates.add(job);
      }
    }

    return candidates;
  }
}
