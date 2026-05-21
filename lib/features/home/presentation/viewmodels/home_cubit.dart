import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:shoplux/features/home/domain/repositories/home_repository.dart';
import 'package:shoplux/features/home/presentation/states/home_state.dart';
import 'package:shoplux/features/wishlist/data/wishlist_storage.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({required HomeRepository repository})
      : _repository = repository,
        super(const HomeState());

  final HomeRepository _repository;
  static const int _pageSize = 10;

  Future<void> loadInitial() async {
    emit(state.copyWith(status: HomeStatus.loading));
    try {
      final (categories, products, banner) = await (
        _repository.getCategories(),
        _repository.getTrendingProducts(page: 0, pageSize: _pageSize),
        _repository.getFeaturedBanner(),
      ).wait;

      final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
      final wishlisted = userId.isNotEmpty
          ? await WishlistStorage.loadIds(userId)
          : <String>{};
      final markedProducts = products
          .map((p) => p.copyWith(isWishlisted: wishlisted.contains(p.id)))
          .toList();

      emit(state.copyWith(
        status: HomeStatus.loaded,
        categories: categories,
        trendingProducts: markedProducts,
        featuredBanner: banner,
        hasMoreProducts: products.length >= _pageSize,
        currentPage: 0,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HomeStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  Future<void> loadMoreProducts() async {
    if (state.isLoadingMoreProducts || !state.hasMoreProducts) return;

    emit(state.copyWith(isLoadingMoreProducts: true, loadMoreError: null));

    try {
      final nextPage = state.currentPage + 1;
      final newProducts = await _repository.getTrendingProducts(
        page: nextPage,
        pageSize: _pageSize,
      );
      final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
      final wishlisted = userId.isNotEmpty
          ? await WishlistStorage.loadIds(userId)
          : <String>{};
      final markedNew = newProducts
          .map((p) => p.copyWith(isWishlisted: wishlisted.contains(p.id)))
          .toList();
      emit(state.copyWith(
        trendingProducts: [...state.trendingProducts, ...markedNew],
        isLoadingMoreProducts: false,
        hasMoreProducts: newProducts.length >= _pageSize,
        currentPage: nextPage,
        loadMoreError: null,
      ));
    } catch (_) {
      emit(state.copyWith(
        isLoadingMoreProducts: false,
        loadMoreError: 'Could not load more products',
      ));
    }
  }

  Future<void> toggleWishlist(String productId) async {
    final index =
        state.trendingProducts.indexWhere((p) => p.id == productId);
    if (index == -1) return;

    final product = state.trendingProducts[index];
    final newWishlistState = !product.isWishlisted;
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';

    final optimisticList = List.of(state.trendingProducts)
      ..[index] = product.copyWith(isWishlisted: newWishlistState);

    emit(state.copyWith(trendingProducts: optimisticList, wishlistError: null));

    if (userId.isNotEmpty) {
      try {
        if (newWishlistState) {
          await Supabase.instance.client.from('wishlists').upsert(
            {'user_id': userId, 'product_id': productId},
            onConflict: 'user_id,product_id',
            ignoreDuplicates: true,
          );
          await WishlistStorage.add(
              userId, product.copyWith(isWishlisted: true));
        } else {
          await Supabase.instance.client
              .from('wishlists')
              .delete()
              .eq('user_id', userId)
              .eq('product_id', productId);
          await WishlistStorage.remove(userId, productId);
        }
      } catch (e) {
        // ignore: avoid_print
        print('[WishlistToggle] error: $e');
        final rollback = List.of(state.trendingProducts)
          ..[index] = product;
        emit(state.copyWith(
          trendingProducts: rollback,
          wishlistError: 'Could not update wishlist. Please try again.',
        ));
      }
    }
  }

  Future<void> applyWishlistState(String userId) async {
    if (state.trendingProducts.isEmpty) return;
    final wishlisted = await WishlistStorage.loadIds(userId);
    final updated = state.trendingProducts
        .map((p) => p.copyWith(isWishlisted: wishlisted.contains(p.id)))
        .toList();
    emit(state.copyWith(trendingProducts: updated));
  }

  Future<void> refresh() => loadInitial();
}

