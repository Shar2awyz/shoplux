class PaymentMethodModel {
  final String id;
  final String userId;
  final String cardType; // 'visa' | 'mastercard'
  final String cardholderName;
  final String lastFour;
  final String encryptedNumber;
  final int expiryMonth;
  final int expiryYear;
  final bool isDefault;

  const PaymentMethodModel({
    required this.id,
    required this.userId,
    required this.cardType,
    required this.cardholderName,
    required this.lastFour,
    required this.encryptedNumber,
    required this.expiryMonth,
    required this.expiryYear,
    required this.isDefault,
  });

  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) =>
      PaymentMethodModel(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        cardType: json['card_type'] as String,
        cardholderName: json['cardholder_name'] as String,
        lastFour: json['last_four'] as String,
        encryptedNumber: json['encrypted_number'] as String,
        expiryMonth: (json['expiry_month'] as num).toInt(),
        expiryYear: (json['expiry_year'] as num).toInt(),
        isDefault: json['is_default'] as bool? ?? false,
      );

  String get maskedNumber => '•••• •••• •••• $lastFour';

  String get expiryDisplay {
    final mm = expiryMonth.toString().padLeft(2, '0');
    final yy = (expiryYear % 100).toString().padLeft(2, '0');
    return '$mm/$yy';
  }

  bool get isExpired {
    final now = DateTime.now();
    return expiryYear < now.year ||
        (expiryYear == now.year && expiryMonth < now.month);
  }
}
