import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:shoplux/constants/AppColors.dart';
import 'package:shoplux/core/app_color_scheme.dart';
import '../../data/payment_methods_datasource.dart';
import '../widgets/card_chip.dart';

class AddCardPage extends StatefulWidget {
  const AddCardPage({super.key});

  static Route<bool> route() =>
      MaterialPageRoute(builder: (_) => const AddCardPage());

  @override
  State<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  final _numberCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  bool _saving = false;
  String _cardType = 'unknown';

  @override
  void initState() {
    super.initState();
    _numberCtrl.addListener(_onNumberChanged);
    _nameCtrl.addListener(_refresh);
    _expiryCtrl.addListener(_refresh);
  }

  void _onNumberChanged() {
    final digits = _numberCtrl.text.replaceAll(' ', '');
    String detected = 'unknown';
    if (digits.startsWith('4')) {
      detected = 'visa';
    } else if (digits.length >= 2) {
      final prefix2 = int.tryParse(digits.substring(0, 2)) ?? 0;
      if (prefix2 >= 51 && prefix2 <= 55) detected = 'mastercard';
    }
    if (digits.length >= 4 && detected == 'unknown') {
      final prefix4 = int.tryParse(digits.substring(0, 4)) ?? 0;
      if (prefix4 >= 2221 && prefix4 <= 2720) detected = 'mastercard';
    }
    setState(() => _cardType = detected);
  }

  void _refresh() => setState(() {});

  bool _luhn(String number) {
    final digits = number.replaceAll(' ', '');
    if (digits.length != 16) return false;
    int sum = 0;
    bool alt = false;
    for (int i = digits.length - 1; i >= 0; i--) {
      int n = int.parse(digits[i]);
      if (alt) {
        n *= 2;
        if (n > 9) n -= 9;
      }
      sum += n;
      alt = !alt;
    }
    return sum % 10 == 0;
  }

  Future<void> _save() async {
    final cardNumber = _numberCtrl.text.trim();
    final name = _nameCtrl.text.trim();
    final expiry = _expiryCtrl.text.trim();

    if (cardNumber.replaceAll(' ', '').length != 16) {
      return _err('Enter a complete 16-digit card number.');
    }
    if (!_luhn(cardNumber)) return _err('Invalid card number.');
    if (_cardType == 'unknown') {
      return _err('Only Visa and Mastercard are supported.');
    }
    if (name.isEmpty) return _err('Enter the cardholder name.');

    final parts = expiry.split('/');
    if (parts.length != 2 || parts[0].length != 2 || parts[1].length != 2) {
      return _err('Enter expiry as MM/YY.');
    }
    final month = int.tryParse(parts[0]) ?? 0;
    final year = 2000 + (int.tryParse(parts[1]) ?? 0);
    if (month < 1 || month > 12) return _err('Invalid expiry month.');
    final now = DateTime.now();
    if (year < now.year || (year == now.year && month < now.month)) {
      return _err('This card has expired.');
    }

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    setState(() => _saving = true);
    try {
      await PaymentMethodsDatasource.insert(
        userId: userId,
        cardType: _cardType,
        cardholderName: name,
        cardNumber: cardNumber,
        expiryMonth: month,
        expiryYear: year,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) _err('Failed to save card: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _err(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.redAccent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  void dispose() {
    _numberCtrl.removeListener(_onNumberChanged);
    _nameCtrl.removeListener(_refresh);
    _expiryCtrl.removeListener(_refresh);
    _numberCtrl.dispose();
    _nameCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  // Builds a live display string (typed digits + dots for remaining).
  String get _liveNumber {
    final digits = _numberCtrl.text.replaceAll(' ', '');
    final buf = StringBuffer();
    for (int i = 0; i < 16; i++) {
      if (i != 0 && i % 4 == 0) buf.write(' ');
      buf.write(i < digits.length ? digits[i] : '•');
    }
    return buf.toString();
  }

  String get _liveExpiry {
    final t = _expiryCtrl.text;
    return t.isEmpty ? 'MM/YY' : t;
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
          onPressed: () => Navigator.pop(context, false),
        ),
        title: Text(
          'Add Card',
          style: TextStyle(
              color: colors.text,
              fontSize: 22,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),

              // ── Live card preview ───────────────────────
              CardChip(
                cardType: _cardType,
                displayNumber: _liveNumber,
                cardholderName: _nameCtrl.text,
                expiryDisplay: _liveExpiry,
              ),

              const SizedBox(height: 28),

              // ── Card Number ─────────────────────────────
              _FieldLabel('Card Number'),
              const SizedBox(height: 8),
              _Field(
                controller: _numberCtrl,
                hint: '0000 0000 0000 0000',
                icon: Icons.credit_card_rounded,
                keyboardType: TextInputType.number,
                formatters: [_CardNumberFormatter()],
              ),

              const SizedBox(height: 16),

              // ── Cardholder Name ─────────────────────────
              _FieldLabel('Cardholder Name'),
              const SizedBox(height: 8),
              _Field(
                controller: _nameCtrl,
                hint: 'Name on card',
                icon: Icons.person_outline_rounded,
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.characters,
              ),

              const SizedBox(height: 16),

              // ── Expiry + CVV ────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FieldLabel('Expiry'),
                        const SizedBox(height: 8),
                        _Field(
                          controller: _expiryCtrl,
                          hint: 'MM/YY',
                          icon: Icons.calendar_today_outlined,
                          keyboardType: TextInputType.number,
                          formatters: [_ExpiryFormatter()],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FieldLabel('CVV'),
                        const SizedBox(height: 8),
                        _Field(
                          controller: _cvvCtrl,
                          hint: '•••',
                          icon: Icons.lock_outline_rounded,
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          formatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.security_rounded,
                      color: context.colors.grey, size: 13),
                  const SizedBox(width: 5),
                  Text(
                    'CVV is never stored — verified locally only.',
                    style:
                        TextStyle(color: context.colors.grey, fontSize: 11),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ── Save button ─────────────────────────────
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor:
                        AppColors.primary.withValues(alpha: 0.5),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text(
                          'Save Card',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Field label ──────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          color: context.colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      );
}

// ─── Text field ───────────────────────────────────────────────────────────────

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter> formatters;
  final bool obscureText;

  const _Field({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.formatters = const [],
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.fieldBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.fieldBorder),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        inputFormatters: formatters,
        obscureText: obscureText,
        style: TextStyle(
            color: colors.text, fontSize: 15, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 14, right: 10),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 0, minHeight: 0),
          hintText: hint,
          hintStyle: TextStyle(color: colors.grey, fontSize: 14),
        ),
      ),
    );
  }
}

// ─── Input formatters ─────────────────────────────────────────────────────────

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 16) return oldValue;

    final buf = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i != 0 && i % 4 == 0) buf.write(' ');
      buf.write(digits[i]);
    }
    final formatted = buf.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 4) return oldValue;

    final formatted =
        digits.length <= 2 ? digits : '${digits.substring(0, 2)}/${digits.substring(2)}';
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
