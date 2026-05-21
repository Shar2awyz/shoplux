import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:shoplux/features/home/domain/models/home_category.dart';
import 'package:shoplux/features/home/domain/models/home_product.dart';

abstract interface class SearchRemoteDataSource {
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

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  const SearchRemoteDataSourceImpl({required this.client});

  final SupabaseClient client;

  @override
  Future<List<HomeCategory>> getCategories() async {
    final data = await client
        .from('categories')
        .select('id, name, image_url')
        .order('name', ascending: true);

    return (data as List<dynamic>).map((row) {
      final map = Map<String, dynamic>.from(row as Map);
      return HomeCategory.fromSupabase({...map, 'product_count': 0});
    }).toList();
  }

  @override
  Future<List<HomeProduct>> searchProducts({
    required String query,
    String? categoryId,
    bool onSaleOnly = false,
    required int page,
    required int pageSize,
  }) async {
    final offset = page * pageSize;
    final userId = client.auth.currentUser?.id;

    var dbQuery = client
        .from('products')
        .select(
          'id, name, base_price, sale_price, thumbnail_url, category_id, '
          'average_rating, total_reviews, is_trending, is_featured',
        )
        .eq('is_active', true);

    if (query.isNotEmpty) {
      dbQuery = dbQuery.ilike('name', '%$query%');
    }

    if (categoryId != null) {
      dbQuery = dbQuery.eq('category_id', categoryId);
    }

    if (onSaleOnly) {
      dbQuery = dbQuery.not('sale_price', 'is', null);
    }

    final productsData = await dbQuery
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
