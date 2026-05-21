import 'package:shoplux/features/home/domain/models/featured_banner.dart';
import 'package:shoplux/features/home/domain/models/home_category.dart';
import 'package:shoplux/features/home/domain/models/home_product.dart';

abstract interface class HomeRepository {
  Future<List<HomeCategory>> getCategories();

  Future<List<HomeProduct>> getTrendingProducts({
    required int page,
    required int pageSize,
  });

  Future<FeaturedBanner?> getFeaturedBanner();

  /// [isWishlisted] is the NEW desired state (true = add, false = remove).
  Future<void> toggleWishlist({
    required String productId,
    required bool isWishlisted,
  });
}
