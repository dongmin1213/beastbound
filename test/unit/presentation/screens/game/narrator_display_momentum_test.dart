import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/presentation/screens/game/narrator_display.dart';
import 'package:soul_dungeon/presentation/widgets/text_engine/text_effect.dart';
import 'package:soul_dungeon/presentation/widgets/text_engine/typewriter_widget.dart';

void main() {
  group('NarratorDisplay.textSpeedForMomentum', () {
    test('momentum 0 -> slow', () {
      expect(NarratorDisplay.textSpeedForMomentum(0), TextSpeed.slow);
    });

    test('momentum 9 -> slow (thresholdLow 미만)', () {
      expect(NarratorDisplay.textSpeedForMomentum(9), TextSpeed.slow);
    });

    test('momentum 10 -> slow (thresholdLow 경계)', () {
      expect(NarratorDisplay.textSpeedForMomentum(10), TextSpeed.slow);
    });

    test('momentum 29 -> slow (thresholdMedium 미만)', () {
      expect(NarratorDisplay.textSpeedForMomentum(29), TextSpeed.slow);
    });

    test('momentum 30 -> normal (thresholdMedium 경계)', () {
      expect(NarratorDisplay.textSpeedForMomentum(30), TextSpeed.normal);
    });

    test('momentum 50 -> normal (중간)', () {
      expect(NarratorDisplay.textSpeedForMomentum(50), TextSpeed.normal);
    });

    test('momentum 79 -> normal (thresholdHigh 미만)', () {
      expect(NarratorDisplay.textSpeedForMomentum(79), TextSpeed.normal);
    });

    test('momentum 80 -> fast (thresholdHigh 경계)', () {
      expect(NarratorDisplay.textSpeedForMomentum(80), TextSpeed.fast);
    });

    test('momentum 100 -> fast (최대)', () {
      expect(NarratorDisplay.textSpeedForMomentum(100), TextSpeed.fast);
    });
  });

  group('NarratorDisplay.textEffectForDistortion', () {
    test('cardDistortionLevel 0 + no glitch -> null (효과 없음)', () {
      expect(NarratorDisplay.textEffectForDistortion(0), isNull);
    });

    test('cardDistortionLevel 0 + microGlitch -> GlitchEffect (2층)', () {
      final effect = NarratorDisplay.textEffectForDistortion(0,
          microGlitchProbability: 0.05);
      expect(effect, isA<GlitchEffect>());
      expect((effect! as GlitchEffect).probability, 0.05);
    });

    test('cardDistortionLevel 1 -> JamoSplitEffect(splitLevel: 1)', () {
      final effect = NarratorDisplay.textEffectForDistortion(1);
      expect(effect, isA<JamoSplitEffect>());
      expect((effect! as JamoSplitEffect).splitLevel, 1);
    });

    test('cardDistortionLevel 2 -> JamoSplitEffect(splitLevel: 2)', () {
      final effect = NarratorDisplay.textEffectForDistortion(2);
      expect(effect, isA<JamoSplitEffect>());
      expect((effect! as JamoSplitEffect).splitLevel, 2);
    });

    test('cardDistortionLevel 3+ -> JamoSplitEffect(splitLevel: 2) (기본값)', () {
      final effect = NarratorDisplay.textEffectForDistortion(5);
      expect(effect, isA<JamoSplitEffect>());
      expect((effect! as JamoSplitEffect).splitLevel, 2);
    });
  });
}
