import 'package:flutter/material.dart';

/// CRT 비네트 오버레이 — 화면 가장자리를 어둡게 처리.
/// IgnorePointer로 터치 이벤트를 통과시킴.
class VignetteOverlay extends StatelessWidget {
  /// 비네트 edge 색상. null이면 검정 기본값.
  final Color? vignetteColor;

  const VignetteOverlay({super.key, this.vignetteColor});

  @override
  Widget build(BuildContext context) {
    final base = vignetteColor ?? Colors.black;
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              Colors.transparent,
              base.withValues(alpha: 0.04),
              base.withValues(alpha: 0.2),
            ],
            stops: const [0.6, 0.85, 1.0],
          ),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}
