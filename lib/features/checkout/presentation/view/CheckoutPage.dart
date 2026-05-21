import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shoplux/MainPages/HomePage/view/HomePage.dart';
import 'package:shoplux/constants/AppColors.dart';
import 'package:shoplux/core/app_color_scheme.dart';
import 'package:shoplux/features/cart/presentation/states/cart_state.dart';
import 'package:shoplux/features/cart/presentation/viewmodels/cart_cubit.dart';
import 'package:shoplux/features/checkout/data/order_repository.dart';
import 'package:shoplux/features/payment_methods/data/payment_methods_datasource.dart';
import 'package:shoplux/features/payment_methods/domain/models/payment_method_model.dart';
import 'package:shoplux/features/payment_methods/presentation/view/PaymentMethodsPage.dart';
import 'package:shoplux/features/payment_methods/presentation/widgets/card_chip.dart';

enum _Payment { cash, visa, mastercard, applePay }

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  _Payment _payment = _Payment.cash;
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  bool _isLoading = false;

  List<PaymentMethodModel> _savedCards = [];
  bool _loadingCards = false;
  String? _selectedCardId;

  @override
  void initState() {
    super.initState();
    _loadSavedCards();
  }

  Future<void> _loadSavedCards() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    setState(() => _loadingCards = true);
    try {
      final cards = await PaymentMethodsDatasource.fetchAll(userId);
      if (mounted) {
        setState(() {
          _savedCards = cards;
          _loadingCards = false;
          final defaultCard =
              cards.where((c) => c.isDefault).firstOrNull;
          if (defaultCard != null) _selectedCardId = defaultCard.id;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingCards = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _placeOrder(CartState state) async {
    if (_nameCtrl.text.trim().isEmpty || _addressCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in your delivery address.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_payment == _Payment.visa || _payment == _Payment.mastercard) {
      final cardType =
          _payment == _Payment.visa ? 'visa' : 'mastercard';
      final hasCard = _savedCards
          .any((c) => c.cardType == cardType && c.id == _selectedCardId);
      if (!hasCard) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Please select a saved ${_paymentLabel(_payment)} card.'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    } else if (_payment == _Payment.applePay) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Apple Pay coming soon — use another method for now.'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final paymentMethodStr = switch (_payment) {
      _Payment.cash => 'cash',
      _Payment.visa => 'visa',
      _Payment.mastercard => 'mastercard',
      _Payment.applePay => 'apple_pay',
    };

    setState(() => _isLoading = true);
    try {
      await OrderRepository.placeOrder(
        userId: userId,
        items: state.items,
        subtotal: state.subtotal,
        discountAmount: state.totalDiscount,
        total: state.total,
        shippingAddress:
            '${_nameCtrl.text.trim()}, ${_addressCtrl.text.trim()}',
        paymentMethod: paymentMethodStr,
      );
      if (!mounted) return;
      await context.read<CartCubit>().clearCart();
      if (!mounted) return;
      _showSuccess();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to place order: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _paymentLabel(_Payment p) => switch (p) {
        _Payment.cash => 'Cash on Delivery',
        _Payment.visa => 'Visa',
        _Payment.mastercard => 'Mastercard',
        _Payment.applePay => 'Apple Pay',
      };

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.fieldBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(
              'Order Placed!',
              style: TextStyle(
                color: context.colors.text,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Your order has been placed successfully.\nWe\'ll deliver it to you soon.',
              style: TextStyle(color: context.colors.grey, fontSize: 14, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>HomePage()), (route) => false,);
                  
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Continue Shopping',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        final colors = context.colors;
        return Scaffold(
          backgroundColor: colors.background,
          appBar: AppBar(
            backgroundColor: colors.background,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.text, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Checkout',
              style: TextStyle(
                color: colors.text,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        _SectionLabel(label: '📍  Delivery Address'),
                        const SizedBox(height: 12),
                        _AddressCard(nameCtrl: _nameCtrl, addressCtrl: _addressCtrl),
                        const SizedBox(height: 20),
                        _SectionLabel(label: '💳  Payment Method'),
                        const SizedBox(height: 12),
                        _PaymentCard(
                          selected: _payment,
                          onChanged: (p) => setState(() => _payment = p),
                        ),
                        if (_payment == _Payment.visa ||
                            _payment == _Payment.mastercard) ...[
                          const SizedBox(height: 10),
                          _SavedCardPicker(
                            cards: _savedCards,
                            cardType: _payment == _Payment.visa
                                ? 'visa'
                                : 'mastercard',
                            selectedId: _selectedCardId,
                            loading: _loadingCards,
                            onSelect: (id) =>
                                setState(() => _selectedCardId = id),
                            onManage: () =>
                                Navigator.push(context, PaymentMethodsPage.route())
                                    .then((_) => _loadSavedCards()),
                          ),
                        ],
                        const SizedBox(height: 20),
                        _OrderSummary(state: state),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                _BottomBar(
                  total: state.total,
                  isLoading: _isLoading,
                  onPlaceOrder: () => _placeOrder(state),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: context.colors.text,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

// ─── Delivery Address ─────────────────────────────────────────────────────────

class _AddressCard extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController addressCtrl;
  const _AddressCard({required this.nameCtrl, required this.addressCtrl});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.fieldBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _InputField(
            controller: nameCtrl,
            hint: 'Full name',
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 10),
          _InputField(
            controller: addressCtrl,
            hint: 'Street, City, ZIP',
            icon: Icons.location_on_outlined,
          ),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return TextField(
      controller: controller,
      style: TextStyle(color: colors.text, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: colors.grey, fontSize: 14),
        prefixIcon: Icon(icon, color: colors.grey, size: 18),
        filled: true,
        fillColor: colors.background,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

// ─── Payment methods ──────────────────────────────────────────────────────────

class _PaymentCard extends StatelessWidget {
  final _Payment selected;
  final ValueChanged<_Payment> onChanged;
  const _PaymentCard({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colors.fieldBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: _Payment.values
            .map((p) => _PaymentTile(
                  payment: p,
                  isSelected: p == selected,
                  onTap: () => onChanged(p),
                ))
            .toList(),
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final _Payment payment;
  final bool isSelected;
  final VoidCallback onTap;
  const _PaymentTile({
    required this.payment,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : colors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            _buildIcon(),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _title,
                    style: TextStyle(
                      color: colors.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _subtitle,
                    style: TextStyle(color: colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : colors.grey,
                  width: 2,
                ),
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded, size: 12, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    switch (payment) {
      case _Payment.cash:
        return _IconBox(
          color: const Color(0xff4CAF50),
          child: const Icon(Icons.payments_outlined, color: Color(0xff4CAF50), size: 20),
        );
      case _Payment.visa:
        return _IconBox(
          color: const Color(0xff1565C0),
          child: const Text(
            'VISA',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        );
      case _Payment.mastercard:
        return _IconBox(
          color: Colors.orange,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 6,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: Color(0xffEB001B),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                right: 6,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xffF79E1B).withValues(alpha: 0.85),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        );
      case _Payment.applePay:
        return _IconBox(
          color: Colors.white24,
          child: const Icon(Icons.apple_rounded, color: Colors.white, size: 22),
        );
    }
  }

  String get _title => switch (payment) {
        _Payment.cash => 'Cash on Delivery',
        _Payment.visa => 'Visa',
        _Payment.mastercard => 'Mastercard',
        _Payment.applePay => 'Apple Pay',
      };

  String get _subtitle => switch (payment) {
        _Payment.cash => 'Pay when your order arrives',
        _Payment.visa => 'Coming soon',
        _Payment.mastercard => 'Coming soon',
        _Payment.applePay => 'Coming soon',
      };
}

class _IconBox extends StatelessWidget {
  final Color color;
  final Widget child;
  const _IconBox({required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(child: child),
    );
  }
}

// ─── Order summary ────────────────────────────────────────────────────────────

class _OrderSummary extends StatelessWidget {
  final CartState state;
  const _OrderSummary({required this.state});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final itemWord = state.totalCount == 1 ? 'item' : 'items';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.fieldBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: TextStyle(
              color: colors.text,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          _Row(
            label: '${state.totalCount} $itemWord',
            value: '\$${_fmt(state.subtotal)}',
            labelColor: colors.grey,
            valueColor: colors.text,
          ),
          if (state.totalDiscount > 0) ...[
            const SizedBox(height: 8),
            _Row(
              label: 'Discount',
              value: '-\$${_fmt(state.totalDiscount)}',
              labelColor: colors.grey,
              valueColor: const Color(0xff4CAF50),
            ),
          ],
          const SizedBox(height: 8),
          _Row(
            label: 'Shipping',
            value: 'Free',
            labelColor: colors.grey,
            valueColor: const Color(0xff4CAF50),
          ),
          Divider(color: colors.divider, height: 20),
          _Row(
            label: 'Total',
            value: '\$${_fmt(state.total)}',
            labelColor: colors.text,
            valueColor: AppColors.primary,
            bold: true,
            fontSize: 15,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color labelColor;
  final Color valueColor;
  final bool bold;
  final double fontSize;

  const _Row({
    required this.label,
    required this.value,
    required this.labelColor,
    required this.valueColor,
    this.bold = false,
    this.fontSize = 13,
  });

  @override
  Widget build(BuildContext context) {
    final weight = bold ? FontWeight.bold : FontWeight.normal;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: labelColor, fontSize: fontSize, fontWeight: weight)),
        Text(value, style: TextStyle(color: valueColor, fontSize: bold ? fontSize + 1 : fontSize, fontWeight: weight)),
      ],
    );
  }
}

// ─── Bottom bar ───────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final double total;
  final bool isLoading;
  final VoidCallback onPlaceOrder;
  const _BottomBar({required this.total, required this.isLoading, required this.onPlaceOrder});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
      decoration: BoxDecoration(
        color: colors.fieldBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total', style: TextStyle(color: colors.grey, fontSize: 12)),
              Text(
                '\$${_fmt(total)}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : onPlaceOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Place Order',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Saved card picker (shown inside checkout when Visa/MC selected) ──────────

class _SavedCardPicker extends StatelessWidget {
  final List<PaymentMethodModel> cards;
  final String cardType; // 'visa' | 'mastercard'
  final String? selectedId;
  final bool loading;
  final ValueChanged<String> onSelect;
  final VoidCallback onManage;

  const _SavedCardPicker({
    required this.cards,
    required this.cardType,
    required this.selectedId,
    required this.loading,
    required this.onSelect,
    required this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final filtered =
        cards.where((c) => c.cardType == cardType).toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.fieldBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Saved cards',
                style: TextStyle(
                  color: colors.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: onManage,
                child: const Text(
                  'Manage',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child:
                      CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                ),
              ),
            )
          else if (filtered.isEmpty)
            _NoCardsHint(cardType: cardType, onManage: onManage)
          else
            ...filtered.map(
              (card) => _CardRadioTile(
                card: card,
                isSelected: card.id == selectedId,
                onTap: () => onSelect(card.id),
              ),
            ),
        ],
      ),
    );
  }
}

class _CardRadioTile extends StatelessWidget {
  final PaymentMethodModel card;
  final bool isSelected;
  final VoidCallback onTap;

  const _CardRadioTile({
    required this.card,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : colors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isSelected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            CardTypeLogo(isVisa: card.cardType == 'visa'),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.maskedNumber,
                    style: TextStyle(
                      color: colors.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${card.cardholderName}  •  ${card.expiryDisplay}',
                    style: TextStyle(color: colors.grey, fontSize: 11),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      isSelected ? AppColors.primary : colors.grey,
                  width: 2,
                ),
                color: isSelected
                    ? AppColors.primary
                    : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      size: 12, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _NoCardsHint extends StatelessWidget {
  final String cardType;
  final VoidCallback onManage;
  const _NoCardsHint({required this.cardType, required this.onManage});

  @override
  Widget build(BuildContext context) {
    final label = cardType == 'visa' ? 'Visa' : 'Mastercard';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              color: context.colors.grey, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'No $label cards saved. ',
              style: TextStyle(color: context.colors.grey, fontSize: 12),
            ),
          ),
          GestureDetector(
            onTap: onManage,
            child: const Text(
              'Add one →',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
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
