import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shoplux/constants/AppColors.dart';
import 'package:shoplux/core/app_color_scheme.dart';

// ─── Data models ──────────────────────────────────────────────────────────────

class _OrderProduct {
  final String name;
  final String? thumbnailUrl;
  final int quantity;
  final double price;

  const _OrderProduct({
    required this.name,
    this.thumbnailUrl,
    required this.quantity,
    required this.price,
  });
}

class _Order {
  final String id;
  final DateTime createdAt;
  final double totalAmount;
  final double discountAmount;
  final double shippingFee;
  final String orderStatus;
  final String paymentStatus;
  final String paymentMethod;
  final String? shippingAddress;
  final List<_OrderProduct> products;

  const _Order({
    required this.id,
    required this.createdAt,
    required this.totalAmount,
    required this.discountAmount,
    required this.shippingFee,
    required this.orderStatus,
    required this.paymentStatus,
    required this.paymentMethod,
    this.shippingAddress,
    required this.products,
  });

  String get displayId {
    final year = createdAt.year;
    final suffix = id.replaceAll('-', '').substring(0, 5).toUpperCase();
    return '#SL-$year-$suffix';
  }

  factory _Order.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['order_items'] as List<dynamic>?) ?? [];
    final products = rawItems.map((item) {
      final product = item['products'] as Map<String, dynamic>?;
      return _OrderProduct(
        name: product?['name'] as String? ?? 'Product',
        thumbnailUrl: product?['thumbnail_url'] as String?,
        quantity: (item['quantity'] as num).toInt(),
        price: (item['price'] as num).toDouble(),
      );
    }).toList();

    return _Order(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      totalAmount: (json['total_amount'] as num).toDouble(),
      discountAmount: (json['discount_amount'] as num? ?? 0).toDouble(),
      shippingFee: (json['shipping_fee'] as num? ?? 0).toDouble(),
      orderStatus: json['order_status'] as String? ?? 'pending',
      paymentStatus: json['payment_status'] as String? ?? 'pending',
      paymentMethod: json['payment_method'] as String? ?? 'cash',
      shippingAddress: json['shipping_address'] as String?,
      products: products,
    );
  }
}

// ─── Page ─────────────────────────────────────────────────────────────────────

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  List<_Order> _orders = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('Not logged in');

      final data = await Supabase.instance.client
          .from('orders')
          .select(
            'id, created_at, total_amount, discount_amount, shipping_fee, '
            'order_status, payment_status, payment_method, shipping_address, '
            'order_items(quantity, price, products(name, thumbnail_url))',
          )
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _orders = (data as List<dynamic>)
              .map((e) => _Order.fromJson(e as Map<String, dynamic>))
              .toList();
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  List<({String label, List<_Order> orders})> get _grouped {
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);
    final yesterday =
        DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 1)));

    final Map<String, List<_Order>> map = {};
    for (final order in _orders) {
      final key = DateFormat('yyyy-MM-dd').format(order.createdAt);
      (map[key] ??= []).add(order);
    }

    return map.entries.map((e) {
      String label;
      if (e.key == today) {
        label = 'Today';
      } else if (e.key == yesterday) {
        label = 'Yesterday';
      } else {
        label = DateFormat('MMM d, yyyy').format(DateTime.parse(e.key));
      }
      return (label: label, orders: e.value);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: colors.text, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Orders',
          style: TextStyle(
              color: colors.text, fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : _error != null
              ? _ErrorState(onRetry: _load)
              : _orders.isEmpty
                  ? const _EmptyState()
                  : RefreshIndicator(
                      color: AppColors.primary,
                      backgroundColor: colors.fieldBackground,
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        itemCount: _grouped.fold<int>(
                            0, (s, g) => s + 1 + g.orders.length),
                        itemBuilder: (context, index) {
                          int cursor = 0;
                          for (final group in _grouped) {
                            if (index == cursor) {
                              return _DateHeader(label: group.label);
                            }
                            cursor++;
                            for (final order in group.orders) {
                              if (index == cursor) {
                                return _OrderCard(order: order);
                              }
                              cursor++;
                            }
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
    );
  }
}

// ─── Date header ──────────────────────────────────────────────────────────────

class _DateHeader extends StatelessWidget {
  final String label;
  const _DateHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 10),
      child: Text(
        label,
        style: TextStyle(
          color: context.colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ─── Order card ───────────────────────────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  final _Order order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final time = DateFormat('MMM d · h:mm a').format(order.createdAt);
    final totalItems = order.products.fold(0, (s, p) => s + p.quantity);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: colors.fieldBackground,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.displayId,
                  style: TextStyle(
                    color: colors.text,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
                _StatusBadge(status: order.orderStatus),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
            child: Text(
              time,
              style: TextStyle(color: colors.grey, fontSize: 12),
            ),
          ),

          // ── Thumbnails ──────────────────────────────
          if (order.products.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _ThumbnailRow(products: order.products),
            ),

          // ── Item names ──────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Text(
              _itemsSummary(order.products),
              style: TextStyle(color: colors.grey, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          Divider(color: colors.divider, height: 1, thickness: 0.5),

          // ── Tracking timeline ────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: _StatusTimeline(order: order),
          ),

          Divider(color: colors.divider, height: 1, thickness: 0.5),

          // ── Footer: qty + total ─────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$totalItems ${totalItems == 1 ? 'item' : 'items'}',
                  style: TextStyle(color: colors.grey, fontSize: 13),
                ),
                Text(
                  '\$${_fmt(order.totalAmount)}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _itemsSummary(List<_OrderProduct> products) {
    if (products.isEmpty) return '';
    final names = products
        .map((p) => p.quantity > 1 ? '${p.name} ×${p.quantity}' : p.name)
        .toList();
    if (names.length <= 2) return names.join(', ');
    return '${names.take(2).join(', ')} +${names.length - 2} more';
  }
}

// ─── Status tracking timeline ─────────────────────────────────────────────────

class _StatusTimeline extends StatelessWidget {
  final _Order order;
  const _StatusTimeline({required this.order});

  static const _statusOrder = [
    'pending',
    'confirmed',
    'processing',
    'shipped',
    'delivered',
  ];

  @override
  Widget build(BuildContext context) {
    final isCancelled = order.orderStatus == 'cancelled';
    final currentIdx = isCancelled ? 0 : _statusOrder.indexOf(order.orderStatus);

    final steps = isCancelled
        ? [
            _StepData(
              icon: Icons.receipt_long_outlined,
              label: 'Order Placed',
              detail: DateFormat('MMM d, h:mm a').format(order.createdAt),
              state: _StepState.done,
            ),
            _StepData(
              icon: Icons.cancel_outlined,
              label: 'Order Cancelled',
              detail: null,
              state: _StepState.failed,
            ),
          ]
        : [
            _StepData(
              icon: Icons.receipt_long_outlined,
              label: 'Order Placed',
              detail: DateFormat('MMM d, h:mm a').format(order.createdAt),
              state: _StepState.done,
            ),
            _StepData(
              icon: order.paymentMethod == 'cash'
                  ? Icons.payments_outlined
                  : Icons.credit_card_outlined,
              label: order.paymentMethod == 'cash'
                  ? 'Cash on Delivery'
                  : 'Payment',
              detail: order.paymentMethod == 'cash'
                  ? 'Pay on arrival'
                  : _paymentStatusLabel(order.paymentStatus),
              state: order.paymentMethod == 'cash'
                  ? _StepState.done
                  : order.paymentStatus == 'paid'
                      ? _StepState.done
                      : order.paymentStatus == 'failed'
                          ? _StepState.failed
                          : _StepState.pending,
            ),
            _StepData(
              icon: Icons.inventory_2_outlined,
              label: 'Processing',
              detail: null,
              state: currentIdx >= 2 ? _StepState.done : _StepState.pending,
            ),
            _StepData(
              icon: Icons.local_shipping_outlined,
              label: 'Shipped',
              detail: null,
              state: currentIdx >= 3
                  ? _StepState.done
                  : currentIdx == 2
                      ? _StepState.active
                      : _StepState.pending,
            ),
            _StepData(
              icon: Icons.home_outlined,
              label: 'Delivered',
              detail: null,
              state: currentIdx >= 4 ? _StepState.done : _StepState.pending,
            ),
          ];

    return Column(
      children: [
        for (int i = 0; i < steps.length; i++)
          _StepRow(
            data: steps[i],
            isLast: i == steps.length - 1,
          ),
      ],
    );
  }

  String _paymentStatusLabel(String s) => switch (s) {
        'paid' => 'Paid',
        'failed' => 'Failed',
        'refunded' => 'Refunded',
        _ => 'Pending',
      };
}

enum _StepState { done, active, pending, failed }

class _StepData {
  final IconData icon;
  final String label;
  final String? detail;
  final _StepState state;
  const _StepData(
      {required this.icon,
      required this.label,
      required this.state,
      this.detail});
}

class _StepRow extends StatelessWidget {
  final _StepData data;
  final bool isLast;
  const _StepRow({required this.data, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dotColor = switch (data.state) {
      _StepState.done => const Color(0xff4CAF50),
      _StepState.active => AppColors.primary,
      _StepState.failed => const Color(0xffEF5350),
      _StepState.pending => colors.grey.withValues(alpha: 0.35),
    };
    final textColor = switch (data.state) {
      _StepState.done || _StepState.active => colors.text,
      _StepState.failed => const Color(0xffEF5350),
      _StepState.pending => colors.grey.withValues(alpha: 0.5),
    };

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Dot + connector line ──
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: dotColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    data.state == _StepState.done
                        ? Icons.check_rounded
                        : data.icon,
                    size: 14,
                    color: dotColor,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      color: dotColor.withValues(alpha: 0.25),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // ── Text ──
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    data.label,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 13,
                      fontWeight: data.state == _StepState.active ||
                              data.state == _StepState.done
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  if (data.detail != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      data.detail!,
                      style: TextStyle(
                        color: colors.grey.withValues(alpha: 0.7),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Thumbnails row ───────────────────────────────────────────────────────────

class _ThumbnailRow extends StatelessWidget {
  final List<_OrderProduct> products;
  const _ThumbnailRow({required this.products});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const maxShown = 4;
    final shown = products.take(maxShown).toList();
    final extra = products.length - maxShown;

    return Row(
      children: [
        ...shown.map((p) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _Thumb(url: p.thumbnailUrl, name: p.name),
            )),
        if (extra > 0)
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '+$extra',
                style: TextStyle(
                  color: colors.text,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Thumb extends StatelessWidget {
  final String? url;
  final String name;
  const _Thumb({required this.url, required this.name});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasUrl = url != null && url!.isNotEmpty;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 52,
        height: 52,
        color: colors.background,
        child: hasUrl
            ? Image.network(
                url!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _initial(name, colors),
              )
            : _initial(name, colors),
      ),
    );
  }

  Widget _initial(String name, AppColorScheme colors) => Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
            color: colors.text.withValues(alpha: 0.4),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
}

// ─── Status badge ─────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = _style(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  (String, Color, Color) _style(String s) => switch (s) {
        'delivered' => (
            '✓ Delivered',
            const Color(0xff0D2B1A),
            const Color(0xff4CAF50)
          ),
        'shipped' => ('Shipped', const Color(0xff2B1500), AppColors.primary),
        'processing' => (
            'Processing',
            const Color(0xff0A1C35),
            const Color(0xff42A5F5)
          ),
        'confirmed' => (
            'Confirmed',
            const Color(0xff0A1C35),
            const Color(0xff42A5F5)
          ),
        'cancelled' => (
            '✕ Cancelled',
            const Color(0xff2B0A0A),
            const Color(0xffEF5350)
          ),
        _ => ('Pending', const Color(0xff1E1500), const Color(0xffFFA726)),
      };
}

// ─── Empty / error states ─────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('📦', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text('No orders yet',
              style: TextStyle(
                  color: colors.text,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Your placed orders will appear here.',
              style: TextStyle(color: colors.grey, fontSize: 13)),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('😕', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text('Could not load orders',
              style: TextStyle(
                  color: colors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Retry',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Helper ───────────────────────────────────────────────────────────────────

String _fmt(double v) =>
    v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(2);
