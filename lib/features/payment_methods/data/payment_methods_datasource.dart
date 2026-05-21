import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/card_encryption_service.dart';
import '../domain/models/payment_method_model.dart';

class PaymentMethodsDatasource {
  PaymentMethodsDatasource._();

  static final _db = Supabase.instance.client;

  static Future<List<PaymentMethodModel>> fetchAll(String userId) async {
    final rows = await _db
        .from('payment_methods')
        .select()
        .eq('user_id', userId)
        .order('is_default', ascending: false)
        .order('created_at', ascending: false);
    return rows.map(PaymentMethodModel.fromJson).toList();
  }

  static Future<PaymentMethodModel> insert({
    required String userId,
    required String cardType,
    required String cardholderName,
    required String cardNumber, // raw digits (may contain spaces)
    required int expiryMonth,
    required int expiryYear,
  }) async {
    final digits = cardNumber.replaceAll(' ', '');
    final lastFour = digits.substring(digits.length - 4);
    final encrypted = CardEncryptionService.encrypt(digits);

    final row = await _db.from('payment_methods').insert({
      'user_id': userId,
      'card_type': cardType,
      'cardholder_name': cardholderName.trim(),
      'last_four': lastFour,
      'encrypted_number': encrypted,
      'expiry_month': expiryMonth,
      'expiry_year': expiryYear,
      'is_default': false,
    }).select().single();

    return PaymentMethodModel.fromJson(row);
  }

  static Future<void> delete(String cardId) async {
    await _db.from('payment_methods').delete().eq('id', cardId);
  }

  static Future<void> setDefault(String cardId, String userId) async {
    // Clear all defaults for this user, then set the chosen one.
    await _db
        .from('payment_methods')
        .update({'is_default': false})
        .eq('user_id', userId);
    await _db
        .from('payment_methods')
        .update({'is_default': true})
        .eq('id', cardId);
  }
}
