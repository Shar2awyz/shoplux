import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shoplux/Auth/SignUpPage/SignUpRepo.dart';
import 'package:shoplux/Auth/SignUpPage/viewmodel/SignUpState.dart';

class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit() : super(SignUpInitial());
  SignUpRepo signUpRepo = SignUpRepo();

  Future<void> SignUp(String email, String password, String name) async {
    emit(SignUpLoading());

    try {
      await signUpRepo.signUp(email, password, name);
      emit(SignUpSuccess());
    } catch (e) {
      emit(SignUpFailure(e.toString()));
    }
  }
}
