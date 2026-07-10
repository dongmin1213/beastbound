import 'package:flutter/material.dart';

import 'package:soul_dungeon/core/models/game_enums.dart';

import 'responsive_scale.dart';

class AppTheme {
  AppTheme._();

  /// 테스트에서 flutter_animate의 Timer 문제를 방지하기 위해
  /// 모든 flutter_animate 기반 애니메이션을 비활성화할 수 있는 글로벌 플래그.
  static bool enableAnimations = true;

  // ── Spacing grid (8px base) ──
  static const spacingXs = 4.0;
  static const spacingSm = 8.0;
  static const spacingMd = 16.0;
  static const spacingLg = 24.0;
  static const spacingXl = 32.0;

  // ── Screen background ──
  static const screenBackground = Color(0xFF0A0A14);

  // ── Card type colors ──
  static const cardAttackColor = Color(0xFFE53935);
  static const cardSkillColor = Color(0xFF66BB6A);
  static const cardPowerColor = Color(0xFFAB47BC);

  static Color cardTypeColor(CardType type) => switch (type) {
        CardType.attack => cardAttackColor,
        CardType.skill => cardSkillColor,
        CardType.power => cardPowerColor,
      };

  // ── Card surface ──
  static const cardBackground = Color(0xFF12122A);
  static const cardBorderDefault = Color(0xFF444444);

  // ── Card premium styling ──
  static const cardEffectPanelBg = Color(0x80000000);
  static const cardUpgradedBorder = Color(0xFFFFD54F);
  static const cardNameShadowColor = Color(0x80000000);

  /// 카드 타입별 그라디언트 상단색 (배경 그라디언트용)
  static Color cardGradientTop(CardType type) => switch (type) {
        CardType.attack => const Color(0xFF2A1830),
        CardType.skill => const Color(0xFF183028),
        CardType.power => const Color(0xFF261840),
      };

  /// 카드 타입별 워터마크 아이콘
  static IconData cardWatermarkIcon(CardType type) => switch (type) {
        CardType.attack => Icons.bolt,
        CardType.skill => Icons.shield_outlined,
        CardType.power => Icons.auto_awesome,
      };

  // ── AP indicator ──
  static const apAvailable = Color(0xFFFFD54F);
  static const apEmpty = Color(0xFF555555);
  static const apInsufficient = Color(0xFFE53935);

  // ── Gauge bar ──
  static const gaugeHp = Color(0xFFE53935);
  static const gaugeHpSafe = Color(0xFFE0E0E0);
  static const gaugeHpBg = Color(0xFF2A2A2A);
  static const gaugeEnemy = Color(0xFFFF7043);
  static const gaugeBlock = Color(0xFF42A5F5);

  // ── Text color coding (combat narration) ──
  static const textDamage = Color(0xFFEF5350);
  static const textHeal = Color(0xFF66BB6A);
  static const textBlock = Color(0xFF42A5F5);
  static const textStatusDebuff = Color(0xFFFF7043);
  static const textStatusBuff = Color(0xFF66BB6A);
  static const textStatusDot = Color(0xFFEF5350);

  // ── Turn divider ──
  static const turnDividerColor = Color(0xFF8D6E63);

  // ── Title screen ──
  static const titleGold = Color(0xFFFFD54F);
  static const titleSubtext = Color(0xFF888888);
  static const titleMenuText = Color(0xFFC8C8C8);
  static const titleMenuDisabled = Color(0xFF555555);

  // Choice card styling (비전투 선택지 — 기존 유지)
  static const choiceCardBackground = Color(0xFF1A1A2E);
  static const choiceCardBorder = Color(0xFF333333);
  static const choiceCardText = Color(0xFFE0E0E0);
  static const choiceSelectedBackground = Color(0xFF1A2A4E);
  static const choiceSelectedBorder = Color(0xFF4A90D9);
  static const choiceDisabledOpacity = 0.3;
  static const choiceHistoryAccent = Color(0xFF4A90D9);
  static const choiceCardFontSize = 14.0;

  // Choice style — caution / reward 위계
  static const choiceCautionBar = Color(0xFFE53935);
  static const choiceCautionGlow = Color(0x1AE53935);
  static const choiceRewardBar = Color(0xFFFFD54F);
  static const choiceRewardText = Color(0xFFFFD54F);

  // Room atmosphere — 탐색/전투 배경색 전환
  static const explorationBackground = Color(0xFF0E0E18);
  static const combatBackground = Color(0xFF0A0A14);

  // Combat preview styling
  static const combatPreviewAttackColor = Color(0xFFE53935);
  static const combatPreviewDefendColor = Color(0xFF42A5F5);
  static const combatPreviewObserveColor = Color(0xFFFFB300);
  static const combatPreviewBackground = Color(0xFF1A1A1A);

  // Combat result styling (등급별 색상)
  static const combatResultEffectiveColor = Color(0xFF66BB6A);
  static const combatResultNeutralColor = Color(0xFFE0E0E0);
  static const combatResultIneffectiveColor = Color(0xFFEF5350);

  // Combat outcome styling (전투 결과)
  static const combatVictoryColor = Color(0xFFFFD54F);
  static const combatDefeatColor = Color(0xFFE53935);
  static const chainBonusColor = Color(0xFFFF9800);

  // Momentum gauge styling
  static const momentumLowColor = Color(0xFF37474F);
  static const momentumMediumColor = Color(0xFF1976D2);
  static const momentumHighColor = Color(0xFF00BCD4);
  static const momentumGainColor = Color(0xFF66BB6A);
  static const momentumLossColor = Color(0xFFEF5350);
  static const momentumPenaltyReasonColor = Color(0xFFEF5350);
  static const momentumGaugeBg = Color(0xFF212121);

  // Combat action buttons (턴 종료 / 도주 차별화)
  static const combatEndTurnBg = Color(0xFF1A2A3E);
  static const combatEndTurnBorder = Color(0xFF4A7AAA);
  static const combatEndTurnText = Color(0xFFE0E0E0);
  static const combatFleeBg = Color(0xFF2A1A1A);
  static const combatFleeBorder = Color(0xFF8B5533);
  static const combatFleeText = Color(0xFF999999);

  // Choice normal button styling (준비/갈림길 선택지 버튼화)
  static const choiceNormalBg = Color(0xFF14142A);
  static const choiceNormalBorder = Color(0xFF3A3A5A);

  // Tier effect styling (기세 단계별 행동 효과)
  static const tierEffectEnhancedColor = Color(0xFF00E676);
  static const tierEffectDiminishedColor = Color(0xFFFF7043);

  // Environment narration styling (환경 서술)
  static const environmentClueColor = Color(0xFF4FC3F7);
  static const environmentBorderColor = Color(0xFF0288D1);

  // Momentum gauge threshold marker
  static const momentumThresholdMarkerColor = Color(0x4DFFFFFF);

  // Minimap styling (미니맵 "모험가의 메모")
  static const minimapCurrentColor = Color(0xFFFFD54F);
  static const minimapVisitedColor = Color(0xFF666666);
  static const minimapAvailableColor = Color(0xFFE0E0E0);
  static const minimapLockedColor = Color(0xFF5A5A5A);
  static const minimapBorderColor = Color(0xFF555555);
  static const minimapBackgroundColor = Color(0xFF0D0D0D);
  static const minimapTitleColor = Color(0xFFB0B0B0);
  static const minimapConnectionColor = Color(0xFF888888);
  static const minimapToggleColor = Color(0xFFB0B0B0);

  // Minimap elite styling (엘리트 경고색)
  static const minimapEliteAvailableColor = Color(0xFFFF6B6B);
  static const minimapEliteCurrentColor = Color(0xFFFF8A65);

  // Shop styling (상점 "여행자의 상점")
  static const shopGoldColor = Color(0xFFFFD54F);
  static const shopItemCardBackground = Color(0xFF1A1A2E);
  static const shopItemCardBorder = Color(0xFF333333);
  static const shopSoldOverlay = Color(0x80000000);
  static const shopRarityCommonColor = Color(0xFFB0B0B0);
  static const shopRarityRareColor = Color(0xFF42A5F5);
  static const shopRarityLegendaryColor = Color(0xFFFFD54F);
  static const shopRarityCursedColor = Color(0xFF9C27B0); // E4 악마의 거래
  static const shopBuyButtonColor = Color(0xFF2A4A2A);

  // NPC styling (NPC 방)
  static const npcFrameColor = Color(0xFF2E7D32);
  static const npcTraderColor = Color(0xFFFFB300);
  static const npcSageColor = Color(0xFF64B5F6);
  static const npcWandererColor = Color(0xFFA5D6A7);
  static const npcDialogueColor = Color(0xFFE0E0E0);
  // NPC alias — 상점 테마 재사용 (시각적 일관성)
  static const npcButtonColor = shopItemCardBorder;
  static const npcItemCardBackground = Colors.transparent;
  static const npcGoldColor = shopGoldColor;
  static const npcBuyButtonColor = shopBuyButtonColor;

  // Rest styling (휴식 방 "휴식의 방")
  static const restFrameColor = Color(0xFF2E7D32);
  static const restRecoveryColor = Color(0xFF66BB6A);
  static const restUpgradeColor = Color(0xFF42A5F5);
  static const restCardBackground = Color(0xFF1A1A2E);
  static const restDisabledColor = Color(0xFF666666);

  // Memory styling (기억 조각)
  static const memoryColor = Color(0xFFCE93D8);

  // Mystery styling (미스터리 방 "??? 미스터리 방")
  static const mysteryFrameColor = Color(0xFF6A1B9A);
  static const mysteryTreasureColor = Color(0xFFFFD54F);
  static const mysteryTrapColor = Color(0xFFEF5350);
  static const mysteryEncounterColor = Color(0xFFFF8A65);
  static const mysteryRewardColor = Color(0xFF66BB6A);
  static const mysteryCardBackground = Color(0xFF1A1A2E);
  static const mysteryButtonColor = Color(0xFF333333);

  // Event styling (이벤트 방 "이벤트")
  static const eventFrameColor = Color(0xFFFF8F00);
  static const eventCardBackground = Color(0xFF1A1A2E);
  static const eventButtonColor = Color(0xFF4A3A1A);

  // --- Responsive scaling methods ---

  /// 화면 크기에 비례하는 본문 텍스트 스타일 (large).
  static TextStyle scaledBodyLarge(BuildContext context) {
    return TextStyle(
      fontSize: ResponsiveScale.scaleFontSize(context, 14),
      height: 1.5,
      color: const Color(0xFFE0E0E0),
    );
  }

  /// 화면 크기에 비례하는 본문 텍스트 스타일 (medium).
  static TextStyle scaledBodyMedium(BuildContext context) {
    return TextStyle(
      fontSize: ResponsiveScale.scaleFontSize(context, 13),
      height: 1.4,
      color: const Color(0xFFB0B0B0),
    );
  }

  /// 화면 크기에 비례하는 선택지 텍스트 스타일.
  static TextStyle scaledChoiceText(BuildContext context) {
    return TextStyle(
      fontSize: ResponsiveScale.scaleFontSize(context, choiceCardFontSize),
      color: choiceCardText,
    );
  }

  /// 화면 크기에 비례하는 메인 화면 패딩.
  static EdgeInsets scaledScreenPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: ResponsiveScale.scalePadding(context, 20),
      vertical: ResponsiveScale.scaleVerticalPadding(context, 16),
    );
  }

  /// 화면 크기에 비례하는 블록 간 간격.
  static double scaledBlockSpacing(BuildContext context) {
    return ResponsiveScale.scaleVerticalPadding(context, 16);
  }

  static final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: screenBackground,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFB0B0B0),
      surface: Color(0xFF121212),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        fontFamily: 'NotoSansKR',
        color: Color(0xFFE0E0E0),
        fontSize: 13,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'NotoSansKR',
        color: Color(0xFFB0B0B0),
        fontSize: 13,
        height: 1.4,
      ),
    ),
  );
}
