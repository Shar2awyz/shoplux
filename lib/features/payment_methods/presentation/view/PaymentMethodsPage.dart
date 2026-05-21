import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:shoplux/constants/AppColors.dart';
import 'package:shoplux/core/app_color_scheme.dart';
import '../../data/payment_methods_datasource.dart';
import '../../domain/models/payment_method_model.dart';
import '../widgets/card_chip.dart';
import 'AddCardPage.dart';

class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({super.key});

  static Route<void> route() =>
      MaterialPageRoute(builder: (_) => const PaymentMethodsPage());

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  List<PaymentMethodModel> _cards = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    setState(() { _loading = true; _error = null; });
    try {
      final cards = await PaymentMethodsDatasource.fetchAll(userId);
      if (mounted) setState(() { _cards = cards; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _delete(PaymentMethodModel card) async {
    try {
      await PaymentMethodsDatasource.delete(card.id);
      if (mounted) {
        setState(() => _cards.remove(card));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Card ending in ${card.lastFour} removed.'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove card: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _setDefault(PaymentMethodModel card) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    try {
      await PaymentMethodsDatasource.setDefault(card.id, userId);
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _goToAddCard() async {
    final added = await Navigator.push<bool>(context, AddCardPage.route());
    if (added == true) _load();
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
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.text, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Payment Methods',
          style: TextStyle(
            color: colors.text,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.primary, size: 28),
            onPressed: _goToAddCard,
            tooltip: 'Add card',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _error != null
              ? _ErrorView(error: _error!, onRetry: _load)
              : _cards.isEmpty
                  ? _EmptyView(onAdd: _goToAddCard)
                  : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: _load,
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        itemCount: _cards.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 20),
                        itemBuilder: (_, i) => _CardItem(
                          card: _cards[i],
                          onDelete: _delete,
                          onSetDefault: _setDefault,
                        ),
                      ),
                    ),
    );
  }
}

// ─── Card item (chip + actions) ───────────────────────────────────────────────

class _CardItem extends StatelessWidget {
  final PaymentMethodModel card;
  final Future<void> Function(PaymentMethodModel) onDelete;
  final Future<void> Function(PaymentMethodModel) onSetDefault;

  const _CardItem({
    required this.card,
    required this.onDelete,
    required this.onSetDefault,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CardChip.fromModel(card),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: card.isDefault
                  ? Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: AppColors.primary, size: 16),
                        const SizedBox(width: 6),
                        const Text(
                          'Default card',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : OutlinedButton.icon(
                      onPressed: () => onSetDefault(card),
                      icon: const Icon(Icons.star_outline_rounded, size: 16),
                      label: const Text('Set as Default'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: () => _confirmDelete(context),
              icon: const Icon(Icons.delete_outline_rounded),
              color: Colors.redAccent,
              style: IconButton.styleFrom(
                backgroundColor: Colors.redAccent.withValues(alpha: 0.08),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              tooltip: 'Remove card',
            ),
          ],
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context) {
    final colors = context.colors;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.fieldBackground,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Remove Card',
            style: TextStyle(
                color: colors.text, fontWeight: FontWeight.bold)),
        content: Text(
          'Remove card ending in ${card.lastFour}?',
          style: TextStyle(color: colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDelete(card);
            },
            child: const Text('Remove',
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyView({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.credit_card_rounded,
                  color: AppColors.primary, size: 48),
            ),
            const SizedBox(height: 20),
            Text(
              'No saved cards',
              style: TextStyle(
                color: colors.text,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a Visa or Mastercard to pay without re-entering details each time.',
              style: TextStyle(color: colors.grey, fontSize: 14, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Add Card',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Error view ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded,
              color: Colors.redAccent, size: 48),
          const SizedBox(height: 16),
          Text('Could not load cards',
              style: TextStyle(
                  color: colors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(error,
              style: TextStyle(color: colors.grey, fontSize: 12),
              textAlign: TextAlign.center),
          const SizedBox(height: 20),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry',
                style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}
