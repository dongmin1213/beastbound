import 'package:flutter/material.dart';
import 'package:soul_dungeon/presentation/theme/responsive_scale.dart';
import 'package:soul_dungeon/presentation/widgets/text_engine/jamo_decomposer.dart';

enum TextSpeed {
  slow,
  normal,
  fast,
  instant,
}

class TypewriterWidget extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final int charsPerSecondSlow;
  final int charsPerSecondNormal;
  final int charsPerSecondFast;
  final TextSpeed speed;
  final VoidCallback? onComplete;

  const TypewriterWidget({
    super.key,
    required this.text,
    this.style,
    this.charsPerSecondSlow = 20,
    this.charsPerSecondNormal = 40,
    this.charsPerSecondFast = 80,
    this.speed = TextSpeed.normal,
    this.onComplete,
  });

  @override
  State<TypewriterWidget> createState() => TypewriterWidgetState();
}

class TypewriterWidgetState extends State<TypewriterWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  final JamoDecomposer _jamo = JamoDecomposer();

  late List<_CharEntry> _charEntries;
  int _totalSteps = 0;
  bool _isComplete = false;

  bool get isAnimating => _controller.isAnimating;

  @override
  void initState() {
    super.initState();
    _buildCharEntries();
    _setupAnimation();
  }

  @override
  void didUpdateWidget(TypewriterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || oldWidget.speed != widget.speed) {
      _controller.dispose();
      _isComplete = false;
      _buildCharEntries();
      _setupAnimation();
    }
  }

  void _buildCharEntries() {
    _charEntries = [];
    _totalSteps = 0;

    final runes = widget.text.runes.toList();
    for (final rune in runes) {
      final char = String.fromCharCode(rune);
      final steps = _jamo.decompose(char);
      _charEntries.add(_CharEntry(
        finalChar: char,
        jamoSteps: steps,
        startStep: _totalSteps,
      ));
      _totalSteps += steps.length;
    }
  }

  void _setupAnimation() {
    if (widget.text.isEmpty || widget.speed == TextSpeed.instant) {
      _controller = AnimationController(
        vsync: this,
        duration: Duration.zero,
      );
      _isComplete = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onComplete?.call();
      });
      return;
    }

    final cps = _charsPerSecond;
    final durationMs = (_totalSteps / cps * 1000).round();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: durationMs),
    )..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && !_isComplete) {
          _isComplete = true;
          widget.onComplete?.call();
        }
      });

    _controller.forward();
  }

  int get _charsPerSecond => switch (widget.speed) {
        TextSpeed.slow => widget.charsPerSecondSlow,
        TextSpeed.normal => widget.charsPerSecondNormal,
        TextSpeed.fast => widget.charsPerSecondFast,
        TextSpeed.instant => 1,
      };

  void skipToEnd() {
    if (_isComplete) return;
    _controller.stop();
    _isComplete = true;
    setState(() {});
    widget.onComplete?.call();
  }

  String _buildVisibleText() {
    if (_isComplete || widget.speed == TextSpeed.instant) {
      return widget.text;
    }

    if (_totalSteps == 0) return '';

    final progress = _controller.value;
    final currentStep = (progress * _totalSteps).floor();

    final buffer = StringBuffer();
    for (final entry in _charEntries) {
      final stepsIntoChar = currentStep - entry.startStep;
      if (stepsIntoChar < 0) break;

      if (entry.jamoSteps.isEmpty) continue;
      final stepIndex = stepsIntoChar.clamp(0, entry.jamoSteps.length - 1);
      buffer.write(entry.jamoSteps[stepIndex]);
    }

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final visibleText = _buildVisibleText();
    // baseStyle.fontSize는 비스케일 기준값이어야 함 (예: 16).
    // 이미 스케일된 값을 전달하면 이중 스케일링 발생에 주의.
    final baseStyle = widget.style ?? Theme.of(context).textTheme.bodyLarge ?? const TextStyle();
    final scaledFontSize = ResponsiveScale.scaleFontSize(
      context,
      baseStyle.fontSize ?? 13,
    );
    final style = baseStyle.copyWith(
      fontSize: scaledFontSize,
      height: 1.6,
    );
    return RichText(
      text: TextSpan(
        text: visibleText,
        style: style,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _CharEntry {
  final String finalChar;
  final List<String> jamoSteps;
  final int startStep;

  const _CharEntry({
    required this.finalChar,
    required this.jamoSteps,
    required this.startStep,
  });
}
