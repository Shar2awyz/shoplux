import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:shoplux/features/cart/data/cart_storage.dart';
import 'package:shoplux/features/cart/domain/models/cart_item.dart';
import 'package:shoplux/features/cart/presentation/states/cart_state.dart';
import 'package:shoplux/features/home/domain/models/home_product.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(const CartState());

  String? _userId;

  Future<void> load(String userId) async {
    _userId = userId;
    emit(state.copyWith(status: CartStatus.loading));
    final items = await CartStorage.load(userId);
    emit(state.copyWith(status: CartStatus.loaded, items: items));
  }

  Future<void> addItem(
    HomeProduct product, {
    String? selectedSize,
    String? selectedColor,
  }) async {
    if (_userId == null) return;

    final items = List.of(state.items);
    final idx = items.indexWhere(
      (i) =>
          i.productId == product.id &&
          i.variant == selectedSize &&
          i.selectedColor == selectedColor,
    );

    if (idx != -1) {
      items[idx] = items[idx].copyWith(quantity: items[idx].quantity + 1);
    } else {
      items.add(CartItem(
        productId: product.id,
        name: product.name,
        price: product.price,
        originalPrice: product.originalPrice,
        imageUrl: product.imageUrl,
        variant: selectedSize,
        selectedColor: selectedColor,
      ));
    }

    emit(state.copyWith(
      items: items,
      addedProductName: product.name,
    ));
    await CartStorage.save(_userId!, items);
  }

  Future<void> removeItem(String productId) async {
    if (_userId == null) return;
    final items = List.of(state.items)
      ..removeWhere((i) => i.productId == productId);
    emit(state.copyWith(items: items, addedProductName: null));
    await CartStorage.save(_userId!, items);
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    if (quantity <= 0) {
      await removeItem(productId);
      return;
    }
    if (_userId == null) return;
    final items = List.of(state.items);
    final idx = items.indexWhere((i) => i.productId == productId);
    if (idx == -1) return;
    items[idx] = items[idx].copyWith(quantity: quantity);
    emit(state.copyWith(items: items));
    await CartStorage.save(_userId!, items);
  }

  Future<void> clearCart() async {
    if (_userId == null) return;
    emit(state.copyWith(items: [], addedProductName: null));
    await CartStorage.save(_userId!, []);
  }

  void clearAddedFeedback() => emit(state.copyWith(addedProductName: null));
}
