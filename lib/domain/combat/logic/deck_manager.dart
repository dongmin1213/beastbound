import 'dart:math';
import 'package:soul_dungeon/core/models/card_data.dart';
import 'package:soul_dungeon/core/logging/game_logger.dart';
import 'package:soul_dungeon/domain/combat/models/deck_state.dart';
/// 덱 조작 — 드로우/셔플/버리기/소진. 순수 함수 (상태 불변).
class DeckManager {
  DeckManager._();

  /// 최대 손패 크기.
  static const int maxHandSize = 15;

  /// 마스터 덱에서 초기 드로우 파일 생성 (셔플).
  static DeckState initialize(List<CardData> masterDeck, {Random? random}) {
    final rng = random ?? Random();
    final shuffled = List<CardData>.from(masterDeck)..shuffle(rng);

    // Innate 카드를 드로우 파일 맨 위로 이동 (먼저 드로우되도록)
    final innate = shuffled.where((c) => c.isInnate).toList();
    final rest = shuffled.where((c) => !c.isInnate).toList();

    return DeckState(drawPile: [...innate, ...rest]);
  }

  /// 드로우 파일에서 [count]장 손패로 이동. 부족하면 버림 더미 셔플.
  static DeckState draw(DeckState state, int count, {Random? random}) {
    final rng = random ?? Random();
    final drawPile = List<CardData>.of(state.drawPile);
    var discardPile = List<CardData>.of(state.discardPile);
    final hand = List<CardData>.of(state.hand);

    for (var i = 0; i < count; i++) {
      if (hand.length >= maxHandSize) break; // 손패 제한
      if (drawPile.isEmpty) {
        if (discardPile.isEmpty) break; // 카드 없음
        // 버림 더미 → 드로우 파일 셔플
        drawPile.addAll(discardPile);
        drawPile.shuffle(rng);
        discardPile = [];
      }
      hand.add(drawPile.removeAt(0));
    }

    return state.copyWith(
      drawPile: drawPile,
      hand: hand,
      discardPile: discardPile,
    );
  }

  /// 손패에서 카드 1장 버림 더미로 이동 (플레이 후).
  /// [handIndex] >= 0이면 해당 인덱스의 카드를 직접 제거 (동일 ID 카드 구분).
  static DeckState discardFromHand(DeckState state, String cardId, {int handIndex = -1}) {
    final hand = List<CardData>.from(state.hand);
    final index = handIndex >= 0 && handIndex < hand.length && hand[handIndex].id == cardId
        ? handIndex
        : hand.indexWhere((c) => c.id == cardId);
    if (index == -1) {
      GameLogger.warning(LogSystem.combat, 'discardFromHand: card $cardId not found in hand');
      return state;
    }

    final card = hand.removeAt(index);
    final discardPile = List<CardData>.from(state.discardPile)..add(card);

    return state.copyWith(hand: hand, discardPile: discardPile);
  }

  /// 손패에서 카드 1장 소진 파일로 이동 (Exhaust).
  /// [handIndex] >= 0이면 해당 인덱스의 카드를 직접 제거 (동일 ID 카드 구분).
  static DeckState exhaustFromHand(DeckState state, String cardId, {int handIndex = -1}) {
    final hand = List<CardData>.from(state.hand);
    final index = handIndex >= 0 && handIndex < hand.length && hand[handIndex].id == cardId
        ? handIndex
        : hand.indexWhere((c) => c.id == cardId);
    if (index == -1) {
      GameLogger.warning(LogSystem.combat, 'exhaustFromHand: card $cardId not found in hand');
      return state;
    }

    final card = hand.removeAt(index);
    final exhaustPile = List<CardData>.from(state.exhaustPile)..add(card);

    return state.copyWith(hand: hand, exhaustPile: exhaustPile);
  }

  /// 턴 종료 — 남은 손패 전부 버림 더미로 (Retain 키워드 카드 제외).
  static DeckState endTurnDiscard(DeckState state) {
    final retained = <CardData>[];
    final discarded = <CardData>[];
    final exhausted = <CardData>[];

    for (final card in state.hand) {
      if (card.isRetain) {
        retained.add(card);
      } else if (card.isEthereal) {
        exhausted.add(card);
      } else {
        discarded.add(card);
      }
    }

    return state.copyWith(
      hand: retained,
      discardPile: [...state.discardPile, ...discarded],
      exhaustPile: [...state.exhaustPile, ...exhausted],
    );
  }

  /// 손패에 카드 추가 (보상/효과 등). 손패 제한 초과 시 버림 더미로.
  static DeckState addToHand(DeckState state, CardData card) {
    if (state.hand.length >= maxHandSize) {
      return state.copyWith(
        discardPile: [...state.discardPile, card],
      );
    }
    return state.copyWith(
      hand: [...state.hand, card],
    );
  }

  /// 손패 전부 버리기 (마나 순환 등).
  static DeckState discardEntireHand(DeckState state) {
    return state.copyWith(
      hand: [],
      discardPile: [...state.discardPile, ...state.hand],
    );
  }

  /// 모든 카드를 드로우 파일로 리셔플 (보스 페이즈 전환 등).
  /// 손패 + 버림 더미 → 드로우 파일 (소진 카드 제외).
  static DeckState reshuffleAll(DeckState state, {Random? random}) {
    final rng = random ?? Random();
    final allCards = [
      ...state.hand,
      ...state.drawPile,
      ...state.discardPile,
    ]..shuffle(rng);

    return state.copyWith(
      drawPile: allCards,
      hand: [],
      discardPile: [],
    );
  }
}
