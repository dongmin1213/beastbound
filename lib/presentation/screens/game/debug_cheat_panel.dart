import 'package:flutter/material.dart';

/// 디버그 치트 패널 — kDebugMode에서만 사용.
///
/// BottomSheet로 표시되며, 갓 모드/HP 회복/AP 무한/금화 치트를 제공.
class DebugCheatPanel extends StatelessWidget {
  final bool godModeEnabled;
  final VoidCallback onToggleGodMode;
  final VoidCallback onFullHeal;
  final VoidCallback onSetAp99;
  final VoidCallback onSetGold9999;

  const DebugCheatPanel({
    super.key,
    required this.godModeEnabled,
    required this.onToggleGodMode,
    required this.onFullHeal,
    required this.onSetAp99,
    required this.onSetGold9999,
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
          ],
        ),
      ),
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
}
