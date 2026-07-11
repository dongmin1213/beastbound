import 'package:flutter/material.dart';
import 'package:soul_dungeon/presentation/theme/responsive_scale.dart';

/// 레트로 OS 스타일 버튼 — RetroWindowFrame과 일관된 시각 언어.
///
/// 특성:
/// - 얇은 1px 테두리, 최소 라운딩 (borderRadius: 2)
/// - 어두운 배경 + monospace 텍스트
/// - 비활성 시 opacity 0.4
/// - 터치 피드백: 배경 밝기 미세 증가
class RetroButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final double? fontSize;
  final FontWeight fontWeight;
  final bool enabled;
  final bool fullWidth;
  final EdgeInsets? padding;
  final double? height;

  const RetroButton({
    super.key,
    required this.label,
    this.onTap,
    this.backgroundColor = const Color(0xFF1A1A2E),
    this.borderColor = const Color(0xFF555555),
    this.textColor = const Color(0xFFE0E0E0),
    this.fontSize,
    this.fontWeight = FontWeight.normal,
    this.enabled = true,
    this.fullWidth = false,
    this.padding,
    this.height,
  });

  @override
  State<RetroButton> createState() => _RetroButtonState();
}

class _RetroButtonState extends State<RetroButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.enabled && widget.onTap != null;
    final resolvedFontSize =
        widget.fontSize ?? ResponsiveScale.scaleFontSize(context, 13);

    final bgColor = _isPressed && isEnabled
        ? Color.lerp(widget.backgroundColor, Colors.white, 0.08)!
        : widget.backgroundColor;

    Widget button = Semantics(
      button: true,
      label: widget.label,
      enabled: isEnabled,
      child: GestureDetector(
      onTap: isEnabled ? widget.onTap : null,
      onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
      child: AnimatedOpacity(
        opacity: isEnabled ? 1.0 : 0.4,
        duration: const Duration(milliseconds: 150),
        child: Container(
          height: widget.height,
          padding: widget.padding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: widget.borderColor, width: 1),
            borderRadius: BorderRadius.circular(2),
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: TextStyle(
              color: widget.textColor,
              fontSize: resolvedFontSize,
              fontFamily: 'Galmuri11',
              fontWeight: widget.fontWeight,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    ),
    );

    if (widget.fullWidth) {
      button = SizedBox(width: double.infinity, child: button);
    }

    return button;
  }
}
