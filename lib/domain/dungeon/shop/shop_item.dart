import 'package:soul_dungeon/core/models/game_enums.dart';

/// 상점 판매 아이템 불변 모델.
/// Equatable 수동 구현 (freezed 미사용).
class ShopItem {
  final String id;
  final String name;
  final String description;
  final ItemType itemType;
  final Rarity rarity;
  final int price;
  final bool sold;

  /// 아이템 효과 타입 (예: 'heal', 'momentum', 'blessing').
  final String? effectType;

  /// 효과 수치 (heal=HP양, momentum=기세양 등).
  final int? effectValue;

  /// 카드 아이템일 때 참조할 카드 ID.
  final String? cardId;

  /// 카드 아이템일 때 AP 코스트 (상점 UI 표시용).
  final int? apCost;

  const ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.itemType,
    required this.rarity,
    required this.price,
    this.sold = false,
    this.effectType,
    this.effectValue,
    this.cardId,
    this.apCost,
  }) : assert(price >= 0, 'price must be non-negative');

  ShopItem copyWith({bool? sold}) {
    return ShopItem(
      id: id,
      name: name,
      description: description,
      itemType: itemType,
      rarity: rarity,
      price: price,
      sold: sold ?? this.sold,
      effectType: effectType,
      effectValue: effectValue,
      cardId: cardId,
      apCost: apCost,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShopItem &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          itemType == other.itemType &&
          rarity == other.rarity &&
          price == other.price &&
          sold == other.sold &&
          effectType == other.effectType &&
          effectValue == other.effectValue &&
          cardId == other.cardId &&
          apCost == other.apCost;

  @override
  int get hashCode => Object.hash(
      id, name, description, itemType, rarity, price, sold, effectType, effectValue, Object.hash(cardId, apCost));

  @override
  String toString() =>
      'ShopItem($id, $name, $rarity, price: $price, sold: $sold)';
}
