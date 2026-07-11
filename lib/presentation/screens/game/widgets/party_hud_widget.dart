import 'package:flutter/material.dart';
import 'package:soul_dungeon/domain/combat/content/monster_passives.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/theme/monster_display.dart';

/// 파티 HUD — 장착한 동료 몬스터를 상시 표시하는 가로 바.
///
/// 포켓몬식 "내 파티" 요소. 탐색 화면에 상시 노출되어 몬스터 테이머 정체성을 준다.
/// 빈 슬롯은 점선 자리로 표시. 탭 시 [onTap](동료 관리 등) 호출.
class PartyHudWidget extends StatelessWidget {
  final List<String> monsterIds;
  final int maxSlots;
  final VoidCallback? onTap;

  const PartyHudWidget({
    super.key,
    required this.monsterIds,
    this.maxSlots = 3,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF15101F),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF3A3352), width: 1.5),
          boxShadow: const [
            BoxShadow(color: Color(0x55000000), offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.groups_rounded,
                size: 15, color: Color(0xFF9A8AC0)),
            const SizedBox(width: 8),
            for (int i = 0; i < maxSlots; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              i < monsterIds.length
                  ? _slot(monsterIds[i])
                  : _emptySlot(),
            ],
            const Spacer(),
            const Icon(Icons.chevron_right,
                size: 16, color: Color(0xFF6A6280)),
          ],
        ),
      ),
    );
  }

  Widget _slot(String id) {
    final sprite = MonsterDisplay.sprite(id);
    final type = MonsterPassives.typeOf(id);
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: const Color(0xFF0E0A18),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: _typeColor(type).withValues(alpha: 0.7),
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: sprite == null
          ? const Icon(Icons.pets, size: 16, color: Color(0xFF554C6A))
          : Image.asset(sprite,
              width: 26, height: 26, filterQuality: FilterQuality.none),
    );
  }

  Widget _emptySlot() {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: const Color(0x330E0A18),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: const Color(0xFF2A2440), width: 1.5),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.add, size: 14, color: Color(0xFF4A4460)),
    );
  }

  Color _typeColor(MonsterType type) => switch (type) {
        MonsterType.attack => const Color(0xFFE0704C),
        MonsterType.guard => const Color(0xFF5FB0C0),
        MonsterType.venom => const Color(0xFF7FC04C),
        MonsterType.vitality => const Color(0xFF6FCF6F),
        MonsterType.swift => const Color(0xFFE0C040),
        MonsterType.none => AppTheme.minimapAvailableColor,
      };
}
