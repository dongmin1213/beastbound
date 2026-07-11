import 'dart:math';

import 'package:soul_dungeon/core/models/boss_choice.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_data.dart';

/// 보스 승리 후 3선택지 생성 + 기세 게이팅.
///
/// 공격적 풀(slay/consume)에서 1개 + 온건 풀(liberate/protect/coexist/study)에서 2개.
class BossChoiceHandler {
  BossChoiceHandler._();

  /// 기세 해금 임계값 — 2번째 온건 선택지는 이 값 이상이어야 선택 가능.
  static const int momentumThreshold = 50;

  /// 공격적 선택지 풀.
  static const _aggressiveTypes = [
    BossChoiceType.slay,
    BossChoiceType.consume,
  ];

  /// 온건 선택지 풀.
  static const _moderateTypes = [
    BossChoiceType.liberate,
    BossChoiceType.protect,
    BossChoiceType.coexist,
    BossChoiceType.study,
  ];

  /// 보스 승리 후 3선택지 생성.
  ///
  /// 공격적 1개(랜덤) + 온건 2개(랜덤) = 3개.
  /// 첫 번째 온건 선택지는 항상 사용 가능.
  /// 두 번째 온건 선택지는 [momentum] >= [momentumThreshold] 필요.
  /// [random]으로 테스트 시 시드 주입 가능.
  static List<ChoiceData> buildChoices({
    required int floor,
    required String bossId,
    required int momentum,
    Random? random,
  }) {
    final rng = random ?? Random();
    final choices = <ChoiceData>[];

    // 공격적 풀에서 1개 랜덤 선택
    final aggressiveShuffled = List<BossChoiceType>.from(_aggressiveTypes)
      ..shuffle(rng);
    final aggressiveChoice = aggressiveShuffled.first;

    choices.add(ChoiceData(
      id: 'boss_${aggressiveChoice.name}',
      text: '${aggressiveChoice.displayName}'
          '\n${aggressiveChoice.description}',
      resultTextBlocks: const [],
      choiceStyle: ChoiceStyle.caution,
    ));

    // 온건 풀에서 2개 랜덤 선택
    final moderateShuffled = List<BossChoiceType>.from(_moderateTypes)
      ..shuffle(rng);
    final moderateChoices = moderateShuffled.take(2).toList();

    for (var i = 0; i < moderateChoices.length; i++) {
      final choice = moderateChoices[i];
      // 첫 번째 온건 선택지는 항상 해금, 두 번째만 기세 조건
      final isUnlocked = i == 0 || momentum >= momentumThreshold;
      if (isUnlocked) {
        choices.add(ChoiceData(
          id: 'boss_${choice.name}',
          text: '${choice.displayName}'
              '\n${choice.description}',
          resultTextBlocks: const [],
          choiceStyle: ChoiceStyle.reward,
        ));
      } else {
        choices.add(ChoiceData(
          id: 'boss_${choice.name}_locked',
          text: '${choice.displayName}'
              ' (기세 $momentumThreshold 필요)'
              '\n${choice.description}',
          resultTextBlocks: const [],
          enabled: false,
        ));
      }
    }

    return choices;
  }

  /// 선택지 ID → BossChoiceType 매핑.
  /// 잠금 선택지(_locked)는 null 반환.
  static BossChoiceType? choiceTypeFromId(String choiceId) {
    return switch (choiceId) {
      'boss_slay' => BossChoiceType.slay,
      'boss_liberate' => BossChoiceType.liberate,
      'boss_coexist' => BossChoiceType.coexist,
      'boss_study' => BossChoiceType.study,
      'boss_consume' => BossChoiceType.consume,
      'boss_protect' => BossChoiceType.protect,
      _ => null,
    };
  }

  /// 선택에 따른 성향 변경 델타.
  static int dispositionDelta = 3;
}
