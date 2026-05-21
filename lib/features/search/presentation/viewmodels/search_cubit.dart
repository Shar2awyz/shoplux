import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:shoplux/features/search/domain/repositories/search_repository.dart';
import 'package:shoplux/features/search/presentation/states/search_state.dart';
import 'package:shoplux/features/wishlist/data/wishlist_storage.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit({required SearchRepository repository})
      : _repository = repository,
        super(const SearchState());

  final SearchRepository _repository;
  Timer? _debounce;
  static const int _pageSize = 20;

  Future<void> init() async {
    if (state.categories.isNotEmpty) return;
    try {
      final categories = await _repository.getCategories();
      emit(state.copyWith(categories: categories));
    } catch (_) {}
  }

  void onQueryChanged(String query) {
    _debounce?.cancel();
    if (query.isEmpty) {
      emit(state.copyWith(
        query: '',
        status: SearchStatus.initial,
        results: [],
        currentPage: 0,
        hasMore: true,
        error: null,
      ));
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _runSearch(
        query: query,
        categoryId: state.selectedCategoryId,
        onSaleOnly: state.onSaleOnly,
      );
    });
  }

  void setAllFilter() => _runSearch(
        query: state.query,
        categoryId: null,
        onSaleOnly: false,
      );

  void setCategoryFilter(String categoryId) => _runSearch(
        query: state.query,
        categoryId: categoryId,
        onSaleOnly: false,
      );

  void setOnSaleFilter() => _runSearch(
        query: state.query,
        categoryId: null,
        onSaleOnly: true,
      );

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;

    emit(state.copyWith(isLoadingMore: true));

    try {
      final nextPage = state.currentPage + 1;
      final more = await _repository.searchProducts(
        query: state.query,
        categoryId: state.selectedCategoryId,
        onSaleOnly: state.onSaleOnly,
        page: nextPage,
        pageSize: _pageSize,
      );
      emit(state.copyWith(
        results: [...state.results, ...more],
        isLoadingMore: false,
        hasMore: more.length >= _pageSize,
        currentPage: nextPage,
      ));
    } catch (_) {
      emit(state.copyWith(isLoadingMore: false));
    }
  }

  Future<void> toggleWishlist(String productId) async {
    final index = state.results.indexWhere((p) => p.id == productId);
    if (index == -1) return;

    final product = state.results[index];
    final newWishlistState = !product.isWishlisted;
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';

    final optimistic = List.of(state.results)
      ..[index] = product.copyWith(isWishlisted: newWishlistState);

    emit(state.copyWith(results: optimistic, wishlistError: null));

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
      } catch (_) {
        final rollback = List.of(state.results)
          ..[index] = product;
        emit(state.copyWith(
          results: rollback,
          wishlistError: 'Could not update wishlist. Please try again.',
        ));
      }
    }
  }

  Future<void> _runSearch({
    required String query,
    String? categoryId,
    bool onSaleOnly = false,
  }) async {
    if (query.isEmpty && categoryId == null && !onSaleOnly) {
      emit(state.copyWith(
        status: SearchStatus.initial,
        results: [],
        currentPage: 0,
        hasMore: true,
        error: null,
      ));
      return;
    }

    emit(state.copyWith(
      query: query,
      selectedCategoryId: categoryId,
      onSaleOnly: onSaleOnly,
      status: SearchStatus.loading,
      results: [],
      currentPage: 0,
      hasMore: true,
      error: null,
    ));

    try {
      final results = await _repository.searchProducts(
        query: query,
        categoryId: categoryId,
        onSaleOnly: onSaleOnly,
        page: 0,
        pageSize: _pageSize,
      );
      final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
      final wishlisted = userId.isNotEmpty
          ? await WishlistStorage.loadIds(userId)
          : <String>{};
      final marked = results
          .map((p) => p.copyWith(isWishlisted: wishlisted.contains(p.id)))
          .toList();
      emit(state.copyWith(
        status: SearchStatus.loaded,
        results: marked,
        hasMore: results.length >= _pageSize,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SearchStatus.error,
        error: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
