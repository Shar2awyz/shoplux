import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpRepo {
  Future<void> signUp(String email, String password, String name) async {
    await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
      data: {'username': name},
    );
  }
}
