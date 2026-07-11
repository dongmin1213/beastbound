import 'package:flutter/material.dart';
import 'package:soul_dungeon/core/config/tamed_monster_store.dart';
import 'package:soul_dungeon/core/config/locale_controller.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soul_dungeon/app.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/core/config/game_hint_manager.dart';
import 'package:soul_dungeon/core/error/result.dart';
import 'package:soul_dungeon/core/save/save_data.dart';
import 'package:soul_dungeon/core/save/save_manager.dart';
import 'package:soul_dungeon/core/save/shared_prefs_save_storage.dart';
import 'package:soul_dungeon/domain/combat/content/card_pool.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final configResult = await BalanceConfig.load();
  final config = switch (configResult) {
    Success(:final data) => data,
    Failure() => const BalanceConfig(),
  };

  final prefs = await SharedPreferences.getInstance();
  GameHintManager.init(prefs);
  TamedMonsterStore.init(prefs);
  await LocaleController.init(prefs);
  final saveManager = SaveManager(
    SharedPrefsSaveStorage(prefs),
    cardResolver: CardPool.findById,
  );

  // 메타 데이터 로드 (소울, 엔딩 기록 등)
  final metaResult = await saveManager.loadMeta();
  final meta = switch (metaResult) {
    Success(:final data) => data,
    Failure() => const MetaSaveData(),
  };

  // 런 세이브 로드 (이어하기용)
  RunSaveData? initialRun;
  if (await saveManager.hasRunSave()) {
    final runResult = await saveManager.loadRun();
    initialRun = switch (runResult) {
      Success(:final data) => data,
      Failure() => null,
    };
  }

  // 저장된 오디오 설정 복원
  final savedSfxVolume = prefs.getDouble('sfx_volume');
  final savedMusicVolume = prefs.getDouble('music_volume');
  final audioConfig = config.audio.copyWith(
    sfxVolume: savedSfxVolume,
    musicVolume: savedMusicVolume,
  );
  final effectiveConfig = config.copyWith(audio: audioConfig);

  runApp(SoulDungeonApp(
    balanceConfig: effectiveConfig,
    saveManager: saveManager,
    initialMeta: meta,
    initialRun: initialRun,
    initialSfxMuted: prefs.getBool('sfx_muted') ?? false,
    initialMusicMuted: prefs.getBool('music_muted') ?? false,
  ));
}
