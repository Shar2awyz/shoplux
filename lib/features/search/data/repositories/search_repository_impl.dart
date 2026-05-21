import 'package:shoplux/features/home/domain/models/home_category.dart';
import 'package:shoplux/features/home/domain/models/home_product.dart';
import 'package:shoplux/features/search/data/datasources/search_remote_data_source.dart';
import 'package:shoplux/features/search/domain/repositories/search_repository.dart';

class SearchRepositoryImpl implements SearchRepository {
  const SearchRepositoryImpl({required this.dataSource});

  final SearchRemoteDataSource dataSource;

  @override
  Future<List<HomeCategory>> getCategories() => dataSource.getCategories();

  @override
  Future<List<HomeProduct>> searchProducts({
    required String query,
    String? categoryId,
    bool onSaleOnly = false,
    required int page,
    required int pageSize,
  }) =>
      dataSource.searchProducts(
        query: query,
        categoryId: categoryId,
        onSaleOnly: onSaleOnly,
        page: page,
        pageSize: pageSize,
      );

  @override
  Future<void> toggleWishlist({
    required String productId,
    required bool isWishlisted,
  }) =>
      dataSource.toggleWishlist(
        productId: productId,
        isWishlisted: isWishlisted,
      );
}
