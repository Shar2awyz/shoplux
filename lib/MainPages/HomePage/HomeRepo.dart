import 'package:supabase_flutter/supabase_flutter.dart';

class HomeRepo {}

class UserRepo {
  String? userid;
  UserRepo(this.userid);
  Future<void> loaddata() async{
    Supabase.instance.client.from('users').select().eq('id', userid!).single().then((value) {
      

      
      print(value);
    });


  }
}
