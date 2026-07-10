import 'package:soul_dungeon/core/events/game_event.dart';

/// 상점 아이템 구매 이벤트 — ShopBloc이 구매 성공 시 GameEventBus를 통해 발행.
/// primitive/String 타입만 사용 — core → domain 역방향 의존 방지.
/// 향후 인벤토리/세이브 시스템 연동용.
class ShopPurchaseEvent extends GameEvent {
  final String itemId;
  final String itemName;
  final int price;
  final int remainingGold;

  ShopPurchaseEvent({
    required this.itemId,
    required this.itemName,
    required this.price,
    required this.remainingGold,
  });

  @override
  String toString() =>
      'ShopPurchaseEvent(itemId: $itemId, itemName: $itemName, price: $price, remainingGold: $remainingGold)';
}
