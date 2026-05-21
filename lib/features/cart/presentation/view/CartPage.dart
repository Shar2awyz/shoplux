import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:shoplux/constants/AppColors.dart';
import 'package:shoplux/core/app_color_scheme.dart';
import 'package:shoplux/features/cart/domain/models/cart_item.dart';
import 'package:shoplux/features/cart/presentation/states/cart_state.dart';
import 'package:shoplux/features/cart/presentation/viewmodels/cart_cubit.dart';
import 'package:shoplux/features/checkout/presentation/view/CheckoutPage.dart';

Color _dotColorFromName(String name) {
  switch (name.toLowerCase()) {
    case 'black':       return const Color(0xFF1A1A1A);
    case 'white':       return const Color(0xFFF5F5F5);
    case 'red':         return const Color(0xFFE53935);
    case 'blue':        return const Color(0xFF1E88E5);
    case 'navy':        return const Color(0xFF1A237E);
    case 'green':       return const Color(0xFF43A047);
    case 'olive':       return const Color(0xFF827717);
    case 'yellow':      return const Color(0xFFFDD835);
    case 'orange':      return const Color(0xFFFB8C00);
    case 'purple':      return const Color(0xFF8E24AA);
    case 'lavender':    return const Color(0xFFCE93D8);
    case 'pink':        return const Color(0xFFE91E8C);
    case 'brown':       return const Color(0xFF6D4C41);
    case 'beige':       return const Color(0xFFF5F0DC);
    case 'cream':       return const Color(0xFFFFFDD0);
    case 'grey':
    case 'gray':        return const Color(0xFF757575);
    case 'silver':      return const Color(0xFFBDBDBD);
    case 'gold':        return const Color(0xFFFFCA28);
    case 'teal':        return const Color(0xFF00897B);
    case 'turquoise':   return const Color(0xFF00BCD4);
    case 'cyan':        return const Color(0xFF00ACC1);
    case 'coral':       return const Color(0xFFFF7043);
    case 'salmon':      return const Color(0xFFEF9A9A);
    case 'khaki':       return const Color(0xFFC8B560);
    case 'maroon':      return const Color(0xFF7B1C1C);
    default:            return const Color(0xFF9E9E9E);
  }
}

class CartPage extends StatelessWidget {
  final VoidCallback? onGoHome;
  const CartPage({super.key, this.onGoHome});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        final w = MediaQuery.of(context).size.width;
        final hPadding = w * 0.05;
        final colors = context.colors;

        return Scaffold(
          backgroundColor: colors.background,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    hPadding,
                    w * 0.06,
                    hPadding,
                    w * 0.04,
                  ),
                  child: Text(
                    'My Cart',
                    style: TextStyle(
                      color: colors.text,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: state.isEmpty
                      ? _EmptyCart(hPadding: hPadding)
                      : _CartContent(state: state, hPadding: hPadding),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Empty state ─────────────────────────────────────────────────────────────

class _EmptyCart extends StatelessWidget {
  final double hPadding;
  const _EmptyCart({required this.hPadding});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: hPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🛒', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 20),
            Text(
              'Your cart is empty',
              style: TextStyle(
                color: colors.text,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add items from the Home or Search page\nto get started.',
              style: TextStyle(
                color: colors.grey,
                fontSize: w * 0.035,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Cart content ─────────────────────────────────────────────────────────────

class _CartContent extends StatelessWidget {
  final CartState state;
  final double hPadding;

  const _CartContent({required this.state, required this.hPadding});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: hPadding),
            physics: const BouncingScrollPhysics(),
            itemCount: state.items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) => _CartItemTile(
              item: state.items[index],
            ),
          ),
        ),
        _CartSummary(state: state, hPadding: hPadding),
      ],
    );
  }
}

// ─── Cart item tile ───────────────────────────────────────────────────────────

class _CartItemTile extends StatelessWidget {
  final CartItem item;
  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final colors = context.colors;
    final cubit = context.read<CartCubit>();

    return Dismissible(
      key: ValueKey('${item.productId}_${item.variant ?? ""}_${item.selectedColor ?? ""}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
      ),
      onDismissed: (_) => cubit.removeItem(item.productId),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.fieldBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 62,
                height: 62,
                color: colors.cardBackgrounds[1],
                child: item.imageUrl.isNotEmpty
                    ? Image.network(
                        item.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            _ImageFallback(name: item.name),
                      )
                    : _ImageFallback(name: item.name),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      color: colors.text,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if ((item.variant != null && item.variant!.isNotEmpty) ||
                      item.selectedColor != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (item.variant != null && item.variant!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: colors.background,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: colors.fieldBorder),
                            ),
                            child: Text(
                              item.variant!,
                              style: TextStyle(
                                  color: colors.grey, fontSize: 11),
                            ),
                          ),
                        if (item.variant != null &&
                            item.variant!.isNotEmpty &&
                            item.selectedColor != null)
                          const SizedBox(width: 6),
                        if (item.selectedColor != null) ...[
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: _dotColorFromName(item.selectedColor!),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colors.fieldBorder,
                                width: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.selectedColor!,
                            style: TextStyle(
                                color: colors.grey, fontSize: 11),
                          ),
                        ],
                      ],
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    '\$${_fmt(item.price)}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            _QuantityControl(item: item, cubit: cubit, w: w),
          ],
        ),
      ),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  final CartItem item;
  final CartCubit cubit;
  final double w;

  const _QuantityControl({
    required this.item,
    required this.cubit,
    required this.w,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _QBtn(
          icon: item.quantity == 1
              ? Icons.delete_outline_rounded
              : Icons.remove,
          color: item.quantity == 1 ? Colors.redAccent : colors.grey,
          onTap: () => cubit.updateQuantity(item.productId, item.quantity - 1),
        ),
        SizedBox(
          width: 28,
          child: Text(
            '${item.quantity}',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.text,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        _QBtn(
          icon: Icons.add,
          color: AppColors.primary,
          onTap: () => cubit.updateQuantity(item.productId, item.quantity + 1),
        ),
      ],
    );
  }
}

class _QBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: context.colors.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  final String name;
  const _ImageFallback({required this.name});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
          color: context.colors.text.withValues(alpha: 0.3),
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ─── Summary ──────────────────────────────────────────────────────────────────

class _CartSummary extends StatelessWidget {
  final CartState state;
  final double hPadding;

  const _CartSummary({required this.state, required this.hPadding});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasDiscount = state.totalDiscount > 0;

    return Container(
      margin: EdgeInsets.fromLTRB(hPadding, 12, hPadding, 16),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
      decoration: BoxDecoration(
        color: colors.fieldBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _SummaryRow(
            label: 'Subtotal',
            value: '\$${_fmt(state.subtotal)}',
            labelColor: colors.grey,
            valueColor: colors.text,
            fontSize: 14,
          ),
          if (hasDiscount) ...[
            const SizedBox(height: 8),
            _SummaryRow(
              label: 'Discount',
              value: '-\$${_fmt(state.totalDiscount)}',
              labelColor: colors.grey,
              valueColor: const Color(0xff4CAF50),
              fontSize: 14,
              valueBold: true,
            ),
          ],
          const SizedBox(height: 12),
          Divider(color: colors.divider, height: 1),
          const SizedBox(height: 12),
          _SummaryRow(
            label: 'Total',
            value: '\$${_fmt(state.total)}',
            labelColor: colors.text,
            valueColor: AppColors.primary,
            fontSize: 16,
            labelBold: true,
            valueBold: true,
            valueFontSize: 18,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CheckoutPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Checkout  →',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color labelColor;
  final Color valueColor;
  final double fontSize;
  final double? valueFontSize;
  final bool labelBold;
  final bool valueBold;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.labelColor,
    required this.valueColor,
    required this.fontSize,
    this.valueFontSize,
    this.labelBold = false,
    this.valueBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontSize: fontSize,
            fontWeight: labelBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: valueFontSize ?? fontSize,
            fontWeight: valueBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

// ─── Helper ───────────────────────────────────────────────────────────────────

String _fmt(double v) =>
    v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(2);
