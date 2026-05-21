import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shoplux/features/cart/domain/models/cart_item.dart';
import 'package:shoplux/features/notifications/data/notification_repository.dart';

class OrderRepository {
  static final _db = Supabase.instance.client;

  static Future<String> placeOrder({
    required String userId,
    required List<CartItem> items,
    required double subtotal,
    required double discountAmount,
    required double total,
    required String shippingAddress,
    String paymentMethod = 'cash',
  }) async {
    final orderRow = await _db
        .from('orders')
        .insert({
          'user_id': userId,
          'payment_method': paymentMethod,
          'payment_status': paymentMethod == 'cash' ? 'pending' : 'paid',
          'order_status': 'pending',
          'subtotal': subtotal,
          'shipping_fee': 0,
          'discount_amount': discountAmount,
          'total_amount': total,
          'shipping_address': shippingAddress,
        })
        .select('id')
        .single();

    final orderId = orderRow['id'] as String;

    await _db.from('order_items').insert(
          items
              .map((item) => {
                    'order_id': orderId,
                    'product_id': item.productId,
                    'quantity': item.quantity,
                    'price': item.price,
                    'total_price': item.lineTotal,
                    if (item.variant != null) 'selected_size': item.variant,
                    if (item.selectedColor != null)
                      'selected_color': item.selectedColor,
                  })
              .toList(),
        );

    try {
      final itemCount = items.fold(0, (s, i) => s + i.quantity);
      await NotificationRepository.insert(
        userId: userId,
        orderId: orderId,
        title: 'Order Placed 🎉',
        body:
            '$itemCount ${itemCount == 1 ? 'item' : 'items'} · \$${_fmt(total)}',
        type: 'order_placed',
      );
    } catch (_) {}

    return orderId;
  }

  static String _fmt(double v) =>
      v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(2);
}
