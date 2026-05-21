import 'package:shoplux/features/profile/domain/models/user_profile.dart';

enum EditProfileStatus { initial, loading, success, error, emailConfirmationSent }

class EditProfileState {
  const EditProfileState({
    this.status = EditProfileStatus.initial,
    this.profile,
    this.error,
  });

  final EditProfileStatus status;
  final UserProfile? profile;
  final String? error;

  bool get isLoading => status == EditProfileStatus.loading;
  bool get isSuccess => status == EditProfileStatus.success;
  bool get isError => status == EditProfileStatus.error;
  bool get emailConfirmationSent =>
      status == EditProfileStatus.emailConfirmationSent;

  EditProfileState copyWith({
    EditProfileStatus? status,
    UserProfile? profile,
    Object? error = _sentinel,
  }) {
    return EditProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      error: error == _sentinel ? this.error : error as String?,
    );
  }
}

const _sentinel = Object();
