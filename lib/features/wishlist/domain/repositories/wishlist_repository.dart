import 'package:shoplux/features/home/domain/models/home_product.dart';

abstract interface class WishlistRepository {
  Future<List<HomeProduct>> getWishlistItems();
  Future<void> removeFromWishlist({required String productId});
}
