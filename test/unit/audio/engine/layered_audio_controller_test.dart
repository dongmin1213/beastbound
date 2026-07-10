import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/audio/engine/layered_audio_controller.dart';
import 'package:soul_dungeon/audio/engine/sound_layer_manager.dart';

/// stopAll/stopMusic 호출 횟수를 추적하는 테스트용 SoundLayerManager.
class _TrackingSoundLayerManager extends NoOpSoundLayerManager {
  int stopAllCount = 0;
  int stopMusicCount = 0;

  @override
  void stopAll() {
    stopAllCount++;
  }

  @override
  void stopMusic() {
    stopMusicCount++;
  }
}

void main() {
  group('LayeredAudioController', () {
    group('layerForMomentum (기본 임계값)', () {
      test('momentum 0 -> L0', () {
        expect(
          LayeredAudioController.layerForMomentum(0),
          AudioLayer.l0,
        );
      });

      test('momentum 9 -> L0 (thresholdLow 미만)', () {
        expect(
          LayeredAudioController.layerForMomentum(9),
          AudioLayer.l0,
        );
      });

      test('momentum 10 -> L1 (thresholdLow 경계)', () {
        expect(
          LayeredAudioController.layerForMomentum(10),
          AudioLayer.l1,
        );
      });

      test('momentum 29 -> L1 (thresholdMedium 미만)', () {
        expect(
          LayeredAudioController.layerForMomentum(29),
          AudioLayer.l1,
        );
      });

      test('momentum 30 -> L2 (thresholdMedium 경계)', () {
        expect(
          LayeredAudioController.layerForMomentum(30),
          AudioLayer.l2,
        );
      });

      test('momentum 79 -> L2 (thresholdHigh 미만)', () {
        expect(
          LayeredAudioController.layerForMomentum(79),
          AudioLayer.l2,
        );
      });

      test('momentum 80 -> L3 (thresholdHigh 경계)', () {
        expect(
          LayeredAudioController.layerForMomentum(80),
          AudioLayer.l3,
        );
      });

      test('momentum 100 -> L3 (thresholdHigh 초과)', () {
        expect(
          LayeredAudioController.layerForMomentum(100),
          AudioLayer.l3,
        );
      });
    });

    group('layerForMomentum (커스텀 임계값)', () {
      test('커스텀 thresholds: 5/20/50', () {
        expect(
          LayeredAudioController.layerForMomentum(
            4,
            thresholdLow: 5,
            thresholdMedium: 20,
            thresholdHigh: 50,
          ),
          AudioLayer.l0,
        );
        expect(
          LayeredAudioController.layerForMomentum(
            5,
            thresholdLow: 5,
            thresholdMedium: 20,
            thresholdHigh: 50,
          ),
          AudioLayer.l1,
        );
        expect(
          LayeredAudioController.layerForMomentum(
            20,
            thresholdLow: 5,
            thresholdMedium: 20,
            thresholdHigh: 50,
          ),
          AudioLayer.l2,
        );
        expect(
          LayeredAudioController.layerForMomentum(
            50,
            thresholdLow: 5,
            thresholdMedium: 20,
            thresholdHigh: 50,
          ),
          AudioLayer.l3,
        );
      });
    });

    group('applyLayer', () {
      late _TrackingSoundLayerManager manager;

      setUp(() {
        manager = _TrackingSoundLayerManager();
      });

      test('L0 -> BGM 유지 (no-op)', () {
        LayeredAudioController.applyLayer(AudioLayer.l0, manager);
        expect(manager.stopAllCount, 0);
        expect(manager.stopMusicCount, 0);
      });

      test('L1 -> BGM 유지 (no-op)', () {
        LayeredAudioController.applyLayer(AudioLayer.l1, manager);
        expect(manager.stopMusicCount, 0);
        expect(manager.stopAllCount, 0);
      });

      test('L2 -> BGM 유지 (no-op)', () {
        LayeredAudioController.applyLayer(AudioLayer.l2, manager);
        expect(manager.stopMusicCount, 0);
        expect(manager.stopAllCount, 0);
      });

      test('L3 -> 아무 호출 없음 (모든 레이어 활성)', () {
        LayeredAudioController.applyLayer(AudioLayer.l3, manager);
        expect(manager.stopAllCount, 0);
        expect(manager.stopMusicCount, 0);
      });
    });
  });
}
