import 'package:flutter/material.dart';
import 'package:soul_dungeon/core/config/floor_region.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 층별 파티클 방향.
enum ParticleDirection { down, up, lateral, swirl, random }

/// 층별 파티클 행동 설정.
class ParticleConfig {
  final int maxParticles;
  final double minSpeed;
  final double maxSpeed;
  final double minSize;
  final double maxSize;
  final double minOpacity;
  final double maxOpacity;
  final ParticleDirection direction;

  const ParticleConfig({
    this.maxParticles = 20,
    this.minSpeed = 0.2,
    this.maxSpeed = 0.6,
    this.minSize = 1,
    this.maxSize = 3,
    this.minOpacity = 0.1,
    this.maxOpacity = 0.4,
    this.direction = ParticleDirection.down,
  });
}

/// 층별 프레젠테이션 전용 비주얼 스타일 데이터.
///
/// `FloorTheme` (domain/shared) → 색상 + 파티클 설정 매핑.
/// domain 값 변경 없이 presentation 표시만 담당.
class FloorThemeVisuals {
  final FloorTheme theme;
  final String displayName;
  final Color backgroundColor;
  final Color combatBackground;
  final Color vignetteColor;
  final Color accentColor;
  final Color particlePrimary;
  final Color particleSecondary;
  final ParticleConfig particleConfig;

  /// RetroWindowFrame 등 UI 박스/프레임 내부 배경색 — 층별 톤 반영.
  final Color frameBackground;

  /// 전투 UI 타이틀 바 · 기본 버튼 배경 — 층별 조화색 (기존 0xFF1A1A2E 대체).
  final Color combatUiTint;

  /// 전투 턴 종료 버튼 배경 (층별 조화).
  final Color combatEndTurnBg;

  /// 전투 턴 종료 버튼 테두리 (층별 조화).
  final Color combatEndTurnBorder;

  /// 전투 도주 버튼 배경 (층별 조화).
  final Color combatFleeBg;

  /// 전투 도주 버튼 테두리 (층별 조화).
  final Color combatFleeBorder;

  const FloorThemeVisuals({
    required this.theme,
    required this.displayName,
    required this.backgroundColor,
    required this.combatBackground,
    required this.vignetteColor,
    required this.accentColor,
    required this.particlePrimary,
    required this.particleSecondary,
    required this.particleConfig,
    required this.frameBackground,
    required this.combatUiTint,
    required this.combatEndTurnBg,
    required this.combatEndTurnBorder,
    required this.combatFleeBg,
    required this.combatFleeBorder,
  });

  /// 층 번호 (1~10) → FloorThemeVisuals. 5지역이 각 2층에 걸친다.
  static FloorThemeVisuals fromFloor(int floor) {
    final theme = switch (FloorRegion.of(floor)) {
      1 => FloorTheme.ruins,
      2 => FloorTheme.cavern,
      3 => FloorTheme.prison,
      4 => FloorTheme.sanctuary,
      5 => FloorTheme.abyss,
      _ => FloorTheme.ruins,
    };
    return fromTheme(theme);
  }

  /// FloorTheme enum → FloorThemeVisuals.
  static FloorThemeVisuals fromTheme(FloorTheme theme) {
    return switch (theme) {
      FloorTheme.ruins => _ruins,
      FloorTheme.cavern => _cavern,
      FloorTheme.prison => _prison,
      FloorTheme.sanctuary => _sanctuary,
      FloorTheme.abyss => _abyss,
    };
  }

  // ── 1층: 폐허 — 습하고 이끼 낀 ──

  static const _ruins = FloorThemeVisuals(
    theme: FloorTheme.ruins,
    displayName: '폐허',
    backgroundColor: Color(0xFF0D100E),
    combatBackground: Color(0xFF090C09),
    vignetteColor: Color(0xFF1A3A2A),
    accentColor: Color(0xFF4A7A5A),
    particlePrimary: Color(0xFF3A6A4A),
    particleSecondary: Color(0x802A4A3A),
    frameBackground: Color(0xFF0B120D),
    combatUiTint: Color(0xFF1A2E1E),
    combatEndTurnBg: Color(0xFF1A3E2A),
    combatEndTurnBorder: Color(0xFF4AAA7A),
    combatFleeBg: Color(0xFF1E2A1A),
    combatFleeBorder: Color(0xFF6B8B53),
    particleConfig: ParticleConfig(
      maxParticles: 20,
      minSpeed: 0.3,
      maxSpeed: 0.8,
      minSize: 1,
      maxSize: 2,
      minOpacity: 0.15,
      maxOpacity: 0.35,
      direction: ParticleDirection.down,
    ),
  );

  // ── 2층: 동굴 — 차갑고 메마른 ──

  static const _cavern = FloorThemeVisuals(
    theme: FloorTheme.cavern,
    displayName: '동굴',
    backgroundColor: Color(0xFF0C0E14),
    combatBackground: Color(0xFF08090F),
    vignetteColor: Color(0xFF1A2A3A),
    accentColor: Color(0xFF5A7A9A),
    particlePrimary: Color(0xFF4A6A8A),
    particleSecondary: Color(0x803A5A7A),
    frameBackground: Color(0xFF0A0D16),
    combatUiTint: Color(0xFF1A1A2E),
    combatEndTurnBg: Color(0xFF1A2A3E),
    combatEndTurnBorder: Color(0xFF4A7AAA),
    combatFleeBg: Color(0xFF2A1A1A),
    combatFleeBorder: Color(0xFF8B5533),
    particleConfig: ParticleConfig(
      maxParticles: 15,
      minSpeed: 0.1,
      maxSpeed: 0.3,
      minSize: 1,
      maxSize: 3,
      minOpacity: 0.08,
      maxOpacity: 0.25,
      direction: ParticleDirection.random,
    ),
  );

  // ── 3층: 감옥 — 마나가 흐르는 ──

  static const _prison = FloorThemeVisuals(
    theme: FloorTheme.prison,
    displayName: '감옥',
    backgroundColor: Color(0xFF0F0D16),
    combatBackground: Color(0xFF0A0912),
    vignetteColor: Color(0xFF2A1A3A),
    accentColor: Color(0xFF7A5A9A),
    particlePrimary: Color(0xFF8A6ABA),
    particleSecondary: Color(0x806A4A9A),
    frameBackground: Color(0xFF0E0B18),
    combatUiTint: Color(0xFF241A2E),
    combatEndTurnBg: Color(0xFF2A1A3E),
    combatEndTurnBorder: Color(0xFF7A4AAA),
    combatFleeBg: Color(0xFF2A1A2A),
    combatFleeBorder: Color(0xFF8B5583),
    particleConfig: ParticleConfig(
      maxParticles: 25,
      minSpeed: 0.4,
      maxSpeed: 1.0,
      minSize: 1,
      maxSize: 2,
      minOpacity: 0.15,
      maxOpacity: 0.5,
      direction: ParticleDirection.up,
    ),
  );

  // ── 4층: 사원 — 뜨겁고 위험한 ──

  static const _sanctuary = FloorThemeVisuals(
    theme: FloorTheme.sanctuary,
    displayName: '사원',
    backgroundColor: Color(0xFF12100D),
    combatBackground: Color(0xFF0D0A08),
    vignetteColor: Color(0xFF3A1A1A),
    accentColor: Color(0xFF9A5A4A),
    particlePrimary: Color(0xFFBA6A3A),
    particleSecondary: Color(0x808A4A2A),
    frameBackground: Color(0xFF14100B),
    combatUiTint: Color(0xFF2E1E1A),
    combatEndTurnBg: Color(0xFF3E2A1A),
    combatEndTurnBorder: Color(0xFFAA7A4A),
    combatFleeBg: Color(0xFF2E1A16),
    combatFleeBorder: Color(0xFF8B5533),
    particleConfig: ParticleConfig(
      maxParticles: 20,
      minSpeed: 0.5,
      maxSpeed: 1.2,
      minSize: 1,
      maxSize: 3,
      minOpacity: 0.15,
      maxOpacity: 0.45,
      direction: ParticleDirection.up,
    ),
  );

  // ── 5층: 심연 — 압도적 어둠 ──

  static const _abyss = FloorThemeVisuals(
    theme: FloorTheme.abyss,
    displayName: '심연',
    backgroundColor: Color(0xFF080810),
    combatBackground: Color(0xFF050508),
    vignetteColor: Color(0xFF1A1A2E),
    accentColor: Color(0xFF6A5A8A),
    particlePrimary: Color(0xFF5A4A7A),
    particleSecondary: Color(0x803A2A5A),
    frameBackground: Color(0xFF090914),
    combatUiTint: Color(0xFF1E1A2E),
    combatEndTurnBg: Color(0xFF241A3E),
    combatEndTurnBorder: Color(0xFF6A5AAA),
    combatFleeBg: Color(0xFF221A24),
    combatFleeBorder: Color(0xFF6B5583),
    particleConfig: ParticleConfig(
      maxParticles: 15,
      minSpeed: 0.2,
      maxSpeed: 0.5,
      minSize: 2,
      maxSize: 4,
      minOpacity: 0.1,
      maxOpacity: 0.35,
      direction: ParticleDirection.swirl,
    ),
  );
}
