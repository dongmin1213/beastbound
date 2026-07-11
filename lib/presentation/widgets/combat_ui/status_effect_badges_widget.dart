import 'package:flutter/material.dart';
import 'package:soul_dungeon/domain/combat/models/status_effect.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/presentation/theme/responsive_scale.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/status_effect_help_popup.dart';

/// 상태효과 뱃지 UI 위젯.
///
/// 버프(녹색 계열)와 디버프(적색 계열)를 시각적으로 구분하여
/// 아이콘 + 스택/턴 수를 표시하는 소형 뱃지 Wrap.
class StatusEffectBadgesWidget extends StatelessWidget {
  final List<StatusEffect> statuses;

  /// 뱃지 정렬 방향 (기본: 왼쪽).
  final Alignment alignment;

  const StatusEffectBadgesWidget({
    super.key,
    required this.statuses,
    this.alignment = Alignment.centerLeft,
  });

  @override
  Widget build(BuildContext context) {
    if (statuses.isEmpty) return const SizedBox.shrink();

    return Align(
      alignment: alignment,
      child: Wrap(
        spacing: 4,
        runSpacing: 3,
        children: statuses.map((s) => _StatusBadge(effect: s)).toList(),
      ),
    );
  }
}

/// 개별 상태효과 뱃지.
class _StatusBadge extends StatelessWidget {
  final StatusEffect effect;

  const _StatusBadge({required this.effect});

  @override
  Widget build(BuildContext context) {
    final badgeFontSize = ResponsiveScale.scaleFontSize(context, 10);
    final isDebuff = effect.isDebuff;
    final colors = _badgeColors(effect.type);
    final symbol = _badgeSymbol(effect.type);

    // 스택 수 표시: 버프는 +N, 디버프는 N
    final stackText = isDebuff ? '${effect.stacks}' : '+${effect.stacks}';
    // 턴 수 표시: turnsRemaining 있으면 (N턴)
    final turnText =
        effect.turnsRemaining != null ? ' ${effect.turnsRemaining}t' : '';

    final turnLabel =
        effect.turnsRemaining != null ? ', ${effect.turnsRemaining}턴 남음' : '';
    final stackLabel = effect.isDebuff
        ? '${effect.stacks}중첩'
        : '+${effect.stacks}중첩';

    return Semantics(
      label: '${effect.type.displayName} $stackLabel$turnLabel',
      child: GestureDetector(
        onTap: () => StatusEffectHelpPopup.show(
          context, effect.type, effect.stacks,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: colors.border, width: 0.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 아이콘/심볼
              Text(
                symbol,
                style: TextStyle(
                  fontSize: badgeFontSize,
                  color: colors.foreground,
                  fontFamily: 'Galmuri11',
                ),
              ),
              const SizedBox(width: 2),
              // 효과명 약자 + 스택
              Text(
                '${effect.type.displayName}$stackText$turnText',
                style: TextStyle(
                  fontSize: badgeFontSize,
                  color: colors.foreground,
                  fontFamily: 'Galmuri11',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 상태효과 타입별 심볼 문자.
  static String _badgeSymbol(StatusEffectType type) {
    return switch (type) {
      StatusEffectType.poison => '\u2620',    // 해골 (독)
      StatusEffectType.burn => '\u2668',      // 온천마크=불꽃 (화상)
      StatusEffectType.weak => '\u25BC',      // 하향 삼각형 (약화)
      StatusEffectType.vulnerable => '\u25CE', // 과녁 (취약)
      StatusEffectType.strength => '\u2694',  // 교차검 (힘)
      StatusEffectType.dexterity => '\u2727',  // 별 (민첩)
      StatusEffectType.thorn => '\u2740',     // 꽃=가시 (가시)
      StatusEffectType.regenerate => '\u2764', // 하트 (재생)
    };
  }

  /// 상태효과 타입별 색상 세트.
  static _BadgeColors _badgeColors(StatusEffectType type) {
    return switch (type) {
      // ── 디버프 (적/주황 계열) ──
      StatusEffectType.poison => const _BadgeColors(
        foreground: Color(0xFF88FF88),
        background: Color(0xFF1A2E1A),
        border: Color(0xFF336633),
      ),
      StatusEffectType.burn => const _BadgeColors(
        foreground: Color(0xFFFF8844),
        background: Color(0xFF2E1A0A),
        border: Color(0xFF664422),
      ),
      StatusEffectType.weak => const _BadgeColors(
        foreground: Color(0xFFFF6B6B),
        background: Color(0xFF2E1A1A),
        border: Color(0xFF663333),
      ),
      StatusEffectType.vulnerable => const _BadgeColors(
        foreground: Color(0xFFFF7043),
        background: Color(0xFF2E1A14),
        border: Color(0xFF663322),
      ),
      // ── 버프 (녹/청/금 계열) ──
      StatusEffectType.strength => const _BadgeColors(
        foreground: Color(0xFFFFD54F),
        background: Color(0xFF2E2A14),
        border: Color(0xFF665522),
      ),
      StatusEffectType.dexterity => const _BadgeColors(
        foreground: Color(0xFF42A5F5),
        background: Color(0xFF14202E),
        border: Color(0xFF224466),
      ),
      StatusEffectType.thorn => const _BadgeColors(
        foreground: Color(0xFFAB47BC),
        background: Color(0xFF241428),
        border: Color(0xFF553366),
      ),
      StatusEffectType.regenerate => const _BadgeColors(
        foreground: Color(0xFF66BB6A),
        background: Color(0xFF142E16),
        border: Color(0xFF226633),
      ),
    };
  }
}

/// 뱃지 색상 세트 (전경, 배경, 테두리).
class _BadgeColors {
  final Color foreground;
  final Color background;
  final Color border;

  const _BadgeColors({
    required this.foreground,
    required this.background,
    required this.border,
  });
}
