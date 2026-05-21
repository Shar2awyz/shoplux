import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:shoplux/features/wishlist/data/datasources/wishlist_remote_data_source.dart';
import 'package:shoplux/features/wishlist/data/wishlist_storage.dart';
import 'package:shoplux/features/wishlist/presentation/states/wishlist_state.dart';

class WishlistCubit extends Cubit<WishlistState> {
  WishlistCubit({required WishlistRemoteDataSource dataSource})
      : _dataSource = dataSource,
        super(const WishlistState());

  final WishlistRemoteDataSource _dataSource;

  String get _userId =>
      Supabase.instance.client.auth.currentUser?.id ?? '';

  Future<void> load() async {
    emit(state.copyWith(status: WishlistStatus.loading, error: null));
    try {
      final items = await _dataSource.getWishlistItems();
      if (_userId.isNotEmpty) {
        await WishlistStorage.saveAll(_userId, items);
      }
      emit(state.copyWith(status: WishlistStatus.loaded, items: items));
    } catch (_) {
      final items = await WishlistStorage.load(_userId);
      emit(state.copyWith(status: WishlistStatus.loaded, items: items));
    }
  }

  Future<void> removeItem(String productId) async {
    final updated = List.of(state.items)
      ..removeWhere((p) => p.id == productId);
    emit(state.copyWith(items: updated, removeError: null));
    if (_userId.isNotEmpty) {
      await WishlistStorage.remove(_userId, productId);
    }
    try {
      await _dataSource.removeFromWishlist(productId: productId);
    } catch (_) {}
  }

  Future<void> refresh() => load();
}
