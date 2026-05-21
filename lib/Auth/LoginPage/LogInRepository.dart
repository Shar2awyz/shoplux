import 'package:supabase_flutter/supabase_flutter.dart';

class Loginrepository {
 Future<void> Login(String email, String password) async {
  await Supabase.instance.client.auth.signInWithPassword(
     email: email,
     password: password
   );


 }


}