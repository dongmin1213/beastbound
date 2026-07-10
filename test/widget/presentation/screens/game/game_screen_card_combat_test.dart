import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/core/config/balance_config.dart';
import 'package:soul_dungeon/domain/combat/bloc/combat_state.dart';
import 'package:soul_dungeon/domain/combat/content/starter_cards.dart';
import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/core/models/enemy_action_type.dart';
import 'package:soul_dungeon/core/models/enemy_combat_data.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/presentation/screens/game/game_screen.dart';

import '../../../../helpers/game_screen_test_helper.dart';

/// 강한 적 — HP 999, 테스트에서 쉽게 죽지 않음.
const _toughEnemy = EnemyCombatData(
  id: 'test_golem',
  name: '테스트 골렘',
  hp: 999,
  atk: 3,
  def: 0,
  floor: 1,
  pattern: [EnemyActionType.attack],
);

/// 즉사용 적 — HP 1.
const _oneHpEnemy = EnemyCombatData(
  id: 'test_weakling',
  name: '허약한 적',
  hp: 1,
  atk: 0,
  def: 0,
  floor: 1,
  pattern: [EnemyActionType.observe],
);

/// 시작 덱 5장.
final _starterDeck = StarterCards.all;

/// 카드 전투 선택지 탭 + async 처리 대기.
/// 400ms delay + bloc stream.first 해결에 충분한 pump.
/// ensureVisible: 선택지가 스크롤 밖에 있을 수 있으므로 항상 호출.
///
/// [isCard] true → 카드 선택지 (ChoiceListWidget 더블탭 필요):
///   첫 탭 = 카드 선택 (시각 피드백), 둘째 탭 = 확인 (실제 플레이).
/// [isCard] false → 액션 버튼 (턴 종료/도주 등, 싱글탭).
Future<void> _selectCardAction(
  WidgetTester tester,
  Finder finder, {
  bool isCard = false,
}) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await tester.pump(); // highlight / select
  if (isCard) {
    // 더블탭: 같은 카드 재탭 → 실제 플레이
    await tester.tap(finder);
    await tester.pump();
  }
  await tester.pump(const Duration(milliseconds: 500)); // 400ms delay fires
  await tester.pump(); // microtask: stream.first resolve
  await tester.pump(); // setState from handler
  for (int i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

/// 카드 전투 진입 후 선택지 표시 대기.
Future<GameScreenState> _enterCardCombat(
  WidgetTester tester,
  EnemyCombatData enemy,
  List<CardData> deck, {
  int? withHp,
  RoomType roomType = RoomType.combat,
  FleeConfig fleeConfig = const FleeConfig(),
}) async {
  await pumpGameScreen(tester, fleeConfig: fleeConfig);
  final state = tester.state<GameScreenState>(find.byType(GameScreen));
  state.enterCardCombatForTest(enemy, deck, withHp: withHp, roomType: roomType);
  await tester.pump();
  await tester.pump();
  return state;
}

void main() {
  group('GameScreen 카드 전투 — 진입', () {
    testWidgets('enterCardCombatForTest → 카드 손패가 선택지로 표시', (tester) async {
      final state = await _enterCardCombat(tester, _toughEnemy, _starterDeck);

      expect(state.inCardCombatForTest, isTrue);
      expect(state.combatStateForTest, isA<CardCombatActive>());

      // 타격 + 방어 + 턴 종료 + 도주
      expect(find.textContaining('턴 종료'), findsOneWidget);
      expect(find.textContaining('도주'), findsOneWidget);
    });

    testWidgets('카드 선택지에 AP 비용 표시', (tester) async {
      await _enterCardCombat(tester, _toughEnemy, _starterDeck);

      expect(find.textContaining('타격'), findsWidgets);
      expect(find.textContaining('방어'), findsWidgets);
    });

    testWidgets('보스 전투 시 도주 선택지 미표시', (tester) async {
      await _enterCardCombat(
        tester,
        _toughEnemy,
        _starterDeck,
        roomType: RoomType.boss,
      );

      expect(find.textContaining('도주'), findsNothing);
      expect(find.textContaining('턴 종료'), findsOneWidget);
    });
  });

  group('GameScreen 카드 전투 — 카드 플레이', () {
    testWidgets('타격 카드 플레이 → 결과 텍스트 표시', (tester) async {
      final state = await _enterCardCombat(tester, _toughEnemy, _starterDeck);

      await _selectCardAction(tester, find.textContaining('타격').first, isCard: true);

      final completedBlocks = state.completedBlocksForTest;
      final resultTexts = completedBlocks
          .where((b) => !b.isChoice)
          .map((b) => b.text)
          .toList();
      expect(
        resultTexts.any((t) => t.contains('데미지')),
        isTrue,
        reason: '카드 플레이 결과에 데미지 텍스트가 있어야 함: $resultTexts',
      );
    });

    testWidgets('카드 플레이 후 AP 감소 반영', (tester) async {
      final state = await _enterCardCombat(tester, _toughEnemy, _starterDeck);

      final combatBefore = state.combatStateForTest as CardCombatActive;
      final apBefore = combatBefore.actionPoints;

      await _selectCardAction(tester, find.textContaining('타격').first, isCard: true);

      final combatAfter = state.combatStateForTest as CardCombatActive;
      expect(combatAfter.actionPoints, apBefore - 1);
    });
  });

  group('GameScreen 카드 전투 — 턴 종료', () {
    testWidgets('턴 종료 → 적 행동 텍스트 표시', (tester) async {
      final state = await _enterCardCombat(tester, _toughEnemy, _starterDeck);

      await _selectCardAction(tester, find.textContaining('턴 종료'));

      final completedBlocks = state.completedBlocksForTest;
      final resultTexts = completedBlocks
          .where((b) => !b.isChoice)
          .map((b) => b.text)
          .toList();
      expect(
        resultTexts.any((t) => t.contains('테스트 골렘')),
        isTrue,
        reason: '적 행동 결과에 적 이름이 포함되어야 함: $resultTexts',
      );
    });

    testWidgets('턴 종료 후 새 턴 시작 (AP 리셋, 손패 보충)', (tester) async {
      final state = await _enterCardCombat(tester, _toughEnemy, _starterDeck);

      // 카드 1장 플레이 → AP 감소
      await _selectCardAction(tester, find.textContaining('타격').first, isCard: true);

      // 턴 종료
      await _selectCardAction(tester, find.textContaining('턴 종료'));

      final combatState = state.combatStateForTest as CardCombatActive;
      expect(combatState.currentTurn, 1);
      expect(combatState.actionPoints, combatState.maxActionPoints);
    });
  });

  group('GameScreen 카드 전투 — 승리', () {
    testWidgets('적 HP 0 이하 → 승리 텍스트 + 보상 표시 (전투 화면 유지)', (tester) async {
      final state = await _enterCardCombat(tester, _oneHpEnemy, _starterDeck);

      await _selectCardAction(tester, find.textContaining('타격').first, isCard: true);

      // 승리 후 보상 선택까지 전투 화면 유지
      expect(state.inCardCombatForTest, isTrue);

      final completedBlocks = state.completedBlocksForTest;
      expect(
        completedBlocks.any((b) => b.text.contains('전투 승리')),
        isTrue,
      );
    });
  });

  group('GameScreen 카드 전투 — 도주', () {
    testWidgets('도주 → 카드 전투 종료 + 도주 텍스트', (tester) async {
      // 100% 성공률로 확정적 테스트
      final state = await _enterCardCombat(
        tester,
        _toughEnemy,
        _starterDeck,
        fleeConfig: const FleeConfig(baseSuccessRate: 1.0),
      );

      await _selectCardAction(tester, find.textContaining('도주'));

      expect(state.inCardCombatForTest, isFalse);

      final completedBlocks = state.completedBlocksForTest;
      expect(
        completedBlocks.any((b) => b.text.contains('도주에 성공')),
        isTrue,
      );
    });
  });

  group('GameScreen 카드 전투 — 패배', () {
    testWidgets('플레이어 HP 0 → 퍼마데스 (전투 종료)', (tester) async {
      final strongEnemy = const EnemyCombatData(
        id: 'test_killer',
        name: '킬러',
        hp: 999,
        atk: 100,
        def: 0,
        floor: 1,
        pattern: [EnemyActionType.attack],
      );
      final state = await _enterCardCombat(
        tester,
        strongEnemy,
        _starterDeck,
        withHp: 1,
      );

      // 턴 종료 → 적 공격 → 사망
      await _selectCardAction(tester, find.textContaining('턴 종료'));

      // 퍼마데스: 전투 화면 종료 확인
      expect(state.inCardCombatForTest, isFalse);

      // 재도전/물러나기 선택지가 없어야 함 (퍼마데스이므로)
      expect(find.textContaining('다시 도전하기'), findsNothing);
      expect(find.textContaining('물러나기'), findsNothing);
    });

    testWidgets('패배 (전투 사망) → 퍼마데스 경로', (tester) async {
      final strongEnemy = const EnemyCombatData(
        id: 'test_strong',
        name: '강한적',
        hp: 999,
        atk: 100,
        def: 0,
        floor: 1,
        pattern: [EnemyActionType.attack],
      );
      final state = await _enterCardCombat(
        tester,
        strongEnemy,
        _starterDeck,
        withHp: 100,
      );

      // 턴 종료 → 적 공격(100) → 전투 사망 (HP 0)
      await _selectCardAction(tester, find.textContaining('턴 종료'));

      // 퍼마데스: 전투 화면 종료 확인
      expect(state.inCardCombatForTest, isFalse);

      // 재도전/물러나기 선택지가 없어야 함 (퍼마데스이므로)
      expect(find.textContaining('다시 도전하기'), findsNothing);
      expect(find.textContaining('물러나기'), findsNothing);
    });
  });

  group('GameScreen 카드 전투 — 카드 보상', () {
    testWidgets('handleSelectCardReward — skip_reward → 전투 화면 유지 (보상 선택 대기)', (tester) async {
      final state = await _enterCardCombat(tester, _oneHpEnemy, _starterDeck);

      // 승리 달성 → 보상 선택까지 전투 화면 유지
      await _selectCardAction(tester, find.textContaining('타격').first, isCard: true);

      expect(state.inCardCombatForTest, isTrue);
    });
  });
}
