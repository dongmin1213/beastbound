import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/events/boss_choice_event.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/core/events/ghost_encountered_event.dart';
import 'package:soul_dungeon/domain/dungeon/event/event_room_generator.dart';
import 'package:soul_dungeon/domain/dungeon/event/job_event_variants.dart';
import 'package:soul_dungeon/domain/narrative/content/boss_text_variants.dart';
import 'package:soul_dungeon/domain/progression/ghost/ghost_npc_data.dart';
import 'package:soul_dungeon/domain/progression/ghost/ghost_reaction.dart';
import 'package:soul_dungeon/core/models/boss_choice.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/domain/dungeon/event/event_room_data.dart';
import 'package:soul_dungeon/presentation/screens/game/ghost/ghost_text_builder.dart';

void main() {
  group('E7b 보스 선택 변형 통합', () {
    late GameEventBus bus;

    setUp(() {
      bus = GameEventBus();
    });

    tearDown(() {
      bus.dispose();
    });

    test('BossChoiceEvent 브로드캐스트', () {
      bus.emit(BossChoiceEvent(
        floor: 1,
        bossId: 'boss_slime_king',
        choiceType: 'slay',
        playerJobId: 'warrior',
      ));

      final events = bus.history.whereType<BossChoiceEvent>().toList();
      expect(events, hasLength(1));
      expect(events.first.bossId, 'boss_slime_king');
      expect(events.first.choiceType, 'slay');
    });

    test('5보스 × 3선택지 기본 텍스트', () {
      final bosses = [
        'boss_slime_king',
        'boss_spider_lord',
        'boss_orc_general',
        'boss_vampire_lord',
        'boss_dungeon_master',
      ];
      for (final bossId in bosses) {
        for (final type in BossChoiceType.values) {
          final text = BossTextVariants.choiceResultText(bossId, type);
          expect(text.isNotEmpty, isTrue,
              reason: '$bossId + ${type.name} should have text');
        }
      }
    });

    test('직업별 변형 — 전사+슬라임왕+처치', () {
      final generic = BossTextVariants.choiceResultText(
        'boss_slime_king',
        BossChoiceType.slay,
      );
      final warrior = BossTextVariants.choiceResultText(
        'boss_slime_king',
        BossChoiceType.slay,
        jobId: 'warrior',
      );
      expect(warrior, isNot(generic));
      expect(warrior, contains('전사'));
    });

    test('직업별 변형 — 현자+거미군주+해방', () {
      final sage = BossTextVariants.choiceResultText(
        'boss_spider_lord',
        BossChoiceType.liberate,
        jobId: 'sage',
      );
      expect(sage, contains('현자'));
    });

    test('미등록 직업 → generic 폴백', () {
      final generic = BossTextVariants.choiceResultText(
        'boss_slime_king',
        BossChoiceType.slay,
      );
      final unknown = BossTextVariants.choiceResultText(
        'boss_slime_king',
        BossChoiceType.slay,
        jobId: 'unknown_job',
      );
      expect(unknown, generic);
    });
  });

  group('E7b 유령 NPC 통합', () {
    late GameEventBus bus;

    setUp(() {
      bus = GameEventBus();
    });

    tearDown(() {
      bus.dispose();
    });

    test('GhostEncounteredEvent 브로드캐스트', () {
      bus.emit(GhostEncounteredEvent(
        ghostJobId: 'warrior',
        ghostDeathFloor: 2,
        reactionLevel: 'familiar',
      ));

      final events = bus.history
          .whereType<GhostEncounteredEvent>()
          .toList();
      expect(events, hasLength(1));
      expect(events.first.ghostJobId, 'warrior');
    });

    test('유령 등장 텍스트 직업 포함', () {
      final ghost = GhostNpcData(
        deathFloor: 2,
        jobId: 'warrior',
        dispositionSnapshot: {},
        runNumber: 1,
      );
      final intro = GhostTextBuilder.introText(ghost);
      expect(intro, contains('전사'));
    });

    test('반응 레벨별 선택지 수', () {
      final familiarChoices =
          GhostTextBuilder.ghostChoices(GhostReactionLevel.familiar);
      final distantChoices =
          GhostTextBuilder.ghostChoices(GhostReactionLevel.distant);

      expect(familiarChoices.length, greaterThanOrEqualTo(2));
      expect(distantChoices.length, greaterThanOrEqualTo(1));
    });

    test('반응 레벨별 텍스트 차이', () {
      final familiar = GhostTextBuilder.reactionText(
        GhostReactionLevel.familiar,
        'warrior',
      );
      final distant = GhostTextBuilder.reactionText(
        GhostReactionLevel.distant,
        'warrior',
      );
      expect(familiar, isNot(distant));
    });
  });

  group('E7b 직업별 이벤트 변형 통합', () {
    test('6직업 각각 매칭 이벤트 변형', () {
      final jobEventPairs = {
        'warrior': '전사의 유령',
        'sage': '수정 동굴',
        'assassin': '수상한 상인',
        'saint': '깨진 제단',
        'guardian': '잊혀진 보물상자',
        'wanderer': '이상한 거래',
      };

      for (final entry in jobEventPairs.entries) {
        final variant = JobEventVariants.getVariant(entry.value, entry.key);
        expect(variant, isNotNull,
            reason: '${entry.key} + "${entry.value}" should have variant');
        expect(variant!.label.isNotEmpty, isTrue);
        expect(variant.outcomeText.isNotEmpty, isTrue);
      }
    });

    test('null jobId → null 반환', () {
      final variant = JobEventVariants.getVariant('전사의 유령', null);
      expect(variant, isNull);
    });

    test('비매칭 이벤트 → null 반환', () {
      final variant = JobEventVariants.getVariant('존재하지 않는 이벤트', 'warrior');
      expect(variant, isNull);
    });

    test('EventRoomGenerator 직업별 선택지 추가', () {
      const config = EventConfig();

      // 시드를 조정하여 '전사의 유령' 이벤트를 선택하도록 찾기
      EventChoice? found;
      for (var seed = 0; seed < 100; seed++) {
        final room = EventRoomGenerator.generate(
          floor: 1,
          eventConfig: config,
          playerJobId: 'warrior',
          seed: seed,
        );
        if (room.title == '전사의 유령') {
          // 기본 선택지 + 직업별 추가 선택지
          final jobVariant = room.choices.where(
            (c) => c.label == '전사의 긍지로 맞선다',
          );
          if (jobVariant.isNotEmpty) {
            found = jobVariant.first;
            break;
          }
        }
      }
      expect(found, isNotNull, reason: '전사 + 전사의 유령 변형 발견');
      expect(found!.outcomeText, contains('투지'));
    });
  });
}
