import 'package:flutter/material.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';

/// 공통 게이지 바 위젯.
///
/// HP, 적 HP 등 current/max 비율을 시각적으로 표시한다.
/// [pulsing]이 true이면 fill 바가 0.5초 주기로 깜빡인다 (HP 위험).
class GaugeBar extends StatefulWidget {
  final int current;
  final int max;
  final Color fillColor;
  final Color bgColor;
  final double height;
  final double borderRadius;
  final bool pulsing;

  const GaugeBar({
    super.key,
    required this.current,
    required this.max,
    this.fillColor = AppTheme.gaugeHp,
    this.bgColor = AppTheme.gaugeHpBg,
    this.height = 8,
    this.borderRadius = 4,
    this.pulsing = false,
  });

  @override
  State<GaugeBar> createState() => _GaugeBarState();
}

class _GaugeBarState extends State<GaugeBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 0.4).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    if (widget.pulsing) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(GaugeBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pulsing && !oldWidget.pulsing) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.pulsing && oldWidget.pulsing) {
      _pulseController.stop();
      _pulseController.value = 0.0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ratio =
        widget.max > 0 ? (widget.current / widget.max).clamp(0.0, 1.0) : 0.0;

    final bar = Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.bgColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: ratio,
        child: Container(
          decoration: BoxDecoration(
            color: widget.fillColor,
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        ),
      ),
    );

    if (!widget.pulsing) return bar;

    return FadeTransition(
      opacity: _pulseAnimation,
      child: bar,
    );
  }
}
