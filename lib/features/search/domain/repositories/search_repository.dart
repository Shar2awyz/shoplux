import 'package:shoplux/features/home/domain/models/home_category.dart';
import 'package:shoplux/features/home/domain/models/home_product.dart';

abstract interface class SearchRepository {
  Future<List<HomeCategory>> getCategories();

  Future<List<HomeProduct>> searchProducts({
    required String query,
    String? categoryId,
    bool onSaleOnly = false,
    required int page,
    required int pageSize,
  });

  Future<void> toggleWishlist({
    required String productId,
    required bool isWishlisted,
  });
}
