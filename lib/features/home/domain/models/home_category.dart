import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_category.freezed.dart';
part 'home_category.g.dart';

@freezed
class HomeCategory with _$HomeCategory {
  const factory HomeCategory({
    required String id,
    required String name,
    required String iconUrl,
    @Default('#6C63FF') String color,
    @Default(0) int productCount,
  }) = _HomeCategory;

  factory HomeCategory.fromJson(Map<String, dynamic> json) =>
      _$HomeCategoryFromJson(json);

  factory HomeCategory.fromSupabase(Map<String, dynamic> json) {
    return HomeCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      iconUrl: json['image_url'] as String? ?? '',
      productCount: json['product_count'] as int? ?? 0,
    );
  }
}
