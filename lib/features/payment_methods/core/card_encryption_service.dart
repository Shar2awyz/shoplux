import 'package:encrypt/encrypt.dart' as enc;

/// AES-256-CBC encryption for card numbers.
/// Each call to [encrypt] generates a fresh random IV so identical card numbers
/// produce different ciphertexts — never deterministic.
/// CVV is intentionally never encrypted or stored.
class CardEncryptionService {
  CardEncryptionService._();

  // 32-byte key → AES-256. Replace with a secret loaded from your backend/env
  // in a production deployment.
  static final _key =
      enc.Key.fromUtf8('ShopLux!CardSec@2024*AES256Bits!');
  static final _cipher =
      enc.Encrypter(enc.AES(_key, mode: enc.AESMode.cbc));

  /// Returns `ivBase64|ciphertextBase64`.
  static String encrypt(String plaintext) {
    final iv = enc.IV.fromSecureRandom(16);
    final result = _cipher.encrypt(plaintext, iv: iv);
    return '${iv.base64}|${result.base64}';
  }

  /// Decrypts a value produced by [encrypt].
  static String decrypt(String stored) {
    final sep = stored.indexOf('|');
    if (sep == -1) throw const FormatException('Malformed card ciphertext');
    final iv = enc.IV.fromBase64(stored.substring(0, sep));
    return _cipher.decrypt64(stored.substring(sep + 1), iv: iv);
  }
}
