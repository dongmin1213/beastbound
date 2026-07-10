import 'package:soul_dungeon/domain/dungeon/shop/shop_item.dart';

/// ShopBloc 이벤트 — sealed class (Dart 3 switch exhaustiveness).
sealed class ShopEvent {
  const ShopEvent();
}

/// 상점 오픈 — 아이템 목록과 플레이어 보유 금화로 초기화.
final class OpenShop extends ShopEvent {
  final List<ShopItem> items;
  final int playerGold;

  const OpenShop({required this.items, required this.playerGold});
}

/// 아이템 구매 시도 — index로 지정.
final class PurchaseItem extends ShopEvent {
  final int index;

  const PurchaseItem(this.index);
}

/// 상점 나가기 — 탐색으로 복귀.
final class LeaveShop extends ShopEvent {
  const LeaveShop();
}
