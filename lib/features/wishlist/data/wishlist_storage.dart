import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:shoplux/features/home/domain/models/home_product.dart';

class WishlistStorage {
  WishlistStorage._();

  static String _key(String userId) => 'wishlist_$userId';

  static Future<List<HomeProduct>> load(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(userId));
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => _fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<Set<String>> loadIds(String userId) async {
    final items = await load(userId);
    return items.map((p) => p.id).toSet();
  }

  static Future<void> add(String userId, HomeProduct product) async {
    final items = await load(userId);
    if (items.any((p) => p.id == product.id)) return;
    items.insert(0, product);
    await _save(userId, items);
  }

  static Future<void> remove(String userId, String productId) async {
    final items = await load(userId);
    items.removeWhere((p) => p.id == productId);
    await _save(userId, items);
  }

  static Future<void> saveAll(String userId, List<HomeProduct> items) =>
      _save(userId, items);

  static Future<void> _save(String userId, List<HomeProduct> items) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(items.map(_toJson).toList());
    await prefs.setString(_key(userId), json);
  }

  static Map<String, dynamic> _toJson(HomeProduct p) => {
        'id': p.id,
        'name': p.name,
        'price': p.price,
        'originalPrice': p.originalPrice,
        'imageUrl': p.imageUrl,
        'categoryId': p.categoryId,
        'rating': p.rating,
        'reviewCount': p.reviewCount,
      };

  static HomeProduct _fromJson(Map<String, dynamic> json) => HomeProduct(
        id: json['id'] as String,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
        originalPrice: (json['originalPrice'] as num).toDouble(),
        imageUrl: json['imageUrl'] as String? ?? '',
        categoryId: json['categoryId'] as String? ?? '',
        rating: (json['rating'] as num? ?? 0).toDouble(),
        reviewCount: json['reviewCount'] as int? ?? 0,
        isWishlisted: true,
      );
}
