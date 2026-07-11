import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soul_dungeon/audio/bloc/audio_event.dart';
import 'package:soul_dungeon/audio/bloc/audio_state.dart';
import 'package:soul_dungeon/audio/engine/bgm_registry.dart';
import 'package:soul_dungeon/audio/engine/sfx_registry.dart';
import 'package:soul_dungeon/audio/engine/sound_layer_manager.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/events/boss_choice_event.dart';
import 'package:soul_dungeon/core/events/card_played_event.dart';
import 'package:soul_dungeon/core/events/chain_bonus_event.dart';
import 'package:soul_dungeon/core/events/combat_ended_event.dart';
import 'package:soul_dungeon/core/events/combat_started_event.dart';
import 'package:soul_dungeon/core/events/dungeon_floor_ready_event.dart';
import 'package:soul_dungeon/core/events/deck_shuffled_event.dart';
import 'package:soul_dungeon/core/events/card_drawn_event.dart';
import 'package:soul_dungeon/core/events/card_exhausted_event.dart';
import 'package:soul_dungeon/core/events/combat_milestone_event.dart';
import 'package:soul_dungeon/core/events/event_choice_event.dart';
import 'package:soul_dungeon/core/events/floor_completed_event.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/core/events/permadeath_event.dart';
import 'package:soul_dungeon/core/events/run_completed_event.dart';
import 'package:soul_dungeon/core/events/gold_gained_event.dart';
import 'package:soul_dungeon/core/events/player_damaged_event.dart';
import 'package:soul_dungeon/core/events/rest_choice_event.dart';
import 'package:soul_dungeon/core/events/room_entered_event.dart';
import 'package:soul_dungeon/core/events/shop_purchase_event.dart';
import 'package:soul_dungeon/core/events/status_effect_applied_event.dart';
import 'package:soul_dungeon/core/events/truth_reveal_event.dart';
import 'package:soul_dungeon/core/logging/game_logger.dart';
import 'package:soul_dungeon/core/events/momentum_changed_event.dart';

export 'audio_event.dart';
export 'audio_state.dart';

/// 오디오 상태를 관리하는 Bloc.
///
/// 생성자 주입: [SoundLayerManager] + [GameEventBus] + [AudioConfig].
/// 크로스도메인 통신은 [GameEventBus]를 통해 수신.
///
/// **SFX 중복 방지:**
/// - 카드 플레이 후 300ms 내 상태효과/드로우/소멸/연쇄 SFX 억제
/// - 동일 SFX ID 100ms 쿨다운
///
/// **Per-layer mute:**
/// - sfxMuted / musicMuted 개별 제어
/// - ToggleMute 시 2개 플래그 동시 토글
///
/// **BGM 시스템:**
/// - CombatStartedEvent → 전투 BGM, CombatEndedEvent → 탐색 BGM
/// - FloorCompletedEvent → 해당 층 탐색 BGM
/// - MomentumChangedEvent L3 진입 시 BGM 재개
class AudioBloc extends Bloc<AudioEvent, AudioState> {
  final SoundLayerManager _soundManager;
  final GameEventBus _eventBus;
  final AudioConfig _config;
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  /// 카드 플레이 시점 기록 (ms). 이후 300ms간 2차 SFX 억제.
  int _lastCardPlayMs = 0;

  /// SFX ID별 마지막 재생 시점 (ms). 100ms 쿨다운 적용.
  final Map<String, int> _sfxCooldowns = {};

  /// 이전 기세 티어 (momentum tier change 감지용).
  String _prevMomentumTier = 'mid';

  /// 현재 재생 중인 BGM ID (중복 재생 방지).
  String? _currentBgmId;

  /// 카드 플레이 이후 2차 SFX 억제 윈도우 (ms).
  static const _cardPlayWindowMs = 300;

  /// 동일 SFX ID 쿨다운 (ms).
  static const _sfxCooldownMs = 100;

  /// 저장된 SFX 뮤트 상태 (SharedPreferences에서 복원).
  final bool _initialSfxMuted;

  /// 저장된 Music 뮤트 상태 (SharedPreferences에서 복원).
  final bool _initialMusicMuted;

  AudioBloc({
    required SoundLayerManager soundManager,
    required GameEventBus eventBus,
    required AudioConfig config,
    bool initialSfxMuted = false,
    bool initialMusicMuted = false,
  })  : _soundManager = soundManager,
        _eventBus = eventBus,
        _config = config,
        _initialSfxMuted = initialSfxMuted,
        _initialMusicMuted = initialMusicMuted,
        super(const AudioUninitialized()) {
    on<InitializeAudio>(_onInitialize);
    on<PlaySfx>(_onPlaySfx);
    on<PlayBgm>(_onPlayBgm);
    on<StopBgm>(_onStopBgm);
    on<PauseBgm>(_onPauseBgm);
    on<ResumeBgm>(_onResumeBgm);
    on<SetMasterVolume>(_onSetMasterVolume);
    on<SetSfxVolume>(_onSetSfxVolume);
    on<SetMusicVolume>(_onSetMusicVolume);
    on<ToggleMute>(_onToggleMute);
    on<ToggleSfxMute>(_onToggleSfxMute);
    on<ToggleMusicMute>(_onToggleMusicMute);
  }

  // ─── Per-layer mute helpers ──────────────────────────────

  /// SFX 재생 가능 여부 (AudioReady + sfxMuted가 아닌 경우).
  bool get _canPlaySfx {
    final s = state;
    return s is AudioReady && !s.sfxMuted;
  }

  /// Music 재생 가능 여부 (AudioReady + musicMuted가 아닌 경우).
  bool get _canPlayMusic {
    final s = state;
    return s is AudioReady && !s.musicMuted;
  }

  /// 현재 카드 플레이 억제 윈도우 안인지 확인.
  bool get _inCardPlayWindow {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (now - _lastCardPlayMs) < _cardPlayWindowMs;
  }

  /// SFX ID로 사운드 재생 (뮤트/미초기화 시 무시).
  ///
  /// [suppressDuringCardPlay] true면 카드 플레이 윈도우 중 억제.
  void _playSfxIfReady(String sfxId, {bool suppressDuringCardPlay = false}) {
    if (!_canPlaySfx) return;

    // 카드 플레이 윈도우 중 2차 SFX 억제
    if (suppressDuringCardPlay && _inCardPlayWindow) return;

    // 동일 SFX 쿨다운
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastPlay = _sfxCooldowns[sfxId] ?? 0;
    if ((now - lastPlay) < _sfxCooldownMs) return;
    _sfxCooldowns[sfxId] = now;

    final path = SfxRegistry.pathFor(sfxId);
    if (path != null) _soundManager.playSfx(path);
  }

  Future<void> _onInitialize(
    InitializeAudio event,
    Emitter<AudioState> emit,
  ) async {
    try {
      await _soundManager.initialize();

      // 초기 볼륨 설정
      _soundManager.setMasterVolume(_config.masterVolume);
      _soundManager.setSfxVolume(_config.sfxVolume);
      _soundManager.setMusicVolume(_config.musicVolume);

      emit(AudioReady(
        masterVolume: _config.masterVolume,
        sfxVolume: _config.sfxVolume,
        musicVolume: _config.musicVolume,
        sfxMuted: _initialSfxMuted,
        musicMuted: _initialMusicMuted,
      ));

      // GameEventBus 구독
      _subscriptions.addAll([
        // ── 카드 플레이 (1차 SFX — 항상 재생) ──
        _eventBus.on<CardPlayedEvent>().listen((e) {
          _lastCardPlayMs = DateTime.now().millisecondsSinceEpoch;
          _playSfxIfReady(SfxRegistry.sfxForCardType(e.cardType));
        }),

        // ── 상태 효과 (2차 SFX — 카드 플레이 중 억제) ──
        _eventBus.on<StatusEffectAppliedEvent>().listen((e) {
          _playSfxIfReady(
            SfxRegistry.sfxForStatusEffect(e.effectType),
            suppressDuringCardPlay: true,
          );
        }),

        // ── 카드 드로우 (2차 SFX — 카드 플레이 중 억제) ──
        _eventBus.on<CardDrawnEvent>().listen((_) {
          _playSfxIfReady('card_draw', suppressDuringCardPlay: true);
        }),

        // ── 카드 소멸 (2차 SFX — 카드 플레이 중 억제) ──
        _eventBus.on<CardExhaustedEvent>().listen((_) {
          _playSfxIfReady('card_exhaust', suppressDuringCardPlay: true);
        }),

        // ── 연쇄 보너스 (2차 SFX — 카드 플레이 중 억제) ──
        _eventBus.on<ChainBonusEvent>().listen((_) {
          _playSfxIfReady('chain_combo', suppressDuringCardPlay: true);
        }),

        // ── 전투 마일스톤 (항상 재생 — 타격/블록은 중요 피드백) ──
        _eventBus.on<CombatMilestoneEvent>().listen((e) {
          _playSfxIfReady(SfxRegistry.sfxForCombatMilestone(e.type.name));
        }),

        // ── 덱 셔플 (항상 재생) ──
        _eventBus.on<DeckShuffledEvent>().listen((_) {
          _playSfxIfReady('deck_shuffle');
        }),

        // ── 플레이어 피격 ──
        _eventBus.on<PlayerDamagedEvent>().listen((e) {
          if (e.hpLost > 0) {
            _playSfxIfReady('player_hurt');
          }
        }),

        // ── 골드 획득 ──
        _eventBus.on<GoldGainedEvent>().listen((e) {
          if (e.amount > 0) {
            _playSfxIfReady('gold_gain');
          }
        }),

        // ── 상점 구매 ──
        _eventBus.on<ShopPurchaseEvent>().listen((_) {
          _playSfxIfReady('shop_purchase');
        }),

        // ── 방 입장 ──
        _eventBus.on<RoomEnteredEvent>().listen((_) {
          _playSfxIfReady('room_enter');
        }),

        // ── 던전 층 준비 완료 (로딩 후 탐색 BGM 즉시 시작) ──
        _eventBus.on<DungeonFloorReadyEvent>().listen((e) {
          if (_currentBgmId == null) {
            add(PlayBgm(BgmRegistry.explorationBgmForFloor(e.floorNumber)));
          }
        }),

        // ── 휴식 선택 (힐/업그레이드) ──
        _eventBus.on<RestChoiceEvent>().listen((e) {
          if (e.hpChange > 0 || e.maxHpChange > 0) {
            _playSfxIfReady('rest_heal');
          }
        }),

        // ── 이벤트 선택 ──
        _eventBus.on<EventChoiceEvent>().listen((e) {
          if (e.hpChange > 0) {
            _playSfxIfReady('heal');
          } else {
            _playSfxIfReady('event_choice');
          }
        }),

        // ── 보스 선택 ──
        _eventBus.on<BossChoiceEvent>().listen((_) {
          _playSfxIfReady('boss_choice');
        }),

        // ── 기세 변화 (티어 변경 시 SFX) ──
        _eventBus.on<MomentumChangedEvent>().listen((e) {
          if (!_canPlaySfx) return;

          // 기세 티어 변경 감지
          final newTier = _momentumTier(e.value);
          if (newTier != _prevMomentumTier) {
            final isUp = _tierRank(newTier) > _tierRank(_prevMomentumTier);
            _prevMomentumTier = newTier;
            _playSfxIfReady(isUp ? 'momentum_up' : 'momentum_down');
          }
        }),

        // ── 층 완료 (탐색 BGM) ──
        _eventBus.on<FloorCompletedEvent>().listen((e) {
          final bgmId = BgmRegistry.explorationBgmForFloor(e.floorNumber);
          add(PlayBgm(bgmId));
        }),

        // ── 진실 공개 ──
        _eventBus.on<TruthRevealEvent>().listen((_) {
          _playSfxIfReady('narrator_truth_reveal');
        }),

        // ── 전투 시작 (전투 BGM) ──
        _eventBus.on<CombatStartedEvent>().listen((e) {
          final bgmId = BgmRegistry.combatBgm(
            isBoss: e.isBoss,
            isElite: e.isElite,
          );
          add(PlayBgm(bgmId));
        }),

        // ── 전투 종료 (탐색 BGM 복귀) ──
        _eventBus.on<CombatEndedEvent>().listen((e) {
          final bgmId = BgmRegistry.explorationBgmForFloor(e.currentFloor);
          add(PlayBgm(bgmId));
        }),

        // ── 퍼마데스 (BGM 정지 + ID 초기화 → 다음 런 시작 시 새 BGM 재생) ──
        _eventBus.on<PermadeathEvent>().listen((_) {
          add(const StopBgm());
        }),

        // ── 런 클리어 (BGM 정지) ──
        _eventBus.on<RunCompletedEvent>().listen((_) {
          add(const StopBgm());
        }),
      ]);

      GameLogger.info(LogSystem.audio,
          'Audio initialized (${SfxRegistry.count} SFX, ${BgmRegistry.count} BGM registered)');
    } catch (e) {
      GameLogger.error(LogSystem.audio, 'Audio initialization failed', e);
      emit(AudioError('Audio initialization failed: $e'));
    }
  }

  /// 기세 값 → 티어 문자열.
  static String _momentumTier(int value) {
    if (value >= 80) return 'high';
    if (value >= 30) return 'mid';
    return 'low';
  }

  /// 티어 → 수치 순위 (비교용).
  static int _tierRank(String tier) => switch (tier) {
        'high' => 2,
        'mid' => 1,
        _ => 0,
      };

  Future<void> _onPlaySfx(
    PlaySfx event,
    Emitter<AudioState> emit,
  ) async {
    if (!_canPlaySfx) return;
    final path = SfxRegistry.pathFor(event.sfxId);
    if (path == null) {
      GameLogger.warning(
        LogSystem.audio,
        'Unknown SFX ID: ${event.sfxId}',
      );
      return;
    }
    await _soundManager.playSfx(path);
  }

  // ─── BGM handlers ──────────────────────────────────────

  Future<void> _onPlayBgm(
    PlayBgm event,
    Emitter<AudioState> emit,
  ) async {
    if (!_canPlayMusic) return;

    // 동일 BGM 중복 재생 방지
    if (_currentBgmId == event.bgmId) return;

    final path = BgmRegistry.pathFor(event.bgmId);
    if (path == null) {
      GameLogger.warning(
        LogSystem.audio,
        'Unknown BGM ID: ${event.bgmId}',
      );
      return;
    }

    _currentBgmId = event.bgmId;
    await _soundManager.playMusic(path);
    GameLogger.info(LogSystem.audio, 'BGM started: ${event.bgmId}');
  }

  void _onStopBgm(
    StopBgm event,
    Emitter<AudioState> emit,
  ) {
    _currentBgmId = null;
    _soundManager.stopMusic();
    GameLogger.info(LogSystem.audio, 'BGM stopped');
  }

  void _onPauseBgm(
    PauseBgm event,
    Emitter<AudioState> emit,
  ) {
    _soundManager.pauseMusic();
  }

  void _onResumeBgm(
    ResumeBgm event,
    Emitter<AudioState> emit,
  ) {
    _soundManager.resumeMusic();
  }

  // ─── Volume handlers ──────────────────────────────────

  void _onSetMasterVolume(
    SetMasterVolume event,
    Emitter<AudioState> emit,
  ) {
    final currentState = state;
    if (currentState is! AudioReady) return;

    final clamped = event.volume.clamp(0.0, 1.0);
    _soundManager.setMasterVolume(clamped);
    emit(currentState.copyWith(masterVolume: clamped));
  }

  void _onSetSfxVolume(
    SetSfxVolume event,
    Emitter<AudioState> emit,
  ) {
    final currentState = state;
    if (currentState is! AudioReady) return;

    final clamped = event.volume.clamp(0.0, 1.0);
    _soundManager.setSfxVolume(clamped);
    emit(currentState.copyWith(sfxVolume: clamped));
  }

  void _onSetMusicVolume(
    SetMusicVolume event,
    Emitter<AudioState> emit,
  ) {
    final currentState = state;
    if (currentState is! AudioReady) return;

    final clamped = event.volume.clamp(0.0, 1.0);
    _soundManager.setMusicVolume(clamped);
    emit(currentState.copyWith(musicVolume: clamped));
  }

  // ─── Mute handlers ──────────────────────────────────

  void _onToggleMute(
    ToggleMute event,
    Emitter<AudioState> emit,
  ) {
    final currentState = state;
    if (currentState is! AudioReady) return;

    // 전체 뮤트: 2개 플래그 동시 토글
    final allMuted = currentState.muted;
    final newMuted = !allMuted;

    if (newMuted) {
      _soundManager.stopAll();
      _currentBgmId = null;
    }
    emit(currentState.copyWith(
      sfxMuted: newMuted,
      musicMuted: newMuted,
    ));
  }

  void _onToggleSfxMute(
    ToggleSfxMute event,
    Emitter<AudioState> emit,
  ) {
    final currentState = state;
    if (currentState is! AudioReady) return;

    emit(currentState.copyWith(sfxMuted: !currentState.sfxMuted));
  }

  void _onToggleMusicMute(
    ToggleMusicMute event,
    Emitter<AudioState> emit,
  ) {
    final currentState = state;
    if (currentState is! AudioReady) return;

    final newMuted = !currentState.musicMuted;
    if (newMuted) {
      _soundManager.stopMusic();
      _currentBgmId = null;
    }
    emit(currentState.copyWith(musicMuted: newMuted));
  }

  @override
  Future<void> close() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _soundManager.dispose();
    return super.close();
  }
}
