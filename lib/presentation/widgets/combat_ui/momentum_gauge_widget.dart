import 'dart:async';

import 'package:flutter/material.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/theme/responsive_scale.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/gauge_bar.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/momentum_calculator.dart';

/// 기세 게이지 위젯 (전투 중 표시)
///
/// StatefulWidget — delta 피드백 페이드아웃 타이머를 내부에서 관리.
/// Bloc은 순수 도메인 상태만 관리하고, UI 타이밍은 presentation 소유.
class MomentumGaugeWidget extends StatefulWidget {
  final int momentum;
  final MomentumDelta? lastDelta;
  final MomentumConfig config;
  final int apForCurrentTier;

  const MomentumGaugeWidget({
    super.key,
    required this.momentum,
    this.lastDelta,
    required this.config,
    this.apForCurrentTier = 0,
  });

  @override
  State<MomentumGaugeWidget> createState() => _MomentumGaugeWidgetState();
}

/// sameActionStreak 사유 텍스트의 font size 배율 (심각성 에스컬레이션).
const _streakFontScaleFactor = 1.2;

class _MomentumGaugeWidgetState extends State<MomentumGaugeWidget>
    with SingleTickerProviderStateMixin {
  MomentumDelta? _displayDelta;
  bool _deltaVisible = true;
  Timer? _fadeTimer;
  Timer? _clearTimer;
  late final AnimationController _tierPulseController;
  late final Animation<double> _tierPulseAnimation;
  MomentumTier? _lastTier;

  @override
  void initState() {
    super.initState();
    _tierPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _tierPulseAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _tierPulseController,
      curve: Curves.easeOut,
    ));
    // 초기 delta가 있으면 표시
    if (widget.lastDelta != null && widget.lastDelta!.value != 0) {
      _displayDelta = widget.lastDelta;
      _deltaVisible = true;
      _startFadeTimers();
    }
  }

  @override
  void didUpdateWidget(MomentumGaugeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lastDelta != oldWidget.lastDelta && widget.lastDelta != null) {
      _showDelta(widget.lastDelta!);
    }
    // 티어 변경 감지 → AP 텍스트 펄스 애니메이션
    final newTier = MomentumCalculator.getTier(widget.momentum, widget.config);
    if (_lastTier != null && _lastTier != newTier) {
      _tierPulseController.forward(from: 0);
    }
    _lastTier = newTier;
  }

  void _showDelta(MomentumDelta delta) {
    _fadeTimer?.cancel();
    _clearTimer?.cancel();
    setState(() {
      _displayDelta = delta;
      _deltaVisible = true;
    });
    _startFadeTimers();
  }

  void _startFadeTimers() {
    // 1.2초 후 페이드 시작, 1.5초 후 제거 (기존 2단계 패턴)
    _fadeTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => _deltaVisible = false);
    });
    _clearTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _displayDelta = null);
    });
  }

  @override
  void dispose() {
    _fadeTimer?.cancel();
    _clearTimer?.cancel();
    _tierPulseController.dispose();
    super.dispose();
  }

  Color _tierColor(MomentumTier tier) {
    return switch (tier) {
      MomentumTier.low => AppTheme.momentumLowColor,
      MomentumTier.medium => AppTheme.momentumMediumColor,
      MomentumTier.high => AppTheme.momentumHighColor,
    };
  }

  @override
  Widget build(BuildContext context) {
    final tier = MomentumCalculator.getTier(widget.momentum, widget.config);
    final range = widget.config.max - widget.config.min;
    final gaugeValue = range > 0
        ? (widget.momentum - widget.config.min).clamp(0, range)
        : 0;
    final tierColor = _tierColor(tier);
    final fontSize = ResponsiveScale.scaleFontSize(context, 12);

    return Semantics(
      label: '기세 ${widget.momentum}, ${tier.displayName}',
      child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 라벨 행: "기세" + 변동 + 수치 + 티어
          Row(
            children: [
              Text(
                '기세 ${widget.momentum}',
                style: TextStyle(
                  color: tierColor,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_displayDelta != null && _displayDelta!.value != 0) ...[
                const SizedBox(width: 4),
                AnimatedOpacity(
                  opacity: _deltaVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _displayDelta!.value > 0
                            ? '+${_displayDelta!.value}'
                            : '${_displayDelta!.value}',
                        style: TextStyle(
                          color: _displayDelta!.value > 0
                              ? AppTheme.momentumGainColor
                              : AppTheme.momentumLossColor,
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _buildReasonText(_displayDelta!.reason, fontSize),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              ScaleTransition(
                scale: _tierPulseAnimation,
                child: Text(
                  widget.apForCurrentTier > 0
                      ? '${tier.displayName} ${widget.apForCurrentTier}AP'
                      : tier.displayName,
                  style: TextStyle(
                    color: tierColor,
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // GaugeBar — HP 바와 동일 스타일
          GaugeBar(
            current: gaugeValue,
            max: range,
            fillColor: tierColor,
            bgColor: AppTheme.momentumGaugeBg,
            height: 10,
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildReasonText(MomentumChangeReason reason, double baseFontSize) {
    final text = switch (reason) {
      MomentumChangeReason.sameAction => '반복!',
      MomentumChangeReason.sameActionStreak => '연속 반복!',
      MomentumChangeReason.actionSwitch => null,
      MomentumChangeReason.environmentAction => '환경 보너스!',
      MomentumChangeReason.specialAction => null,
      MomentumChangeReason.cardTypeSwitch => null,
      MomentumChangeReason.none => null,
    };
    if (text == null) return const SizedBox.shrink();

    final isStreak = reason == MomentumChangeReason.sameActionStreak;
    final isEnvironment = reason == MomentumChangeReason.environmentAction;
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: TextStyle(
          color: isEnvironment
              ? AppTheme.momentumGainColor
              : AppTheme.momentumPenaltyReasonColor,
          fontSize: isStreak ? baseFontSize * _streakFontScaleFactor : baseFontSize,
          fontWeight: (isStreak || isEnvironment) ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

}
