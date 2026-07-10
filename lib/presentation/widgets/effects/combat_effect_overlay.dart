import 'dart:async';

import 'package:flutter/material.dart';
import 'package:soul_dungeon/core/events/combat_milestone_event.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/core/events/player_damaged_event.dart';
import 'package:soul_dungeon/core/events/rest_choice_event.dart';
import 'package:soul_dungeon/core/events/event_choice_event.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';

/// 전투 이펙트 오버레이 -- 피격/방어/회복 시 화면 전체 틴트 플래시.
///
/// [GameEventBus]를 구독하여 이벤트별 색상 플래시를 200ms 페이드아웃으로 표시.
/// [IgnorePointer]로 터치 이벤트를 하위 위젯으로 통과시킴.
class CombatEffectOverlay extends StatefulWidget {
  final GameEventBus gameEventBus;

  const CombatEffectOverlay({
    super.key,
    required this.gameEventBus,
  });

  @override
  State<CombatEffectOverlay> createState() => _CombatEffectOverlayState();
}

class _CombatEffectOverlayState extends State<CombatEffectOverlay>
    with SingleTickerProviderStateMixin {
  static const _red = Color(0x33FF0000);
  static const _green = Color(0x3300FF00);
  static const _blue = Color(0x330066FF);

  late final AnimationController _controller;
  StreamSubscription<PlayerDamagedEvent>? _damagedSub;
  StreamSubscription<CombatMilestoneEvent>? _milestoneSub;
  StreamSubscription<RestChoiceEvent>? _restSub;
  StreamSubscription<EventChoiceEvent>? _eventSub;

  Color _flashColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    if (!AppTheme.enableAnimations) return;

    _damagedSub = widget.gameEventBus.on<PlayerDamagedEvent>().listen((event) {
      if (event.hpLost > 0) _flash(_red);
    });

    _milestoneSub =
        widget.gameEventBus.on<CombatMilestoneEvent>().listen((event) {
      if (event.type == CombatMilestoneType.block) _flash(_blue);
    });

    _restSub = widget.gameEventBus.on<RestChoiceEvent>().listen((event) {
      if (event.hpChange > 0 || event.maxHpChange > 0) _flash(_green);
    });

    _eventSub = widget.gameEventBus.on<EventChoiceEvent>().listen((event) {
      if (event.hpChange > 0) _flash(_green);
    });
  }

  void _flash(Color color) {
    if (!mounted) return;
    setState(() => _flashColor = color);
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
    _damagedSub?.cancel();
    _milestoneSub?.cancel();
    _restSub?.cancel();
    _eventSub?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!AppTheme.enableAnimations) return const SizedBox.shrink();

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // 1.0 → 0.0 fade-out: controller가 forward이므로 역방향 opacity
          final opacity = 1.0 - _controller.value;
          return ColoredBox(
            color: _flashColor.withValues(alpha: _flashColor.a * opacity),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}
