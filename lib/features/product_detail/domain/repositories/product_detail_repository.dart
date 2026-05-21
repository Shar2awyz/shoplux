import 'package:shoplux/features/product_detail/domain/models/product_extras.dart';

abstract interface class ProductDetailRepository {
  Future<ProductExtras> getProductExtras(String productId);

  Future<void> toggleWishlist({
    required String productId,
    required bool isWishlisted,
  });
}
