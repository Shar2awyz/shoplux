// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HomeProductImpl _$$HomeProductImplFromJson(Map<String, dynamic> json) =>
    _$HomeProductImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      originalPrice: (json['originalPrice'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      categoryId: json['categoryId'] as String,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      isWishlisted: json['isWishlisted'] as bool? ?? false,
      isTrending: json['isTrending'] as bool? ?? false,
      isFeatured: json['isFeatured'] as bool? ?? false,
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$HomeProductImplToJson(_$HomeProductImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'price': instance.price,
      'originalPrice': instance.originalPrice,
      'imageUrl': instance.imageUrl,
      'categoryId': instance.categoryId,
      'rating': instance.rating,
      'reviewCount': instance.reviewCount,
      'isWishlisted': instance.isWishlisted,
      'isTrending': instance.isTrending,
      'isFeatured': instance.isFeatured,
      'images': instance.images,
    };
