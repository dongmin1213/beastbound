import 'package:flutter/material.dart';
import 'package:soul_dungeon/l10n/app_localizations.dart';
import 'package:soul_dungeon/core/config/locale_controller.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soul_dungeon/audio/bloc/audio_bloc.dart';
import 'package:soul_dungeon/domain/progression/bloc/progression_bloc.dart';
import 'package:soul_dungeon/domain/progression/bloc/progression_event.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/theme/responsive_scale.dart';
import 'package:soul_dungeon/presentation/widgets/effects/retro_window_frame.dart';

/// 설정 화면 — BGM/SFX 볼륨 개별 조절 + 완전 초기화.
class SettingsScreen extends StatelessWidget {
  final VoidCallback onBack;

  /// 완전 초기화 완료 후 콜백 (타이틀 복귀 등).
  final VoidCallback? onResetComplete;

  const SettingsScreen({
    super.key,
    required this.onBack,
    this.onResetComplete,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) onBack();
      },
      child: Theme(
        data: AppTheme.dark,
        child: Scaffold(
          backgroundColor: AppTheme.screenBackground,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 24,
              ),
              child: RetroWindowFrame(
                title: '\u2699 설정',
                borderColor: AppTheme.titleGold,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: BlocListener<AudioBloc, AudioState>(
                listener: (context, audioState) async {
                  if (audioState is! AudioReady) return;
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setDouble('sfx_volume', audioState.sfxVolume);
                  await prefs.setDouble(
                    'music_volume',
                    audioState.musicVolume,
                  );
                  await prefs.setBool('sfx_muted', audioState.sfxMuted);
                  await prefs.setBool('music_muted', audioState.musicMuted);
                },
                child: BlocBuilder<AudioBloc, AudioState>(
                    builder: (context, audioState) {
                      if (audioState is! AudioReady) {
                        return Text(
                          '오디오 초기화 중...',
                          style: TextStyle(
                            color: const Color(0xFF888888),
                            fontSize:
                                ResponsiveScale.scaleFontSize(context, 13),
                            fontFamily: 'Galmuri11',
                          ),
                        );
                      }

                      final audioBloc = context.read<AudioBloc>();

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildSectionHeader(context, '사운드'),
                          const SizedBox(height: 16),
                          _buildVolumeSlider(
                            context: context,
                            label: '배경음악',
                            value: audioState.musicVolume,
                            muted: audioState.musicMuted,
                            onChanged: (v) =>
                                audioBloc.add(SetMusicVolume(v)),
                            onToggleMute: () =>
                                audioBloc.add(const ToggleMusicMute()),
                          ),
                          const SizedBox(height: 16),
                          _buildVolumeSlider(
                            context: context,
                            label: '효과음',
                            value: audioState.sfxVolume,
                            muted: audioState.sfxMuted,
                            onChanged: (v) =>
                                audioBloc.add(SetSfxVolume(v)),
                            onToggleMute: () =>
                                audioBloc.add(const ToggleSfxMute()),
                          ),
                          const SizedBox(height: 24),
                          _buildSectionHeader(
                              context, AppLocalizations.of(context).settingsLanguage),
                          const SizedBox(height: 16),
                          _buildLanguageToggle(context),
                          const SizedBox(height: 24),
                          _buildSectionHeader(context, '데이터'),
                          const SizedBox(height: 16),
                          _buildResetButton(context),
                          const SizedBox(height: 24),
                          // 닫기 버튼
                          GestureDetector(
                            onTap: onBack,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFF555555),
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '\u25c0 돌아가기',
                                style: TextStyle(
                                  color: const Color(0xFFB0B0B0),
                                  fontSize: ResponsiveScale.scaleFontSize(
                                    context,
                                    13,
                                  ),
                                  fontFamily: 'Galmuri11',
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageToggle(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final active = Localizations.localeOf(context).languageCode;

    Widget btn(String label, Locale locale) {
      final selected = active == locale.languageCode;
      return Expanded(
        child: GestureDetector(
          onTap: () => LocaleController.instance.setLocale(locale),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: selected
                  ? AppTheme.titleGold.withValues(alpha: 0.18)
                  : null,
              border: Border.all(
                color: selected ? AppTheme.titleGold : const Color(0xFF555555),
                width: selected ? 1.5 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                color: selected ? AppTheme.titleGold : const Color(0xFFB0B0B0),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        btn(l10n.languageKorean, const Locale('ko')),
        btn(l10n.languageEnglish, const Locale('en')),
      ],
    );
  }

  Widget _buildResetButton(BuildContext context) {
    final fontSize = ResponsiveScale.scaleFontSize(context, 13);
    final smallFontSize = ResponsiveScale.scaleFontSize(context, 11);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '소울, 업그레이드, 해금 등 모든 진행 데이터를\n초기화합니다. 되돌릴 수 없습니다.',
          style: TextStyle(
            color: const Color(0xFF888888),
            fontSize: smallFontSize,
            fontFamily: 'Galmuri11',
            height: 1.4,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showResetConfirmation(context),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFFFF6B6B).withValues(alpha: 0.5),
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: Text(
              '\u26A0 완전 초기화',
              style: TextStyle(
                color: const Color(0xFFFF6B6B),
                fontSize: fontSize,
                fontFamily: 'Galmuri11',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog<bool>(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 40,
          vertical: 24,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: RetroWindowFrame(
            title: '완전 초기화',
            borderColor: const Color(0xFFFF6B6B),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '모든 데이터가 삭제됩니다.\n\n'
                    '\u2022 소울 (전액)\n'
                    '\u2022 소울 업그레이드\n'
                    '\u2022 해금된 카드/직업\n'
                    '\u2022 기억 조각\n'
                    '\u2022 엔딩 기록\n'
                    '\u2022 런 진행 데이터\n\n'
                    '이 작업은 되돌릴 수 없습니다.',
                    style: TextStyle(
                      color: Color(0xFFB0B0B0),
                      fontSize: 13,
                      fontFamily: 'Galmuri11',
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.of(ctx).pop(false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFF555555),
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              '취소',
                              style: TextStyle(
                                color: Color(0xFFB0B0B0),
                                fontSize: 13,
                                fontFamily: 'Galmuri11',
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.of(ctx).pop(true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B6B)
                                  .withValues(alpha: 0.15),
                              border: Border.all(
                                color: const Color(0xFFFF6B6B)
                                    .withValues(alpha: 0.6),
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              '초기화',
                              style: TextStyle(
                                color: Color(0xFFFF6B6B),
                                fontSize: 13,
                                fontFamily: 'Galmuri11',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).then((confirmed) {
      if (confirmed != true || !context.mounted) return;
      _showFinalConfirmation(context);
    });
  }

  void _showFinalConfirmation(BuildContext context) {
    showDialog<bool>(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 40,
          vertical: 24,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: RetroWindowFrame(
            title: '최종 확인',
            borderColor: const Color(0xFFFF6B6B),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '정말로 모든 데이터를 삭제하시겠습니까?\n\n되돌릴 수 없습니다.',
                    style: TextStyle(
                      color: Color(0xFFFF6B6B),
                      fontSize: 14,
                      fontFamily: 'Galmuri11',
                      height: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.of(ctx).pop(false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFF555555),
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              '취소',
                              style: TextStyle(
                                color: Color(0xFFB0B0B0),
                                fontSize: 13,
                                fontFamily: 'Galmuri11',
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.of(ctx).pop(true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B6B)
                                  .withValues(alpha: 0.25),
                              border: Border.all(
                                color: const Color(0xFFFF6B6B),
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              '삭제합니다',
                              style: TextStyle(
                                color: Color(0xFFFF6B6B),
                                fontSize: 13,
                                fontFamily: 'Galmuri11',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).then((confirmed) {
      if (confirmed != true || !context.mounted) return;
      // 완전 초기화 실행
      context.read<ProgressionBloc>().add(const ResetAllProgression());
      // 완료 콜백 (타이틀 복귀)
      if (onResetComplete != null) {
        onResetComplete!();
      } else {
        onBack();
      }
    });
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Container(
      padding: const EdgeInsets.only(bottom: 4),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF444444)),
        ),
      ),
      child: Text(
        '── $title ──',
        style: TextStyle(
          color: AppTheme.titleGold,
          fontSize: ResponsiveScale.scaleFontSize(context, 13),
          fontFamily: 'Galmuri11',
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildVolumeSlider({
    required BuildContext context,
    required String label,
    required double value,
    required bool muted,
    required ValueChanged<double> onChanged,
    required VoidCallback onToggleMute,
  }) {
    final fontSize = ResponsiveScale.scaleFontSize(context, 13);
    final smallFontSize = ResponsiveScale.scaleFontSize(context, 11);
    final displayPercent = (value * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: muted
                      ? const Color(0xFF666666)
                      : const Color(0xFFE0E0E0),
                  fontSize: fontSize,
                  fontFamily: 'Galmuri11',
                ),
              ),
            ),
            Text(
              muted ? '음소거' : '$displayPercent%',
              style: TextStyle(
                color: muted
                    ? const Color(0xFF666666)
                    : const Color(0xFFB0B0B0),
                fontSize: smallFontSize,
                fontFamily: 'Galmuri11',
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: muted
                      ? const Color(0xFF444444)
                      : AppTheme.titleGold.withValues(alpha: 0.8),
                  inactiveTrackColor: const Color(0xFF333333),
                  thumbColor: muted
                      ? const Color(0xFF666666)
                      : AppTheme.titleGold,
                  overlayColor: AppTheme.titleGold.withValues(alpha: 0.1),
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                  ),
                ),
                child: Slider(
                  value: value,
                  onChanged: muted ? null : onChanged,
                ),
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onToggleMute,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: muted
                        ? const Color(0xFF666666)
                        : const Color(0xFF555555),
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.center,
                child: Text(
                  muted ? '\u2573' : '\u266A',
                  style: TextStyle(
                    color: muted
                        ? const Color(0xFF666666)
                        : const Color(0xFFB0B0B0),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
