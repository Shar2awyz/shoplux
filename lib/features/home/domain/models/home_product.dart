import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_product.freezed.dart';
part 'home_product.g.dart';

@freezed
class HomeProduct with _$HomeProduct {
  const HomeProduct._();

  const factory HomeProduct({
    required String id,
    required String name,
    required double price,
    required double originalPrice,
    required String imageUrl,
    required String categoryId,
    @Default(0.0) double rating,
    @Default(0) int reviewCount,
    @Default(false) bool isWishlisted,
    @Default(false) bool isTrending,
    @Default(false) bool isFeatured,
    @Default([]) List<String> images,
  }) = _HomeProduct;

  factory HomeProduct.fromJson(Map<String, dynamic> json) =>
      _$HomeProductFromJson(json);

  factory HomeProduct.fromSupabase(
    Map<String, dynamic> json, {
    bool isWishlisted = false,
  }) {
    final basePrice = (json['base_price'] as num).toDouble();
    final salePrice = (json['sale_price'] as num?)?.toDouble();

    // base_price = full price, sale_price = discounted price (lower)
    final price = salePrice ?? basePrice;
    final originalPrice = basePrice;

    return HomeProduct(
      id: json['id'] as String,
      name: json['name'] as String,
      price: price,
      originalPrice: originalPrice,
      imageUrl: json['thumbnail_url'] as String? ?? '',
      categoryId: json['category_id'] as String? ?? '',
      rating: (json['average_rating'] as num? ?? 0).toDouble(),
      reviewCount: json['total_reviews'] as int? ?? 0,
      isTrending: true,
      isFeatured: json['is_featured'] as bool? ?? false,
      isWishlisted: isWishlisted,
    );
  }

  double get discountPercentage {
    if (originalPrice <= price) return 0.0;
    return ((originalPrice - price) / originalPrice * 100).roundToDouble();
  }

  bool get hasDiscount => originalPrice > price;
}
