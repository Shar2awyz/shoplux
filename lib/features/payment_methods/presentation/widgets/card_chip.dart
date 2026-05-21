import 'package:flutter/material.dart';
import '../../domain/models/payment_method_model.dart';

/// Visual credit-card chip used on both the list page and the live preview.
class CardChip extends StatelessWidget {
  final String cardType; // 'visa' | 'mastercard' | 'unknown'
  final String displayNumber; // 19-char masked/live string
  final String cardholderName;
  final String expiryDisplay; // MM/YY
  final bool isDefault;

  const CardChip({
    super.key,
    required this.cardType,
    required this.displayNumber,
    required this.cardholderName,
    required this.expiryDisplay,
    this.isDefault = false,
  });

  factory CardChip.fromModel(PaymentMethodModel card) => CardChip(
        cardType: card.cardType,
        displayNumber: card.maskedNumber,
        cardholderName: card.cardholderName,
        expiryDisplay: card.expiryDisplay,
        isDefault: card.isDefault,
      );

  @override
  Widget build(BuildContext context) {
    final isVisa = cardType == 'visa';
    final isMc = cardType == 'mastercard';

    final gradient = isMc
        ? const LinearGradient(
            colors: [Color(0xFF37003C), Color(0xFF880E4F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : isVisa
            ? const LinearGradient(
                colors: [Color(0xFF1A237E), Color(0xFF1565C0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [Colors.grey.shade800, Colors.grey.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              );

    final shadowColor = isMc
        ? const Color(0xFF880E4F)
        : isVisa
            ? const Color(0xFF1565C0)
            : Colors.black;

    return Container(
      height: 190,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: chip icon + default badge + card logo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ChipIcon(),
                Row(
                  children: [
                    if (isDefault)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'DEFAULT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    if (isVisa || isMc) CardTypeLogo(isVisa: isVisa),
                  ],
                ),
              ],
            ),

            const Spacer(),

            // Card number
            Text(
              displayNumber,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                letterSpacing: 3,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 16),

            // Cardholder name + expiry
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CARDHOLDER',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 9,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        cardholderName.isEmpty
                            ? 'FULL NAME'
                            : cardholderName.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'EXPIRES',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 9,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      expiryDisplay.isEmpty ? 'MM/YY' : expiryDisplay,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 26,
      decoration: BoxDecoration(
        color: const Color(0xFFFFD700),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Icon(Icons.credit_card, color: Colors.brown, size: 16),
    );
  }
}

class CardTypeLogo extends StatelessWidget {
  final bool isVisa;
  const CardTypeLogo({super.key, required this.isVisa});

  @override
  Widget build(BuildContext context) {
    if (isVisa) {
      return const Text(
        'VISA',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
          fontStyle: FontStyle.italic,
        ),
      );
    }
    // Mastercard — two overlapping circles
    return SizedBox(
      width: 42,
      height: 26,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            child: Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                color: Color(0xFFEB001B),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 0,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: const Color(0xFFF79E1B).withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
