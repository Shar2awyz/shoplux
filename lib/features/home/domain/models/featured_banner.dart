import 'package:freezed_annotation/freezed_annotation.dart';

part 'featured_banner.freezed.dart';
part 'featured_banner.g.dart';

/// Derived from the `banners` table (is_active = true).
/// Discount percentage is fetched from the linked `offers` row when target_type = 'offer'.
@freezed
class FeaturedBanner with _$FeaturedBanner {
  const factory FeaturedBanner({
    required String id,
    required String productId,
    required String title,
    @Default('') String subtitle,
    required String imageUrl,
    @Default(0.0) double discountPercentage,
    @Default('Shop Now') String ctaText,
  }) = _FeaturedBanner;

  factory FeaturedBanner.fromJson(Map<String, dynamic> json) =>
      _$FeaturedBannerFromJson(json);

  factory FeaturedBanner.fromSupabase(Map<String, dynamic> json) {
    return FeaturedBanner(
      id: json['id'] as String,
      productId: json['target_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subtitle: '',
      imageUrl: json['image_url'] as String? ?? '',
      discountPercentage:
          (json['discount_percentage'] as num?)?.toDouble() ?? 0.0,
      ctaText: 'Shop Now',
    );
  }
}
