import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:shoplux/features/home/domain/models/home_product.dart';
import 'package:shoplux/features/product_detail/domain/repositories/product_detail_repository.dart';
import 'package:shoplux/features/product_detail/presentation/states/product_detail_state.dart';
import 'package:shoplux/features/wishlist/data/wishlist_storage.dart';

class ProductDetailCubit extends Cubit<ProductDetailState> {
  ProductDetailCubit({
    required this.repository,
    required HomeProduct product,
  }) : super(ProductDetailState(product: product));

  final ProductDetailRepository repository;

  Future<void> loadExtras() async {
    try {
      final extras = await repository.getProductExtras(state.product.id);
      // ignore: avoid_print
      print('[ProductDetail] sizes=${extras.sizes} colors=${extras.colors}');
      if (isClosed) return;
      emit(state.copyWith(
        isLoadingExtras: false,
        brandName: extras.brandName,
        categoryName: extras.categoryName,
        description: extras.description,
        sizes: extras.sizes,
        colors: extras.colors,
        selectedSize: extras.sizes.isNotEmpty ? extras.sizes.first : null,
        selectedColor: extras.colors.isNotEmpty ? extras.colors.first : null,
      ));
    } catch (e, st) {
      // ignore: avoid_print
      print('[ProductDetail] loadExtras error: $e\n$st');
      if (isClosed) return;
      emit(state.copyWith(isLoadingExtras: false, error: e.toString()));
    }
  }

  void selectSize(String size) => emit(state.copyWith(selectedSize: size));

  void selectColor(String color) => emit(state.copyWith(selectedColor: color));

  Future<void> toggleWishlist() async {
    final newValue = !state.product.isWishlisted;
    final product = state.product;
    emit(state.copyWith(
      product: product.copyWith(isWishlisted: newValue),
      wishlistError: null,
    ));
    try {
      await repository.toggleWishlist(
        productId: product.id,
        isWishlisted: newValue,
      );
      final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
      if (userId.isNotEmpty) {
        if (newValue) {
          await WishlistStorage.add(
              userId, product.copyWith(isWishlisted: true));
        } else {
          await WishlistStorage.remove(userId, product.id);
        }
      }
    } catch (_) {
      if (isClosed) return;
      emit(state.copyWith(
        product: product.copyWith(isWishlisted: !newValue),
        wishlistError: 'Could not update wishlist. Please try again.',
      ));
    }
  }
}
