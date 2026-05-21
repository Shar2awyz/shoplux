sealed class SignUpState {

}
class SignUpInitial extends SignUpState{}
class SignUpLoading extends SignUpState{}
class SignUpSuccess extends SignUpState{}
class SignUpFailure extends SignUpState{
  String error;
  SignUpFailure(this.error);

}
