import 'package:flutter/material.dart';
import 'package:soul_dungeon/core/models/job_path.dart';
import 'package:soul_dungeon/core/models/disposition_axis.dart';
import 'package:soul_dungeon/presentation/theme/pixel_art_assets.dart';

/// Tier 2 직업용 프로그래밍 생성 아이콘.
///
/// 상위직: 기반 1차 직업 스프라이트 + 금색 틴트 + 금색 테두리.
/// 조합직: 주축 1차 직업 스프라이트 + 이중색 테두리.
class ProgrammaticJobIcon extends StatelessWidget {
  final JobPath job;
  final double size;

  const ProgrammaticJobIcon({
    super.key,
    required this.job,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    final basePath = _resolveBaseSprite();
    if (basePath == null) return _fallbackIcon();

    if (job.isAdvanced) return _buildAdvancedIcon(basePath);
    if (job.isCombination) return _buildCombinationIcon(basePath);
    return _fallbackIcon();
  }

  /// 상위직 — 금색 테두리 + 금색 틴트.
  Widget _buildAdvancedIcon(String basePath) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // 금색 틴트 적용된 기반 스프라이트
          ColorFiltered(
            colorFilter: const ColorFilter.mode(
              Color(0x30FFD54F),
              BlendMode.srcATop,
            ),
            child: Image.asset(
              basePath,
              width: size,
              height: size,
              filterQuality: FilterQuality.none,
            ),
          ),
          // 금색 테두리
          CustomPaint(
            size: Size(size, size),
            painter: _JobIconBorderPainter(
              primaryColor: const Color(0xFFFFD54F),
            ),
          ),
        ],
      ),
    );
  }

  /// 조합직 — 이중색 테두리 + 부축 색상 틴트.
  Widget _buildCombinationIcon(String basePath) {
    final axes = job.requiredAxes;
    if (axes == null) return _fallbackIcon();

    final primaryColor = _axisColor(axes.primary);
    final secondaryColor = _axisColor(axes.secondary);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // 부축 색상 틴트 적용된 기반 스프라이트
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              secondaryColor.withValues(alpha: 0.2),
              BlendMode.srcATop,
            ),
            child: Image.asset(
              basePath,
              width: size,
              height: size,
              filterQuality: FilterQuality.none,
            ),
          ),
          // 이중색 테두리 (좌: 주축, 우: 부축)
          CustomPaint(
            size: Size(size, size),
            painter: _JobIconBorderPainter(
              primaryColor: primaryColor,
              secondaryColor: secondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallbackIcon() {
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Text(
          '\u2713',
          style: TextStyle(
            color: const Color(0xFF4CAF50),
            fontSize: size * 0.6,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }

  /// Tier 2 직업의 기반 1차 직업 스프라이트 경로 해석.
  String? _resolveBaseSprite() {
    // 상위직 — requiredPrimaryJobId 직접 참조
    if (job.isAdvanced && job.requiredPrimaryJobId != null) {
      return PixelArtAssets.jobSprite(job.requiredPrimaryJobId!);
    }
    // 조합직 — 주축에서 1차 직업 추론
    if (job.isCombination && job.requiredAxes != null) {
      final baseId = _axisToBaseJobId(job.requiredAxes!.primary);
      if (baseId != null) return PixelArtAssets.jobSprite(baseId);
    }
    return null;
  }

  /// 성향 축 → 대표 1차 직업 ID 매핑.
  static String? _axisToBaseJobId(DispositionAxis axis) {
    return switch (axis) {
      DispositionAxis.struggle => 'warrior',
      DispositionAxis.mercy => 'saint',
      DispositionAxis.wisdom => 'sage',
      DispositionAxis.shadow => 'assassin',
      DispositionAxis.will => 'guardian',
      DispositionAxis.harmony => 'wanderer',
    };
  }

  /// 성향 축 → 대표 색상.
  static Color _axisColor(DispositionAxis axis) {
    return switch (axis) {
      DispositionAxis.struggle => const Color(0xFFE53935),
      DispositionAxis.mercy => const Color(0xFF66BB6A),
      DispositionAxis.wisdom => const Color(0xFF42A5F5),
      DispositionAxis.shadow => const Color(0xFF9C27B0),
      DispositionAxis.will => const Color(0xFFFF8F00),
      DispositionAxis.harmony => const Color(0xFF00BCD4),
    };
  }
}

/// 직업 아이콘 테두리 페인터.
///
/// [secondaryColor]가 null이면 단색 (상위직 금색) 테두리,
/// 있으면 좌/우 이중색 (조합직) 테두리.
class _JobIconBorderPainter extends CustomPainter {
  final Color primaryColor;
  final Color? secondaryColor;

  _JobIconBorderPainter({
    required this.primaryColor,
    this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final borderWidth = 2.0;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    if (secondaryColor == null) {
      // 단색 테두리 (상위직)
      final paint = Paint()
        ..color = primaryColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth;
      canvas.drawRect(rect.deflate(borderWidth / 2), paint);
    } else {
      // 이중색 테두리 (조합직) — 좌측=주축, 우측=부축
      final half = size.width / 2;
      final primaryPaint = Paint()
        ..color = primaryColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth;
      final secondaryPaint = Paint()
        ..color = secondaryColor!
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth;

      final inset = borderWidth / 2;

      // 상단
      canvas.drawLine(
        Offset(inset, inset),
        Offset(half, inset),
        primaryPaint,
      );
      canvas.drawLine(
        Offset(half, inset),
        Offset(size.width - inset, inset),
        secondaryPaint,
      );

      // 하단
      canvas.drawLine(
        Offset(inset, size.height - inset),
        Offset(half, size.height - inset),
        primaryPaint,
      );
      canvas.drawLine(
        Offset(half, size.height - inset),
        Offset(size.width - inset, size.height - inset),
        secondaryPaint,
      );

      // 좌측
      canvas.drawLine(
        Offset(inset, inset),
        Offset(inset, size.height - inset),
        primaryPaint,
      );

      // 우측
      canvas.drawLine(
        Offset(size.width - inset, inset),
        Offset(size.width - inset, size.height - inset),
        secondaryPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_JobIconBorderPainter oldDelegate) =>
      oldDelegate.primaryColor != primaryColor ||
      oldDelegate.secondaryColor != secondaryColor;
}
