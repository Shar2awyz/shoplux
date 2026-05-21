import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:shoplux/features/home/domain/models/featured_banner.dart';
import 'package:shoplux/features/home/domain/models/home_category.dart';
import 'package:shoplux/features/home/domain/models/home_product.dart';

part 'home_state.freezed.dart';

enum HomeStatus { initial, loading, loaded, error }

@freezed
class HomeState with _$HomeState {
  const HomeState._();

  const factory HomeState({
    @Default(HomeStatus.initial) HomeStatus status,
    @Default([]) List<HomeCategory> categories,
    @Default([]) List<HomeProduct> trendingProducts,
    FeaturedBanner? featuredBanner,
    @Default(false) bool isLoadingMoreProducts,
    @Default(true) bool hasMoreProducts,
    @Default(0) int currentPage,
    String? errorMessage,
    String? wishlistError,
    String? loadMoreError,
  }) = _HomeState;

  bool get isLoading => status == HomeStatus.loading;
  bool get isLoaded => status == HomeStatus.loaded;
  bool get hasError => status == HomeStatus.error;
}
