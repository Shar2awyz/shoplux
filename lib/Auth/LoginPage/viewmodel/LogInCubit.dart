import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shoplux/Auth/LoginPage/LogInRepository.dart';
import 'package:shoplux/Auth/LoginPage/viewmodel/LogInState.dart';
import 'package:shoplux/core/shared_prefs.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());
  Loginrepository loginrepository = Loginrepository();

  Future<void> login(String email, String password) async {
    emit(LoginLoading());
    try {
      await loginrepository.Login(email, password);
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        await AppPrefs.saveUserId(userId);
      }
      emit(LoginSuccess());
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }
}
