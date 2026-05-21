import 'package:shoplux/features/home/domain/models/home_category.dart';
import 'package:shoplux/features/home/domain/models/home_product.dart';

enum SearchStatus { initial, loading, loaded, error }

class SearchState {
  const SearchState({
    this.query = '',
    this.selectedCategoryId,
    this.onSaleOnly = false,
    this.results = const [],
    this.categories = const [],
    this.status = SearchStatus.initial,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.currentPage = 0,
    this.error,
    this.wishlistError,
  });

  final String query;
  final String? selectedCategoryId;
  final bool onSaleOnly;
  final List<HomeProduct> results;
  final List<HomeCategory> categories;
  final SearchStatus status;
  final bool isLoadingMore;
  final bool hasMore;
  final int currentPage;
  final String? error;
  final String? wishlistError;

  bool get isLoading => status == SearchStatus.loading;
  bool get isLoaded => status == SearchStatus.loaded;
  bool get hasError => status == SearchStatus.error;
  bool get isEmpty => isLoaded && results.isEmpty;
  bool get isInitial => status == SearchStatus.initial;

  SearchState copyWith({
    String? query,
    Object? selectedCategoryId = _sentinel,
    bool? onSaleOnly,
    List<HomeProduct>? results,
    List<HomeCategory>? categories,
    SearchStatus? status,
    bool? isLoadingMore,
    bool? hasMore,
    int? currentPage,
    Object? error = _sentinel,
    Object? wishlistError = _sentinel,
  }) {
    return SearchState(
      query: query ?? this.query,
      selectedCategoryId: selectedCategoryId == _sentinel
          ? this.selectedCategoryId
          : selectedCategoryId as String?,
      onSaleOnly: onSaleOnly ?? this.onSaleOnly,
      results: results ?? this.results,
      categories: categories ?? this.categories,
      status: status ?? this.status,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      error: error == _sentinel ? this.error : error as String?,
      wishlistError: wishlistError == _sentinel
          ? this.wishlistError
          : wishlistError as String?,
    );
  }
}

const _sentinel = Object();
