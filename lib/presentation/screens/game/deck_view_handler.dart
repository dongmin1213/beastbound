import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/core/models/game_enums.dart';
import 'package:soul_dungeon/presentation/widgets/combat_ui/card_display_formatter.dart';

/// 덱 뷰 — 현재 덱 카드 목록 + 통계.
class DeckViewHandler {
  DeckViewHandler._();

  /// 덱 카드 목록 텍스트 생성.
  /// 카드 타입 순서(attack→skill→power)로 정렬.
  static List<String> formatDeckList(List<CardData> deck) {
    final sorted = List<CardData>.from(deck)
      ..sort((a, b) => a.type.index.compareTo(b.type.index));
    return sorted
        .map((card) => CardDisplayFormatter.formatCardLine(card))
        .toList();
  }

  /// 덱 통계 텍스트.
  static String formatDeckStats(List<CardData> deck) {
    final attacks = deck.where((c) => c.type == CardType.attack).length;
    final skills = deck.where((c) => c.type == CardType.skill).length;
    final powers = deck.where((c) => c.type == CardType.power).length;
    final upgraded = deck.where((c) => c.upgraded).length;
    return '덱: ${deck.length}장 (공격 $attacks / 스킬 $skills / 파워 $powers) 업그레이드: $upgraded';
  }
}
