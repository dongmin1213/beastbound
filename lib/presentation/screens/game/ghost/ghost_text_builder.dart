import 'package:soul_dungeon/domain/progression/ghost/ghost_npc_data.dart';
import 'package:soul_dungeon/domain/progression/ghost/ghost_reaction.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_data.dart';

/// 유령 NPC 텍스트/선택지 빌더 (presentation 전용).
///
/// 유령 반응 레벨에 따른 인사말, 대화, 선택지를 생성.
class GhostTextBuilder {
  GhostTextBuilder._();

  static const _jobDisplayNames = <String, String>{
    'warrior': '전사',
    'sage': '현자',
    'assassin': '암살자',
    'saint': '성자',
    'guardian': '수호자',
    'wanderer': '방랑자',
  };

  /// 유령 등장 인트로 텍스트.
  static String introText(GhostNpcData ghost) {
    final jobName = _jobDisplayNames[ghost.jobId] ?? ghost.jobId;
    return '${ghost.deathFloor}층에서 쓰러진 $jobName의 유령이 나타났다. '
        '${ghost.runNumber}번째 여정의 잔상이 희미하게 흔들린다.';
  }

  /// 반응 레벨에 따른 대화 텍스트.
  static String reactionText(GhostReactionLevel level, String jobId) {
    final jobName = _jobDisplayNames[jobId] ?? jobId;
    return switch (level) {
      GhostReactionLevel.familiar =>
        '유령이 반갑게 다가온다. "같은 $jobName의 길을 걷는군... 반갑다."',
      GhostReactionLevel.curious =>
        '유령이 고개를 갸우뚱한다. "흥미로운 기운이야... $jobName과는 다르지만."',
      GhostReactionLevel.distant =>
        '유령이 냉담하게 바라본다. "$jobName이었던 나와는 다른 길을 걷는 자..."',
    };
  }

  /// 반응 레벨에 따른 선택지 목록.
  static List<ChoiceData> ghostChoices(GhostReactionLevel level) =>
      switch (level) {
        GhostReactionLevel.familiar => [
            const ChoiceData(
              id: 'ghost_talk',
              text: '이야기를 나눈다',
              resultTextBlocks: ['유령과 이야기를 나눴다.'],
            ),
            const ChoiceData(
              id: 'ghost_trade',
              text: '지식을 나눠받는다',
              resultTextBlocks: ['유령이 가진 지식을 나눠주었다.'],
            ),
            const ChoiceData(
              id: 'ghost_fight',
              text: '겨뤄본다',
              resultTextBlocks: ['유령과 전투를 시작한다.'],
            ),
            const ChoiceData(
              id: 'ghost_farewell',
              text: '작별을 고한다',
              resultTextBlocks: ['유령에게 작별을 고했다.'],
            ),
          ],
        GhostReactionLevel.curious => [
            const ChoiceData(
              id: 'ghost_talk',
              text: '이야기를 나눈다',
              resultTextBlocks: ['유령과 이야기를 나눴다.'],
            ),
            const ChoiceData(
              id: 'ghost_fight',
              text: '겨뤄본다',
              resultTextBlocks: ['유령과 전투를 시작한다.'],
            ),
            const ChoiceData(
              id: 'ghost_farewell',
              text: '작별을 고한다',
              resultTextBlocks: ['유령에게 작별을 고했다.'],
            ),
          ],
        GhostReactionLevel.distant => [
            const ChoiceData(
              id: 'ghost_approach',
              text: '조심스럽게 다가간다',
              resultTextBlocks: ['조심스럽게 다가갔다.'],
            ),
            const ChoiceData(
              id: 'ghost_fight',
              text: '도발한다',
              resultTextBlocks: ['유령을 도발했다.'],
            ),
            const ChoiceData(
              id: 'ghost_ignore',
              text: '무시하고 지나간다',
              resultTextBlocks: ['유령을 무시하고 지나갔다.'],
            ),
          ],
      };
}
