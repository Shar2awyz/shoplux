import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:shoplux/features/home/data/datasources/home_remote_data_source.dart';
import 'package:shoplux/features/home/domain/models/featured_banner.dart';
import 'package:shoplux/features/home/domain/models/home_category.dart';
import 'package:shoplux/features/home/domain/models/home_product.dart';
import 'package:shoplux/features/home/domain/repositories/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl({required this.dataSource});

  final HomeRemoteDataSource dataSource;

  @override
  Future<List<HomeCategory>> getCategories() async {
    try {
      return await dataSource.getCategories();
    } on PostgrestException catch (e) {
      throw Exception('Failed to load categories: ${e.message}');
    }
  }

  @override
  Future<List<HomeProduct>> getTrendingProducts({
    required int page,
    required int pageSize,
  }) async {
    try {
      return await dataSource.getTrendingProducts(
        page: page,
        pageSize: pageSize,
      );
    } on PostgrestException catch (e) {
      throw Exception('Failed to load products: ${e.message}');
    }
  }

  @override
  Future<FeaturedBanner?> getFeaturedBanner() async {
    try {
      return await dataSource.getFeaturedBanner();
    } on PostgrestException catch (e) {
      throw Exception('Failed to load banner: ${e.message}');
    }
  }

  @override
  Future<void> toggleWishlist({
    required String productId,
    required bool isWishlisted,
  }) async {
    try {
      await dataSource.toggleWishlist(
        productId: productId,
        isWishlisted: isWishlisted,
      );
    } on PostgrestException catch (e) {
      throw Exception('Failed to update wishlist: ${e.message}');
    }
  }
}
