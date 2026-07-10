import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/domain/dungeon/event/event_room_data.dart';
import 'package:soul_dungeon/presentation/theme/app_theme.dart';
import 'package:soul_dungeon/presentation/widgets/event/event_widget.dart';

void main() {
  const testChoice1 = EventChoice(
    label: '도움을 준다',
    outcomeText: '감사합니다.',
    goldChange: 10,
    hpChange: 0,
  );
  const testChoice2 = EventChoice(
    label: '무시한다',
    outcomeText: '지나간다.',
    goldChange: 0,
    hpChange: 0,
  );
  const testChoice3 = EventChoice(
    label: '약탈한다',
    outcomeText: '금화를 빼앗았다.',
    goldChange: 15,
    hpChange: -5,
  );
  final testData = EventRoomData(
    title: '길을 잃은 여행자',
    narrativeText: '어두운 통로에 여행자가 있다.',
    choices: [testChoice1, testChoice2, testChoice3],
  );

  Widget buildTestWidget(
    EventRoomData data, {
    void Function(int)? onChoiceSelected,
  }) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: EventWidget(
          data: data,
          onChoiceSelected: onChoiceSelected ?? (_) {},
        ),
      ),
    );
  }

  group('EventWidget', () {
    testWidgets('renders choice labels without exposing outcomeText', (tester) async {
      await tester.pumpWidget(buildTestWidget(testData));

      // 헤더 (RetroWindowFrame 타이틀) + 이벤트 제목 + 서술 텍스트
      expect(find.text('[이벤트]'), findsOneWidget);
      expect(find.text('길을 잃은 여행자'), findsOneWidget);
      expect(find.text('어두운 통로에 여행자가 있다.'), findsOneWidget);

      // 선택지 label + 효과 요약 표시
      expect(find.text('도움을 준다 (골드 +10)'), findsOneWidget);
      expect(find.text('무시한다'), findsOneWidget);
      expect(find.text('약탈한다 (HP -5 / 골드 +15)'), findsOneWidget);

      // outcomeText는 절대 노출 금지
      expect(find.text('감사합니다.'), findsNothing);
      expect(find.text('지나간다.'), findsNothing);
      expect(find.text('금화를 빼앗았다.'), findsNothing);
    });

    testWidgets('tap choice button calls onChoiceSelected with correct index', (tester) async {
      int? selectedIndex;
      await tester.pumpWidget(buildTestWidget(
        testData,
        onChoiceSelected: (index) => selectedIndex = index,
      ));

      // 두 번째 선택지 탭
      await tester.tap(find.text('무시한다'));
      expect(selectedIndex, 1);

      // 첫 번째 선택지 탭
      await tester.tap(find.text('도움을 준다 (골드 +10)'));
      expect(selectedIndex, 0);

      // 세 번째 선택지 탭
      await tester.tap(find.text('약탈한다 (HP -5 / 골드 +15)'));
      expect(selectedIndex, 2);
    });
  });
}
