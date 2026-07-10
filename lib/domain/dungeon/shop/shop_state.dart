import 'package:equatable/equatable.dart';
import 'package:soul_dungeon/domain/dungeon/shop/shop_item.dart';

/// ShopBloc 상태 — sealed class (Dart 3 switch exhaustiveness).
sealed class ShopState extends Equatable {
  const ShopState();
}

/// 초기 상태 — 상점 미오픈.
final class ShopInitial extends ShopState {
  const ShopInitial();

  @override
  List<Object?> get props => [];
}

/// 상점 준비 완료 — 아이템 목록, 보유 금화, 구매 완료 아이템.
final class ShopReady extends ShopState {
  final List<ShopItem> items;
  final int gold;
  final List<ShopItem> purchasedItems;

  const ShopReady({
    required this.items,
    required this.gold,
    required this.purchasedItems,
  });

  @override
  List<Object?> get props => [items, gold, purchasedItems];
}

/// 상점 종료 — 잔여 금화, 구매 아이템 목록.
final class ShopClosed extends ShopState {
  final int remainingGold;
  final List<ShopItem> purchasedItems;

  const ShopClosed({
    required this.remainingGold,
    required this.purchasedItems,
  });

  @override
  List<Object?> get props => [remainingGold, purchasedItems];
}
