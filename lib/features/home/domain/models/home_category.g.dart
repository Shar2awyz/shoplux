// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HomeCategoryImpl _$$HomeCategoryImplFromJson(Map<String, dynamic> json) =>
    _$HomeCategoryImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      iconUrl: json['iconUrl'] as String,
      color: json['color'] as String? ?? '#6C63FF',
      productCount: (json['productCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$HomeCategoryImplToJson(_$HomeCategoryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'iconUrl': instance.iconUrl,
      'color': instance.color,
      'productCount': instance.productCount,
    };
