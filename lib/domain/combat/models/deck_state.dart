import 'package:equatable/equatable.dart';
import 'package:soul_dungeon/core/models/card_data.dart';

/// 전투 중 덱 상태 — 드로우 파일/버림 더미/소진 파일/손패.
class DeckState extends Equatable {
  final List<CardData> drawPile;
  final List<CardData> hand;
  final List<CardData> discardPile;
  final List<CardData> exhaustPile;

  const DeckState({
    this.drawPile = const [],
    this.hand = const [],
    this.discardPile = const [],
    this.exhaustPile = const [],
  });

  int get drawPileCount => drawPile.length;
  int get handCount => hand.length;
  int get discardPileCount => discardPile.length;
  int get exhaustPileCount => exhaustPile.length;

  /// 손패에 특정 카드가 있는지 확인.
  bool hasCardInHand(String cardId) =>
      hand.any((c) => c.id == cardId);

  DeckState copyWith({
    List<CardData>? drawPile,
    List<CardData>? hand,
    List<CardData>? discardPile,
    List<CardData>? exhaustPile,
  }) {
    return DeckState(
      drawPile: drawPile ?? this.drawPile,
      hand: hand ?? this.hand,
      discardPile: discardPile ?? this.discardPile,
      exhaustPile: exhaustPile ?? this.exhaustPile,
    );
  }

  @override
  List<Object?> get props => [drawPile, hand, discardPile, exhaustPile];
}
