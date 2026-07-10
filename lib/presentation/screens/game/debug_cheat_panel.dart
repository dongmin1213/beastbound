import 'package:flutter/material.dart';
import 'package:soul_dungeon/core/models/job_path.dart';

/// 디버그 치트 패널 — kDebugMode에서만 사용.
///
/// BottomSheet로 표시되며, 갓 모드/HP 회복/AP 무한/금화/전직 치트를 제공.
class DebugCheatPanel extends StatelessWidget {
  final bool godModeEnabled;
  final VoidCallback onToggleGodMode;
  final VoidCallback onFullHeal;
  final VoidCallback onSetAp99;
  final VoidCallback onSetGold9999;
  final void Function(JobPath job) onForceClassChange;
  final void Function(List<JobPath> candidates, {bool isSecond}) onShowClassChoices;
  final VoidCallback? onSimulateBossClassChange;

  const DebugCheatPanel({
    super.key,
    required this.godModeEnabled,
    required this.onToggleGodMode,
    required this.onFullHeal,
    required this.onSetAp99,
    required this.onSetGold9999,
    required this.onForceClassChange,
    required this.onShowClassChoices,
    this.onSimulateBossClassChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'DEBUG CHEATS',
              style: TextStyle(
                color: Color(0xFFFF4444),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // 갓 모드 토글
            _buildToggleRow(
              label: 'God Mode (무적)',
              enabled: godModeEnabled,
              onTap: () {
                onToggleGodMode();
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
            // HP 풀 회복
            _buildButton(
              label: 'HP Full Heal',
              color: const Color(0xFF44FF44),
              onTap: () {
                onFullHeal();
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
            // AP 99
            _buildButton(
              label: 'AP = 99 (전투 중)',
              color: const Color(0xFF4488FF),
              onTap: () {
                onSetAp99();
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
            // 금화 9999
            _buildButton(
              label: 'Gold = 9999',
              color: const Color(0xFFFFD700),
              onTap: () {
                onSetGold9999();
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
            // ── 선택지 UI 테스트 ──
            const Divider(color: Color(0xFF444444)),
            const SizedBox(height: 8),
            const Text(
              '전직 선택지 UI 테스트',
              style: TextStyle(
                color: Color(0xFF44DDAA),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _buildSmallButton(context, '전사 vs 사신', const Color(0xFF44DDAA), () {
                  onShowClassChoices([const Warrior(), const Reaper()], isSecond: false);
                }),
                _buildSmallButton(context, '암살자 vs 환술사', const Color(0xFF44DDAA), () {
                  onShowClassChoices([const Assassin(), const Illusionist()], isSecond: false);
                }),
                _buildSmallButton(context, '방랑자 vs 조율사', const Color(0xFF44DDAA), () {
                  onShowClassChoices([const Wanderer(), const Harmonist()], isSecond: false);
                }),
              ],
            ),
            if (onSimulateBossClassChange != null) ...[
              const SizedBox(height: 8),
              _buildButton(
                label: '🐛 보스방 전직 테스트 (전사 vs 사신)',
                color: const Color(0xFFFF6644),
                onTap: () {
                  onSimulateBossClassChange!();
                  Navigator.pop(context);
                },
              ),
            ],
            const SizedBox(height: 16),
            // ── 전직 섹션 ──
            const Divider(color: Color(0xFF444444)),
            const SizedBox(height: 8),
            const Text(
              '강제 전직',
              style: TextStyle(
                color: Color(0xFFCC66FF),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '1차 전직',
              style: TextStyle(color: Color(0xFF888888), fontSize: 12),
            ),
            const SizedBox(height: 4),
            _buildJobGrid(context, JobPath.tier1Values),
            const SizedBox(height: 8),
            const Text(
              '2차 전직 — 상위직',
              style: TextStyle(color: Color(0xFF888888), fontSize: 12),
            ),
            const SizedBox(height: 4),
            _buildJobGrid(
              context,
              JobPath.tier2Values.where((j) => j.isAdvanced).toList(),
            ),
            const SizedBox(height: 8),
            const Text(
              '2차 전직 — 조합직',
              style: TextStyle(color: Color(0xFF888888), fontSize: 12),
            ),
            const SizedBox(height: 4),
            _buildJobGrid(
              context,
              JobPath.tier2Values.where((j) => j.isCombination).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildJobGrid(BuildContext context, List<JobPath> jobs) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: jobs.map((job) {
        final color = job.isHidden
            ? const Color(0xFFFF6644)
            : job.isCombination
                ? const Color(0xFFFFAA44)
                : job.isAdvanced
                    ? const Color(0xFF66DDFF)
                    : const Color(0xFFCC66FF);
        return GestureDetector(
          onTap: () {
            onForceClassChange(job);
            Navigator.pop(context);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF222222),
              border: Border.all(color: color.withValues(alpha: 0.5)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              job.displayName,
              style: TextStyle(color: color, fontSize: 13),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildToggleRow({
    required String label,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: enabled
              ? const Color(0xFF442222)
              : const Color(0xFF222222),
          border: Border.all(
            color: enabled
                ? const Color(0xFFFF4444)
                : const Color(0xFF444444),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            Text(
              enabled ? 'ON' : 'OFF',
              style: TextStyle(
                color: enabled
                    ? const Color(0xFFFF4444)
                    : const Color(0xFF888888),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF222222),
          border: Border.all(color: color.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(color: color, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildSmallButton(
    BuildContext context,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: () {
        onTap();
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF222222),
          border: Border.all(color: color.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(color: color, fontSize: 13),
        ),
      ),
    );
  }
}
