import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shoplux/features/product_detail/domain/models/product_extras.dart';
import 'package:shoplux/features/product_detail/domain/models/product_variant.dart';

abstract interface class ProductDetailRemoteDataSource {
  Future<ProductExtras> getProductExtras(String productId);

  Future<void> toggleWishlist({
    required String productId,
    required bool isWishlisted,
  });
}

class ProductDetailRemoteDataSourceImpl
    implements ProductDetailRemoteDataSource {
  const ProductDetailRemoteDataSourceImpl({required this.client});

  final SupabaseClient client;

  static const _apparelOrder = [
    'XS', 'S', 'M', 'L', 'XL', 'XXL', 'XXXL', '3XL', '4XL',
  ];

  List<String> _sortSizes(List<String> raw) {
    if (raw.isEmpty) return raw;
    final allNumeric = raw.every((s) => double.tryParse(s) != null);
    if (allNumeric) {
      return raw..sort((a, b) => double.parse(a).compareTo(double.parse(b)));
    }
    final known = _apparelOrder.where(raw.contains).toList();
    final unknown = raw.where((s) => !_apparelOrder.contains(s)).toList();
    return [...known, ...unknown];
  }

  @override
  Future<ProductExtras> getProductExtras(String productId) async {
    // Two separate queries — avoids RLS join issues on product_variants
    final data = await client
        .from('products')
        .select('description, brands(name), categories(name)')
        .eq('id', productId)
        .single();

    final variantsList = await client
        .from('product_variants')
        .select('id, size, color, stock_status')
        .eq('product_id', productId);

    final brandName =
        (data['brands'] as Map<String, dynamic>?)?['name'] as String? ?? '';
    final categoryName =
        (data['categories'] as Map<String, dynamic>?)?['name'] as String? ?? '';
    final description = data['description'] as String? ?? '';

    final variants = variantsList.map((v) {
      return ProductVariant(
        id: v['id'] as String,
        size: (v['size'] as String?)?.trim().isNotEmpty == true
            ? (v['size'] as String).trim()
            : null,
        color: (v['color'] as String?)?.trim().isNotEmpty == true
            ? (v['color'] as String).trim()
            : null,
        stockStatus: v['stock_status'] as String? ?? 'in_stock',
      );
    }).toList();

    final rawSizes = variants
        .map((v) => v.size)
        .whereType<String>()
        .toSet()
        .toList();
    final sizes = _sortSizes(rawSizes);

    final colors = variants
        .map((v) => v.color)
        .whereType<String>()
        .toSet()
        .toList();

    return ProductExtras(
      brandName: brandName,
      categoryName: categoryName,
      description: description,
      sizes: sizes,
      colors: colors,
      variants: variants,
    );
  }

  @override
  Future<void> toggleWishlist({
    required String productId,
    required bool isWishlisted,
  }) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    if (isWishlisted) {
      await client.from('wishlists').upsert(
        {'user_id': userId, 'product_id': productId},
        onConflict: 'user_id,product_id',
        ignoreDuplicates: true,
      );
    } else {
      await client
          .from('wishlists')
          .delete()
          .eq('user_id', userId)
          .eq('product_id', productId);
    }
  }
}
