import 'package:flutter/foundation.dart';
import 'package:soul_dungeon/core/app_branding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:soul_dungeon/audio/bloc/audio_bloc.dart';
import 'package:soul_dungeon/audio/engine/soloud_sound_layer_manager.dart';
import 'package:soul_dungeon/audio/engine/sound_layer_manager.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/core/save/save_data.dart';
import 'package:soul_dungeon/core/save/save_manager.dart';
import 'package:soul_dungeon/domain/dungeon/generator/dungeon_generator.dart';
import 'package:soul_dungeon/domain/momentum/bloc/momentum_bloc.dart';
import 'package:soul_dungeon/domain/narrative/bloc/narrator_bloc.dart';
import 'package:soul_dungeon/domain/progression/bloc/progression_bloc.dart';
import 'package:soul_dungeon/domain/progression/bloc/progression_state.dart';
import 'package:soul_dungeon/presentation/screens/game/game_screen.dart';
import 'package:soul_dungeon/presentation/screens/job_codex/job_codex_screen.dart';
import 'package:soul_dungeon/presentation/screens/bestiary/bestiary_screen.dart';
import 'package:soul_dungeon/presentation/screens/starter/starter_select_screen.dart';
import 'package:soul_dungeon/presentation/screens/settings/settings_screen.dart';
import 'package:soul_dungeon/presentation/screens/soul_shop/soul_shop_screen.dart';
import 'package:soul_dungeon/presentation/screens/title/title_screen.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/widgets/effects/retro_window_frame.dart';

class SoulDungeonApp extends StatefulWidget {
  final BalanceConfig balanceConfig;
  final GameEventBus? gameEventBus;
  final SaveManager? saveManager;
  final MetaSaveData? initialMeta;
  final RunSaveData? initialRun;
  /// 오디오 엔진. 미지정 시 SoLoud 사용. 테스트에서 NoOp 주입 가능.
  final SoundLayerManager? soundManager;

  /// 테스트 전용: 초기 경로 지정 (기본 '/').
  final String initialRoute;

  /// 저장된 SFX 뮤트 상태 (SharedPreferences에서 복원).
  final bool initialSfxMuted;

  /// 저장된 Music 뮤트 상태 (SharedPreferences에서 복원).
  final bool initialMusicMuted;

  const SoulDungeonApp({
    super.key,
    required this.balanceConfig,
    this.gameEventBus,
    this.saveManager,
    this.initialMeta,
    this.initialRun,
    this.soundManager,
    this.initialRoute = '/',
    this.initialSfxMuted = false,
    this.initialMusicMuted = false,
  });

  @override
  State<SoulDungeonApp> createState() => _SoulDungeonAppState();
}

class _SoulDungeonAppState extends State<SoulDungeonApp> {
  late final GameEventBus _eventBus;
  late final GoRouter _router;
  late final MomentumBloc _momentumBloc;
  late final ProgressionBloc _progressionBloc;
  late final DungeonGenerator _dungeonGenerator;
  late final NarratorBloc _narratorBloc;
  late final AudioBloc _audioBloc;

  /// 외부 주입 여부 — dispose 시 외부 소유 인스턴스는 해제하지 않음.
  late final bool _ownsEventBus;

  /// 현재 런 세이브 — 퍼마데스/새 게임 시 null로 클리어.
  /// widget.initialRun은 final이므로 mutable 복사본 유지.
  RunSaveData? _currentRun;

  @override
  void initState() {
    super.initState();

    _currentRun = widget.initialRun;
    _ownsEventBus = widget.gameEventBus == null;
    _eventBus = widget.gameEventBus ?? GameEventBus();

    _momentumBloc = MomentumBloc(
      gameEventBus: _eventBus,
      config: widget.balanceConfig.momentum,
    );

    _dungeonGenerator = DungeonGenerator(
      config: widget.balanceConfig.dungeon,
      floorsConfig: widget.balanceConfig.floors,
      gameEventBus: _eventBus,
      tutorialConfig: widget.balanceConfig.tutorial,
    );

    _narratorBloc = NarratorBloc(gameEventBus: _eventBus);

    _audioBloc = AudioBloc(
      soundManager: widget.soundManager ?? SoLoudSoundLayerManager(),
      eventBus: _eventBus,
      config: widget.balanceConfig.audio,
      initialSfxMuted: widget.initialSfxMuted,
      initialMusicMuted: widget.initialMusicMuted,
    );
    _audioBloc.add(const InitializeAudio());

    _progressionBloc = ProgressionBloc(
      gameEventBus: _eventBus,
      saveManager: widget.saveManager,
      economyConfig: widget.balanceConfig.economy,
    );
    if (widget.initialMeta != null) {
      _progressionBloc.initialize(widget.initialMeta!);
    } else {
      _progressionBloc.initialize(const MetaSaveData());
    }

    _router = GoRouter(
      initialLocation: widget.initialRoute,
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => _MobileFrame(
            child: TitleScreen(
              hasSaveData: _currentRun != null,
              onNewGame: () async {
                if (_currentRun != null) {
                  final confirmed = await showDialog<bool>(
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
                        title: '세이브 덮어쓰기',
                        borderColor: const Color(0xFFFF6B6B),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                '기존 진행 데이터가 삭제됩니다.\n새 게임을 시작하시겠습니까?',
                                style: TextStyle(
                                  color: Color(0xFFB0B0B0),
                                  fontSize: 14,
                                  fontFamily: 'monospace',
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () =>
                                          Navigator.of(ctx).pop(false),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: const Color(0xFF555555),
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        alignment: Alignment.center,
                                        child: const Text(
                                          '돌아가기',
                                          style: TextStyle(
                                            color: Color(0xFFB0B0B0),
                                            fontSize: 13,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () =>
                                          Navigator.of(ctx).pop(true),
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
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        alignment: Alignment.center,
                                        child: const Text(
                                          '새 게임 시작',
                                          style: TextStyle(
                                            color: Color(0xFFFF6B6B),
                                            fontSize: 13,
                                            fontFamily: 'monospace',
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
                  );
                  if (confirmed != true || !context.mounted) return;
                }
                // 새 게임 시 기존 런 세이브 삭제
                await widget.saveManager?.deleteRun();
                _currentRun = null;
                if (!context.mounted) return;
                context.go('/starter');
              },
              onContinue: () => context.go('/game?continue=true'),
              onSoulShop: () => context.go('/bestiary'), // 도감(Bestiary)
              onJobCodex: () => context.go('/job-codex'),
              onSettings: () => context.go('/settings'),
            ),
          ),
        ),
        GoRoute(
          path: '/starter',
          builder: (context, state) => _MobileFrame(
            child: StarterSelectScreen(
              onSelect: (monsterId) => context.go('/game?starter=$monsterId'),
              onBack: () => context.go('/'),
            ),
          ),
        ),
        GoRoute(
          path: '/game',
          builder: (context, state) {
            final isContinue =
                state.uri.queryParameters['continue'] == 'true';
            final starterMonsterId = state.uri.queryParameters['starter'];
            final initialRunState = isContinue
                ? _currentRun?.playerRunState
                : null;
            final initialCombatStateRaw = isContinue
                ? _currentRun?.cardCombatStateRaw
                : null;

            // ProgressionBloc에서 최신 MetaSaveData 조회 (소울상점 즉시 반영)
            final currentMeta = switch (_progressionBloc.state) {
              ProgressionLoaded(:final meta) => meta,
              _ => widget.initialMeta,
            };

            return _MobileFrame(
              child: GameScreen(
                gameEventBus: _eventBus,
                dungeonGenerator: _dungeonGenerator,
                charsPerSecondSlow:
                    widget.balanceConfig.text.charsPerSecondSlow,
                charsPerSecondNormal:
                    widget.balanceConfig.text.charsPerSecondNormal,
                charsPerSecondFast:
                    widget.balanceConfig.text.charsPerSecondFast,
                momentumConfig: widget.balanceConfig.momentum,
                combatConfig: widget.balanceConfig.combat,
                economyConfig: widget.balanceConfig.economy,
                dungeonConfig: widget.balanceConfig.dungeon,
                mysteryConfig: widget.balanceConfig.mystery,
                npcConfig: widget.balanceConfig.npc,
                restConfig: widget.balanceConfig.rest,
                eventConfig: widget.balanceConfig.event,
                dispositionConfig: widget.balanceConfig.disposition,
                buildConfig: widget.balanceConfig.build,
                prepConfig: widget.balanceConfig.prep,
                rarityConfig: widget.balanceConfig.rarity,
                saveManager: widget.saveManager,
                narratorBloc: _narratorBloc,
                initialMeta: currentMeta,
                audioConfig: widget.balanceConfig.audio,
                fleeConfig: widget.balanceConfig.flee,
                cardCombatConfig: widget.balanceConfig.cardCombat,
                chainBonusConfig: widget.balanceConfig.chainBonus,
                floorsConfig: widget.balanceConfig.floors,
                initialRunState: initialRunState,
                initialCombatStateRaw: initialCombatStateRaw,
                starterMonsterId: starterMonsterId,
                onRunDeleted: () => _currentRun = null,
              ),
            );
          },
        ),
        GoRoute(
          path: '/bestiary',
          builder: (context, state) => _MobileFrame(
            child: BestiaryScreen(
              onBack: () => context.go('/'),
            ),
          ),
        ),
        GoRoute(
          path: '/job-codex',
          builder: (context, state) => _MobileFrame(
            child: JobCodexScreen(
              onBack: () => context.go('/'),
            ),
          ),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => _MobileFrame(
            child: SettingsScreen(
              onBack: () => context.go('/'),
              onResetComplete: () => context.go('/'),
            ),
          ),
        ),
        GoRoute(
          path: '/soul-shop',
          builder: (context, state) => _MobileFrame(
            child: SoulShopScreen(
              onBack: () => context.go('/'),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _router.dispose();
    _audioBloc.close();
    _narratorBloc.close();
    _progressionBloc.close();
    _momentumBloc.close();
    if (_ownsEventBus) {
      _eventBus.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MomentumBloc>.value(value: _momentumBloc),
        BlocProvider<ProgressionBloc>.value(value: _progressionBloc),
        BlocProvider<AudioBloc>.value(value: _audioBloc),
      ],
      child: MaterialApp.router(
        title: AppBranding.title,
        theme: AppTheme.dark,
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
        builder: (context, child) {
          // 시스템 글자 크기/화면 배율 설정이 앱 레이아웃을 깨뜨리지 않도록
          // textScaler를 0.8~1.2 범위로 clamp.
          final mediaQuery = MediaQuery.of(context);
          final clampedScale = mediaQuery.textScaler
              .clamp(minScaleFactor: 0.8, maxScaleFactor: 1.2);
          return MediaQuery(
            data: mediaQuery.copyWith(textScaler: clampedScale),
            child: child!,
          );
        },
      ),
    );
  }
}

/// 웹에서 모바일 비율로 표시하는 프레임.
/// 모바일(iOS/Android)에서는 전체 화면 그대로.
class _MobileFrame extends StatelessWidget {
  final Widget child;

  const _MobileFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return child;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 390,
            maxHeight: 844,
          ),
          child: child,
        ),
      ),
    );
  }
}
