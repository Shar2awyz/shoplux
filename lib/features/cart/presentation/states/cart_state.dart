import 'package:shoplux/features/cart/domain/models/cart_item.dart';

enum CartStatus { initial, loading, loaded }

class CartState {
  const CartState({
    this.status = CartStatus.initial,
    this.items = const [],
    this.addedProductName,
  });

  final CartStatus status;
  final List<CartItem> items;
  final String? addedProductName;

  bool get isLoaded => status == CartStatus.loaded;
  bool get isEmpty => items.isEmpty;

  int get totalCount => items.fold(0, (s, i) => s + i.quantity);

  double get subtotal =>
      items.fold(0.0, (s, i) => s + i.originalPrice * i.quantity);

  double get totalDiscount =>
      items.fold(0.0, (s, i) => s + i.lineSavings);

  double get total => subtotal - totalDiscount;

  CartState copyWith({
    CartStatus? status,
    List<CartItem>? items,
    Object? addedProductName = _sentinel,
  }) {
    return CartState(
      status: status ?? this.status,
      items: items ?? this.items,
      addedProductName: addedProductName == _sentinel
          ? this.addedProductName
          : addedProductName as String?,
    );
  }
}

const _sentinel = Object();
