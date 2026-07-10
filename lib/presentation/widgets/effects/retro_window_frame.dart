import 'package:flutter/material.dart';
import 'package:soul_dungeon/presentation/theme/responsive_scale.dart';

/// 레트로 OS 윈도우 프레임 — "현실접속" 스타일 차용.
///
/// 타이틀 바 + 얇은 단선 테두리 + 닫기 버튼(선택).
/// 상점, 이벤트, 휴식, 미스터리, NPC, 미니맵, 상태창 등에 적용.
class RetroWindowFrame extends StatelessWidget {
  final String title;
  final Widget child;
  final Color titleBarColor;
  final Color borderColor;
  final Color backgroundColor;
  final VoidCallback? onClose;

  /// true일 때 child를 Expanded로 감싸 부모 공간을 채운다.
  final bool expand;

  const RetroWindowFrame({
    super.key,
    required this.title,
    required this.child,
    this.titleBarColor = const Color(0xFF1A1A2E),
    this.borderColor = const Color(0xFF555555),
    this.backgroundColor = const Color(0xFF0D0D14),
    this.onClose,
    this.expand = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── 타이틀 바 ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: titleBarColor,
              border: Border(
                bottom: BorderSide(color: borderColor, width: 1),
              ),
            ),
            child: Row(
              children: [
                // 좌측 장식 도트
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: borderColor,
                      width: 1,
                    ),
                  ),
                ),
                // 타이틀
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: const Color(0xFFB0B0B0),
                      fontSize: ResponsiveScale.scaleFontSize(context, 12),
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                // 닫기 버튼 (선택적)
                if (onClose != null)
                  Semantics(
                    button: true,
                    label: '닫기',
                    child: GestureDetector(
                    onTap: onClose,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        border: Border.all(color: borderColor, width: 1),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '\u00D7',
                        style: TextStyle(
                          color: Color(0xFFB0B0B0),
                          fontSize: 14,
                          fontFamily: 'monospace',
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                  ),
              ],
            ),
          ),
          // ── 콘텐츠 영역 ──
          if (expand) Expanded(child: child) else child,
        ],
      ),
    );
  }
}
