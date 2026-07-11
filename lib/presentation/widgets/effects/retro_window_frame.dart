import 'package:flutter/material.dart';
import 'package:soul_dungeon/presentation/theme/responsive_scale.dart';

/// GBC/포켓몬식 패널 프레임.
///
/// 둥근 두께 테두리 + 그라데이션 타이틀 바 + 채워진 젬 장식 + (선택)닫기 버튼.
/// 터미널 단선 창틀에서 핸드헬드 몬스터 게임 패널로 리스킨.
/// 상점·이벤트·휴식·미스터리·NPC·미니맵·상태창·전투 등 전 화면 공용.
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
    this.titleBarColor = const Color(0xFF241C3A),
    this.borderColor = const Color(0xFF8A7AC0),
    this.backgroundColor = const Color(0xFF120E1E),
    this.onClose,
    this.expand = false,
  });

  /// 색을 흰색 쪽으로 살짝 밝힘 (그라데이션 상단용).
  Color _lighten(Color c, [double t = 0.14]) =>
      Color.lerp(c, Colors.white, t) ?? c;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 2),
        // 핸드헬드 느낌의 단단한 그림자.
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Column(
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _titleBar(context),
            if (expand) Expanded(child: child) else child,
          ],
        ),
      ),
    );
  }

  Widget _titleBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_lighten(titleBarColor), titleBarColor],
        ),
        border: Border(bottom: BorderSide(color: borderColor, width: 2)),
      ),
      child: Row(
        children: [
          // 좌측 젬 (채워진 둥근 사각)
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: borderColor,
              borderRadius: BorderRadius.circular(3),
              boxShadow: [
                BoxShadow(
                  color: borderColor.withValues(alpha: 0.6),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          // 타이틀
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: const Color(0xFFF2ECFA),
                fontSize: ResponsiveScale.scaleFontSize(context, 13),
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
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: borderColor, width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '×',
                    style: TextStyle(
                      color: Color(0xFFF2ECFA),
                      fontSize: 14,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
