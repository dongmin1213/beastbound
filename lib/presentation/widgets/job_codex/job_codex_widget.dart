import 'package:flutter/material.dart';
import 'package:soul_dungeon/core/models/job_path.dart';
import 'package:soul_dungeon/domain/progression/unlock/job_unlock_registry.dart';
import 'package:soul_dungeon/core/models/disposition_axis.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/theme/pixel_art_assets.dart';
import 'package:soul_dungeon/presentation/theme/responsive_scale.dart';
import 'package:soul_dungeon/presentation/widgets/common/pixel_art_icon.dart';
import 'package:soul_dungeon/presentation/widgets/common/programmatic_job_icon.dart';
import 'package:soul_dungeon/presentation/widgets/effects/retro_window_frame.dart';

/// 직업 도감 위젯 — 해금 상태 + 설명 + 성향 + 전직 경로 표시.
///
/// 9개 1차 직업 + 14개 2차 직업의 해금 상태를 표시하고,
/// 각 직업의 설명, 성향 축, 전직 가능 경로를 보여준다.
class JobCodexWidget extends StatelessWidget {
  /// 해금된 히든 직업 ID (MetaSaveData.unlockedHiddenJobIds).
  final Set<String> unlockedHiddenJobIds;

  /// 닫기 콜백.
  final VoidCallback? onClose;

  const JobCodexWidget({
    super.key,
    required this.unlockedHiddenJobIds,
    this.onClose,
  });

  /// 히든 1차 직업 ID 목록 (사신, 환술사, 조율사).
  static final Set<String> _hiddenJobIds =
      JobPath.values.where((j) => j.isHidden).map((j) => j.id).toSet();

  bool _isUnlocked(JobPath job) {
    // 히든 1차 직업 → 직접 해금 필요
    if (job.isHidden) return unlockedHiddenJobIds.contains(job.id);
    // 2차 전직 상위직 → 기반 1차 직업이 히든이면 해금 여부 확인
    if (job.isAdvanced && job.requiredPrimaryJobId != null) {
      final baseId = job.requiredPrimaryJobId!;
      if (_hiddenJobIds.contains(baseId) &&
          !unlockedHiddenJobIds.contains(baseId)) {
        return false; // 기반 히든 직업 미해금 → 상위직도 잠김
      }
    }
    // 기본 직업 + 해금된 기반의 상위직 + 조합직 → 항상 표시
    return true;
  }

  /// 1차 직업에서 전직 가능한 2차 직업 목록.
  List<JobPath> _getAdvancementPaths(JobPath tier1Job) {
    final results = <JobPath>[];
    for (final job in JobPath.tier2Values) {
      if (job.isAdvanced && job.requiredPrimaryJobId == tier1Job.id) {
        results.add(job);
      }
      if (job.isCombination && job.requiredAxes != null) {
        final axes = job.requiredAxes!;
        if (axes.primary == tier1Job.dominantAxis ||
            axes.secondary == tier1Job.dominantAxis) {
          results.add(job);
        }
      }
    }
    return results;
  }

  @override
  Widget build(BuildContext context) {
    final jobs = JobPath.values;
    final fontSize = ResponsiveScale.scaleFontSize(context, 13);
    final smallFontSize = ResponsiveScale.scaleFontSize(context, 11);

    return RetroWindowFrame(
      title: '\u2694 직업 도감',
      borderColor: AppTheme.titleGold,
      expand: true,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '해금된 직업: ${_countUnlocked(jobs)} / ${jobs.length}',
              style: TextStyle(
                color: const Color(0xFFB0B0B0),
                fontSize: smallFontSize,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: [
                  // ── 1차 전직 ──
                  _buildSectionHeader('1차 직업', fontSize),
                  const SizedBox(height: 4),
                  for (final job in JobPath.tier1Values) ...[
                    _buildJobEntry(context, job, fontSize, smallFontSize),
                    const SizedBox(height: 8),
                  ],
                  const SizedBox(height: 12),
                  // ── 2차 전직 ──
                  _buildSectionHeader('2차 전직', fontSize),
                  const SizedBox(height: 4),
                  for (final job in JobPath.tier2Values) ...[
                    _buildJobEntry(context, job, fontSize, smallFontSize),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
            if (onClose != null) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: onClose,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF555555)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '\u25c0 닫기',
                    style: TextStyle(
                      color: const Color(0xFFB0B0B0),
                      fontSize: fontSize,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  int _countUnlocked(List<JobPath> jobs) {
    return jobs.where(_isUnlocked).length;
  }

  Widget _buildSectionHeader(String title, double fontSize) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF444444)),
        ),
      ),
      child: Text(
        '── $title ──',
        style: TextStyle(
          color: AppTheme.titleGold,
          fontSize: fontSize,
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildJobEntry(
    BuildContext context,
    JobPath job,
    double fontSize,
    double smallFontSize,
  ) {
    final unlocked = _isUnlocked(job);

    if (!unlocked) {
      return _buildLockedEntry(job, fontSize, smallFontSize);
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF333333)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 아이콘 + 이름
          _buildJobHeader(job, fontSize),
          const SizedBox(height: 4),
          // 설명
          Text(
            job.description,
            style: TextStyle(
              color: const Color(0xFF999999),
              fontSize: smallFontSize,
              fontFamily: 'monospace',
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 4),
          // 성향 축
          _buildAxisInfo(job, smallFontSize),
          // 전직 경로 (1차 직업만)
          if (job.tier == 1) ...[
            const SizedBox(height: 4),
            _buildAdvancementPaths(job, smallFontSize),
          ],
        ],
      ),
    );
  }

  Widget _buildJobHeader(JobPath job, double fontSize) {
    final spritePath = PixelArtAssets.jobSprite(job.id);
    return Row(
      children: [
        if (spritePath != null) ...[
          PixelArtIcon(spritePath, size: 28),
          const SizedBox(width: 8),
        ] else if (job.tier == 2) ...[
          ProgrammaticJobIcon(job: job, size: 28),
          const SizedBox(width: 8),
        ] else ...[
          Text(
            '\u2713 ',
            style: TextStyle(
              color: const Color(0xFF4CAF50),
              fontSize: fontSize,
              fontFamily: 'monospace',
            ),
          ),
        ],
        Expanded(
          child: Text(
            '${job.displayName} (${job.id})',
            style: TextStyle(
              color: const Color(0xFFE0E0E0),
              fontSize: fontSize,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAxisInfo(JobPath job, double smallFontSize) {
    // 2차 조합직: 필요 축 2개 표시
    if (job.isCombination && job.requiredAxes != null) {
      final axes = job.requiredAxes!;
      return Text(
        '필요 성향: ${axes.primary.displayName} + ${axes.secondary.displayName}',
        style: TextStyle(
          color: _axisColor(job.dominantAxis),
          fontSize: smallFontSize,
          fontFamily: 'monospace',
        ),
      );
    }

    // 1차 직업 / 2차 상위직: 주 성향 축 표시
    return Text(
      '성향: ${job.dominantAxis.displayName}',
      style: TextStyle(
        color: _axisColor(job.dominantAxis),
        fontSize: smallFontSize,
        fontFamily: 'monospace',
      ),
    );
  }

  Widget _buildAdvancementPaths(JobPath tier1Job, double smallFontSize) {
    final paths = _getAdvancementPaths(tier1Job);
    if (paths.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final path in paths)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              path.isCombination && path.requiredAxes != null
                  ? '  \u2192 ${path.displayName} (${path.requiredAxes!.primary.displayName} + ${path.requiredAxes!.secondary.displayName})'
                  : '  \u2192 ${path.displayName} (${path.dominantAxis.displayName} 심화)',
              style: TextStyle(
                color: const Color(0xFF888888),
                fontSize: smallFontSize,
                fontFamily: 'monospace',
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLockedEntry(
    JobPath job,
    double fontSize,
    double smallFontSize,
  ) {
    final condition = JobUnlockRegistry.conditionFor(job.id);
    final hint = condition?.hintText ?? '???';

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF222222)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Text(
            '\u2717 ',
            style: TextStyle(
              color: const Color(0xFF666666),
              fontSize: fontSize,
              fontFamily: 'monospace',
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '??? (잠김)',
                  style: TextStyle(
                    color: const Color(0xFF666666),
                    fontSize: fontSize,
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  hint,
                  style: TextStyle(
                    color: const Color(0xFF888888),
                    fontSize: smallFontSize,
                    fontFamily: 'monospace',
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 성향 축별 색상.
  Color _axisColor(DispositionAxis axis) {
    return switch (axis) {
      DispositionAxis.struggle => const Color(0xFFFF6B6B),
      DispositionAxis.mercy => const Color(0xFF81C784),
      DispositionAxis.wisdom => const Color(0xFF64B5F6),
      DispositionAxis.shadow => const Color(0xFFAB47BC),
      DispositionAxis.will => const Color(0xFFFFB74D),
      DispositionAxis.harmony => const Color(0xFFE0E0E0),
    };
  }
}
