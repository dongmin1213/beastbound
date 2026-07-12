import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';

/// 선택지 시각 위계 스타일.
enum ChoiceStyle { normal, caution, reward }

class ChoiceData {
  final String id;
  final String text;
  final List<String> resultTextBlocks;
  final String? actionType;
  final bool enabled;
  final int? apCost;
  final CardType? cardType;
  final ChoiceStyle choiceStyle;

  /// 카드 전투 선택지의 원본 카드 데이터 (롱프레스 상세 보기용).
  final CardData? sourceCard;

  const ChoiceData({
    required this.id,
    required this.text,
    required this.resultTextBlocks,
    this.actionType,
    this.enabled = true,
    this.apCost,
    this.cardType,
    this.choiceStyle = ChoiceStyle.normal,
    this.sourceCard,
  });

  /// 카드 전투 선택지인지 여부.
  bool get isCard => cardType != null;
}

/// 텍스트 블록 유형
enum TextBlockType {
  normal,
  combatPreview,
  turnDivider,
  combatResult,
  combatOutcome,
  environmentNarration,
  environmentDiscovery,
}

class TextBlockData {
  final String text;
  final List<ChoiceData>? choices;
  final TextBlockType blockType;
  final Map<String, dynamic>? metadata;

  const TextBlockData({
    required this.text,
    this.choices,
    this.blockType = TextBlockType.normal,
    this.metadata,
  });

  bool get hasChoices => choices != null && choices!.isNotEmpty;

  static TextBlockData fromSimpleText(String text) =>
      TextBlockData(text: text);

  static List<TextBlockData> fromSimpleTexts(List<String> texts) =>
      texts.map((t) => TextBlockData(text: t)).toList();
}

class CompletedBlock {
  final String text;
  final bool isChoice;
  final TextBlockType blockType;
  final Map<String, dynamic>? metadata;

  const CompletedBlock({
    required this.text,
    this.isChoice = false,
    this.blockType = TextBlockType.normal,
    this.metadata,
  });
}
