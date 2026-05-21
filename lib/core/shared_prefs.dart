import 'package:encrypt/encrypt.dart' as enc;
import 'package:shared_preferences/shared_preferences.dart';

class AppPrefs {
  AppPrefs._();

  static late SharedPreferences _prefs;

  // 32-char key for AES-256
  static final _key = enc.Key.fromUtf8('ShopLux!SecureKey#2024@AES256!!!');
  static final _iv = enc.IV.fromLength(16);
  static final _encrypter = enc.Encrypter(enc.AES(_key));

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── Dark mode ──────────────────────────────────────────
  static const _kDarkMode = 'dark_mode';

  static bool get isDarkMode => _prefs.getBool(_kDarkMode) ?? true;

  static Future<void> setDarkMode(bool value) =>
      _prefs.setBool(_kDarkMode, value);

  // ── Encrypted user ID ──────────────────────────────────
  static const _kUserId = 'user_id';

  static bool get isLoggedIn => _prefs.getString(_kUserId) != null;

  static Future<void> saveUserId(String userId) async {
    final encrypted = _encrypter.encrypt(userId, iv: _iv).base64;
    await _prefs.setString(_kUserId, encrypted);
  }

  static String? getUserId() {
    final stored = _prefs.getString(_kUserId);
    if (stored == null) return null;
    try {
      return _encrypter.decrypt64(stored, iv: _iv);
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearUserId() => _prefs.remove(_kUserId);
}
