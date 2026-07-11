import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';

/// 노드 시각 상태.
enum NodeVisualState {
  current,
  visited,
  available,
  locked,
}

/// RoomType → 텍스트 심볼 매핑.
class RoomSymbolData {
  RoomSymbolData._();

  static String symbol(RoomType type) => switch (type) {
        RoomType.combat => 'X',
        RoomType.elite => 'E',
        RoomType.event => '!',
        RoomType.mystery => '?',
        RoomType.shop => '\$',
        RoomType.npc => '@',
        RoomType.rest => 'R',
        RoomType.boss => 'B',
      };

  /// 방 타입별 고유 색상 (available/current 상태에서 사용).
  static Color typeAccentColor(RoomType type) => switch (type) {
        RoomType.combat => const Color(0xFFCC4444),
        RoomType.elite => const Color(0xFFFF6B6B),
        RoomType.event => const Color(0xFFE8A838),
        RoomType.mystery => const Color(0xFF8888CC),
        RoomType.shop => const Color(0xFF55AA55),
        RoomType.npc => const Color(0xFF6699CC),
        RoomType.rest => const Color(0xFF44AA88),
        RoomType.boss => const Color(0xFFDD5555),
      };

  static Color color(NodeVisualState state, {RoomType? roomType}) =>
      switch (state) {
        NodeVisualState.current => roomType == RoomType.elite
            ? AppTheme.minimapEliteCurrentColor
            : AppTheme.minimapCurrentColor,
        NodeVisualState.visited => AppTheme.minimapVisitedColor,
        NodeVisualState.available => roomType != null
            ? typeAccentColor(roomType)
            : AppTheme.minimapAvailableColor,
        NodeVisualState.locked => AppTheme.minimapLockedColor,
      };
}

/// RoomType 심볼 위젯.
class RoomSymbolWidget extends StatelessWidget {
  final RoomType roomType;
  final NodeVisualState visualState;
  final VoidCallback? onTap;

  /// 타입 공개 여부 — false이면 잠금 노드가 [·]로 표시 (존재만 암시).
  final bool typeRevealed;

  const RoomSymbolWidget({
    super.key,
    required this.roomType,
    required this.visualState,
    this.onTap,
    this.typeRevealed = true,
  });

  @override
  Widget build(BuildContext context) {
    final symbolText = RoomSymbolData.symbol(roomType);
    final symbolColor = RoomSymbolData.color(visualState, roomType: roomType);
    final isCurrent = visualState == NodeVisualState.current;
    final isAvailable = visualState == NodeVisualState.available;
    final isLocked = visualState == NodeVisualState.locked;

    // 현재/방문/선택가능 노드는 실제 심볼 표시
    // 잠금 노드: typeRevealed면 [?], 미공개면 [·] (존재만 암시)
    final showSymbol = isCurrent ||
        visualState == NodeVisualState.visited ||
        isAvailable ||
        (isLocked && typeRevealed);

    final stateLabel = switch (visualState) {
      NodeVisualState.current => '현재 위치',
      NodeVisualState.visited => '방문 완료',
      NodeVisualState.available => '이동 가능',
      NodeVisualState.locked => '잠김',
    };
    final typeLabel = switch (roomType) {
      RoomType.combat => '전투',
      RoomType.elite => '정예',
      RoomType.event => '이벤트',
      RoomType.mystery => '미스터리',
      RoomType.shop => '상점',
      RoomType.npc => 'NPC',
      RoomType.rest => '휴식',
      RoomType.boss => '보스',
    };

    Widget node = Semantics(
      button: isAvailable,
      label: '$typeLabel 방, $stateLabel',
      child: GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          border: Border.all(
            color: isCurrent
                ? AppTheme.minimapCurrentColor
                : isAvailable
                    ? symbolColor.withValues(alpha: 0.9)
                    : Colors.transparent,
            width: isCurrent ? 2.5 : (isAvailable ? 1.5 : 1),
          ),
          borderRadius: BorderRadius.circular(8),
          // GBC 칩: 이동 가능/현재 노드는 타입색으로 채워 도드라지게.
          color: isCurrent
              ? AppTheme.minimapCurrentColor.withValues(alpha: 0.28)
              : isAvailable
                  ? symbolColor.withValues(alpha: 0.22)
                  : null,
          boxShadow: (isCurrent || isAvailable)
              ? [
                  BoxShadow(
                    color: (isCurrent
                            ? AppTheme.minimapCurrentColor
                            : symbolColor)
                        .withValues(alpha: 0.4),
                    blurRadius: 5,
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          showSymbol ? '[$symbolText]' : '[\u00B7]',
          style: TextStyle(
            color: symbolColor,
            fontSize: 14,
            fontWeight: isCurrent || isAvailable ? FontWeight.bold : FontWeight.normal,
            fontFamily: 'Galmuri11',
          ),
        ),
      ),
    ),
    );

    // 현재 위치 노드: 부드러운 펄스 글로우
    if (isCurrent && AppTheme.enableAnimations) {
      node = node
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .shimmer(
            duration: 2000.ms,
            color: AppTheme.minimapCurrentColor.withValues(alpha: 0.3),
          );
    }

    return node;
  }
}
