import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoplux/features/cart/domain/models/cart_item.dart';
class CartStorage {
  CartStorage._();

  static String _key(String userId) => 'cart_$userId';

  static Future<List<CartItem>> load(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(userId));
    if (raw == null || raw.isEmpty) return [];
    try {
      return CartItem.listFromJson(raw);
    } catch (_) {
      return [];
    }
  }

  static Future<void> save(String userId, List<CartItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key(userId), CartItem.listToJson(items));
  }

  static Future<void> clear(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(userId));
  }
}
