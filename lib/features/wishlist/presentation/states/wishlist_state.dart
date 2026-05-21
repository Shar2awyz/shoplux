import 'package:shoplux/features/home/domain/models/home_product.dart';

enum WishlistStatus { initial, loading, loaded, error }

class WishlistState {
  const WishlistState({
    this.status = WishlistStatus.initial,
    this.items = const [],
    this.error,
    this.removeError,
  });

  final WishlistStatus status;
  final List<HomeProduct> items;
  final String? error;
  final String? removeError;

  bool get isLoading => status == WishlistStatus.loading;
  bool get isLoaded => status == WishlistStatus.loaded;
  bool get hasError => status == WishlistStatus.error;
  bool get isEmpty => isLoaded && items.isEmpty;

  WishlistState copyWith({
    WishlistStatus? status,
    List<HomeProduct>? items,
    Object? error = _sentinel,
    Object? removeError = _sentinel,
  }) {
    return WishlistState(
      status: status ?? this.status,
      items: items ?? this.items,
      error: error == _sentinel ? this.error : error as String?,
      removeError:
          removeError == _sentinel ? this.removeError : removeError as String?,
    );
  }
}

const _sentinel = Object();
