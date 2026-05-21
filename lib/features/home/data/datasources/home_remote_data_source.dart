import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:shoplux/features/home/domain/models/featured_banner.dart';
import 'package:shoplux/features/home/domain/models/home_category.dart';
import 'package:shoplux/features/home/domain/models/home_product.dart';

abstract interface class HomeRemoteDataSource {
  Future<List<HomeCategory>> getCategories();

  Future<List<HomeProduct>> getTrendingProducts({
    required int page,
    required int pageSize,
  });

  Future<FeaturedBanner?> getFeaturedBanner();

  Future<void> toggleWishlist({
    required String productId,
    required bool isWishlisted,
  });
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  const HomeRemoteDataSourceImpl({required this.client});

  final SupabaseClient client;

  @override
  Future<List<HomeCategory>> getCategories() async {
    final data = await client
        .from('categories')
        .select('id, name, image_url, products(count)')
        .order('name', ascending: true);

    return (data as List<dynamic>).map((row) {
      final map = Map<String, dynamic>.from(row as Map);
      final countList = map['products'] as List<dynamic>?;
      final count = countList?.isNotEmpty == true
          ? (countList!.first as Map<String, dynamic>)['count'] as int? ?? 0
          : 0;
      return HomeCategory.fromSupabase({...map, 'product_count': count});
    }).toList();
  }

  @override
  Future<List<HomeProduct>> getTrendingProducts({
    required int page,
    required int pageSize,
  }) async {
    final offset = page * pageSize;
    final userId = client.auth.currentUser?.id;

    final productsData = await client
        .from('products')
        .select(
          'id, name, base_price, sale_price, thumbnail_url, category_id, '
          'average_rating, total_reviews, is_featured',
        )
        .eq('is_active', true)
        .order('average_rating', ascending: false)
        .range(offset, offset + pageSize - 1);

    final wishlistedIds = await _fetchWishlistedIds(userId);

    return (productsData as List<dynamic>).map((row) {
      final map = Map<String, dynamic>.from(row as Map);
      return HomeProduct.fromSupabase(
        map,
        isWishlisted: wishlistedIds.contains(map['id'] as String),
      );
    }).toList();
  }

  @override
  Future<FeaturedBanner?> getFeaturedBanner() async {
    final bannerData = await client
        .from('banners')
        .select('id, title, image_url, target_type, target_id')
        .eq('is_active', true)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (bannerData == null) return null;

    double discountPercentage = 0.0;
    final targetType = bannerData['target_type'] as String?;
    final targetId = bannerData['target_id'] as String?;

    if (targetType == 'offer' && targetId != null) {
      final offerData = await client
          .from('offers')
          .select('discount_percentage')
          .eq('id', targetId)
          .eq('is_active', true)
          .maybeSingle();

      if (offerData != null) {
        discountPercentage =
            (offerData['discount_percentage'] as num?)?.toDouble() ?? 0.0;
      }
    }

    return FeaturedBanner.fromSupabase({
      ...bannerData,
      'discount_percentage': discountPercentage,
    });
  }

  @override
  Future<void> toggleWishlist({
    required String productId,
    required bool isWishlisted,
  }) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    if (isWishlisted) {
      await client.from('wishlists').insert({
        'user_id': userId,
        'product_id': productId,
      });
    } else {
      await client
          .from('wishlists')
          .delete()
          .eq('user_id', userId)
          .eq('product_id', productId);
    }
  }

  Future<Set<String>> _fetchWishlistedIds(String? userId) async {
    if (userId == null) return {};
    final data = await client
        .from('wishlists')
        .select('product_id')
        .eq('user_id', userId);
    return (data as List<dynamic>)
        .map((row) => (row as Map<String, dynamic>)['product_id'] as String)
        .toSet();
  }
}
