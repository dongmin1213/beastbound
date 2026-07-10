import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soul_dungeon/core/events/game_event_bus.dart';
import 'package:soul_dungeon/core/events/shop_purchase_event.dart';
import 'package:soul_dungeon/domain/dungeon/shop/shop_event.dart';
import 'package:soul_dungeon/domain/dungeon/shop/shop_state.dart';

/// 상점 Bloc — 생성자 주입, 3파일 분리.
/// 상점 아이템 구매 로직 담당. presentation 의존 없음.
class ShopBloc extends Bloc<ShopEvent, ShopState> {
  final GameEventBus gameEventBus;

  ShopBloc({required this.gameEventBus}) : super(const ShopInitial()) {
    on<OpenShop>(_onOpenShop);
    on<PurchaseItem>(_onPurchaseItem);
    on<LeaveShop>(_onLeaveShop);
  }

  void _onOpenShop(OpenShop event, Emitter<ShopState> emit) {
    emit(ShopReady(
      items: event.items,
      gold: event.playerGold,
      purchasedItems: const [],
    ));
  }

  void _onPurchaseItem(PurchaseItem event, Emitter<ShopState> emit) {
    final currentState = state;
    if (currentState is! ShopReady) return;

    final index = event.index;

    // 범위 검증
    if (index < 0 || index >= currentState.items.length) return;

    final item = currentState.items[index];

    // 이미 판매됨
    if (item.sold) return;

    // 골드 부족
    if (currentState.gold < item.price) return;

    // 구매 성공
    final updatedItems = List.of(currentState.items);
    updatedItems[index] = item.copyWith(sold: true);
    final newGold = currentState.gold - item.price;

    emit(ShopReady(
      items: updatedItems,
      gold: newGold,
      purchasedItems: [...currentState.purchasedItems, item.copyWith(sold: true)],
    ));

    // ShopPurchaseEvent GameEventBus 발행
    gameEventBus.emit(ShopPurchaseEvent(
      itemId: item.id,
      itemName: item.name,
      price: item.price,
      remainingGold: newGold,
    ));
  }

  void _onLeaveShop(LeaveShop event, Emitter<ShopState> emit) {
    final currentState = state;
    if (currentState is! ShopReady) return;

    emit(ShopClosed(
      remainingGold: currentState.gold,
      purchasedItems: currentState.purchasedItems,
    ));
  }
}
