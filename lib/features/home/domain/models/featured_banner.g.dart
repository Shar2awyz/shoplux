// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'featured_banner.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FeaturedBannerImpl _$$FeaturedBannerImplFromJson(Map<String, dynamic> json) =>
    _$FeaturedBannerImpl(
      id: json['id'] as String,
      productId: json['productId'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String? ?? '',
      imageUrl: json['imageUrl'] as String,
      discountPercentage:
          (json['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      ctaText: json['ctaText'] as String? ?? 'Shop Now',
    );

Map<String, dynamic> _$$FeaturedBannerImplToJson(
  _$FeaturedBannerImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'productId': instance.productId,
  'title': instance.title,
  'subtitle': instance.subtitle,
  'imageUrl': instance.imageUrl,
  'discountPercentage': instance.discountPercentage,
  'ctaText': instance.ctaText,
};
