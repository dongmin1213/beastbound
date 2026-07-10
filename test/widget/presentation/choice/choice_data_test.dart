import 'package:flutter_test/flutter_test.dart';
import 'package:soul_dungeon/presentation/widgets/choice/choice_data.dart';

void main() {
  group('ChoiceData', () {
    test('creates with required fields', () {
      const choice = ChoiceData(
        id: 'choice_left',
        text: '왼쪽 길로 간다',
        resultTextBlocks: ['어둠이 깊어진다.'],
      );

      expect(choice.id, 'choice_left');
      expect(choice.text, '왼쪽 길로 간다');
      expect(choice.resultTextBlocks, ['어둠이 깊어진다.']);
    });

    test('supports empty result text blocks', () {
      const choice = ChoiceData(
        id: 'choice_empty',
        text: '계속 간다',
        resultTextBlocks: [],
      );

      expect(choice.resultTextBlocks, isEmpty);
    });

    test('supports multiple result text blocks', () {
      const choice = ChoiceData(
        id: 'choice_multi',
        text: '관찰한다',
        resultTextBlocks: [
          '주변을 살핀다.',
          '벽에 새겨진 문양이 보인다.',
        ],
      );

      expect(choice.resultTextBlocks, hasLength(2));
    });
  });

  group('TextBlockData', () {
    test('creates text block without choices', () {
      const block = TextBlockData(text: '어둠 속에서 두 갈래 길이 보인다.');

      expect(block.text, '어둠 속에서 두 갈래 길이 보인다.');
      expect(block.choices, isNull);
      expect(block.hasChoices, isFalse);
    });

    test('creates text block with choices', () {
      const block = TextBlockData(
        text: '어디로 갈 것인가?',
        choices: [
          ChoiceData(id: 'a', text: '왼쪽', resultTextBlocks: ['왼쪽으로 갔다.']),
          ChoiceData(id: 'b', text: '오른쪽', resultTextBlocks: ['오른쪽으로 갔다.']),
        ],
      );

      expect(block.hasChoices, isTrue);
      expect(block.choices, hasLength(2));
    });

    test('empty choices list treated as no choices', () {
      const block = TextBlockData(
        text: '텍스트',
        choices: [],
      );

      expect(block.hasChoices, isFalse);
    });

    test('single choice is valid', () {
      const block = TextBlockData(
        text: '유일한 선택',
        choices: [
          ChoiceData(id: 'only', text: '계속', resultTextBlocks: ['진행한다.']),
        ],
      );

      expect(block.hasChoices, isTrue);
      expect(block.choices, hasLength(1));
    });

    test('four choices is valid', () {
      const block = TextBlockData(
        text: '네 갈래 길',
        choices: [
          ChoiceData(id: 'a', text: '북', resultTextBlocks: []),
          ChoiceData(id: 'b', text: '남', resultTextBlocks: []),
          ChoiceData(id: 'c', text: '동', resultTextBlocks: []),
          ChoiceData(id: 'd', text: '서', resultTextBlocks: []),
        ],
      );

      expect(block.choices, hasLength(4));
    });

    test('fromSimpleText creates block without choices', () {
      final block = TextBlockData.fromSimpleText('단순 텍스트');

      expect(block.text, '단순 텍스트');
      expect(block.hasChoices, isFalse);
    });

    test('fromSimpleTexts creates list of blocks without choices', () {
      final blocks = TextBlockData.fromSimpleTexts([
        '첫 번째 블록',
        '두 번째 블록',
      ]);

      expect(blocks, hasLength(2));
      expect(blocks[0].text, '첫 번째 블록');
      expect(blocks[1].text, '두 번째 블록');
      expect(blocks.every((b) => !b.hasChoices), isTrue);
    });
  });

  group('CompletedBlock', () {
    test('creates regular text block', () {
      const block = CompletedBlock(text: '일반 텍스트');

      expect(block.text, '일반 텍스트');
      expect(block.isChoice, isFalse);
    });

    test('creates choice history block', () {
      const block = CompletedBlock(text: '왼쪽 길로 간다', isChoice: true);

      expect(block.text, '왼쪽 길로 간다');
      expect(block.isChoice, isTrue);
    });
  });
}
