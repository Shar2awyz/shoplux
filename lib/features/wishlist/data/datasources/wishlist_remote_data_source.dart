import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:shoplux/features/home/domain/models/home_product.dart';

abstract interface class WishlistRemoteDataSource {
  Future<List<HomeProduct>> getWishlistItems();
  Future<void> removeFromWishlist({required String productId});
}

class WishlistRemoteDataSourceImpl implements WishlistRemoteDataSource {
  const WishlistRemoteDataSourceImpl({required this.client});

  final SupabaseClient client;

  @override
  Future<List<HomeProduct>> getWishlistItems() async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    // Step 1: get ordered product IDs from wishlists
    final wishlistRows = await client
        .from('wishlists')
        .select('product_id')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    final productIds = (wishlistRows as List<dynamic>)
        .map((r) => (r as Map<String, dynamic>)['product_id'] as String?)
        .whereType<String>()
        .toList();

    if (productIds.isEmpty) return [];

    // Step 2: fetch product details the same way the home feed does
    final productsRows = await client
        .from('products')
        .select(
          'id, name, base_price, sale_price, thumbnail_url, category_id, '
          'average_rating, total_reviews, is_featured',
        )
        .inFilter('id', productIds);

    // Build a map so we can restore the original wishlist order
    final productMap = <String, Map<String, dynamic>>{
      for (final r in productsRows as List<dynamic>)
        (r as Map<String, dynamic>)['id'] as String:
            Map<String, dynamic>.from(r),
    };

    return productIds
        .where(productMap.containsKey)
        .map((id) => HomeProduct.fromSupabase(
              productMap[id]!,
              isWishlisted: true,
            ))
        .toList();
  }

  @override
  Future<void> removeFromWishlist({required String productId}) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    await client
        .from('wishlists')
        .delete()
        .eq('user_id', userId)
        .eq('product_id', productId);
  }
}
