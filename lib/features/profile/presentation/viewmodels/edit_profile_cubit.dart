import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shoplux/features/profile/domain/repositories/profile_repository.dart';
import 'package:shoplux/features/profile/presentation/states/edit_profile_state.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  EditProfileCubit({required ProfileRepository repository})
      : _repository = repository,
        super(const EditProfileState());

  final ProfileRepository _repository;

  void loadProfile() {
    try {
      final profile = _repository.getCurrentProfile();
      emit(state.copyWith(profile: profile));
    } catch (_) {}
  }

  Future<void> saveChanges({
    required String name,
    required String phone,
    required String address,
    required String email,
  }) async {
    emit(state.copyWith(status: EditProfileStatus.loading, error: null));

    try {
      final currentEmail = state.profile?.email ?? '';
      final emailChanged = email.trim() != currentEmail.trim();

      await _repository.updateProfile(
        name: name.trim(),
        phone: phone.trim(),
        address: address.trim(),
      );

      if (emailChanged) {
        await _repository.updateEmail(email.trim());
        final updated = state.profile?.copyWith(
          name: name.trim(),
          phone: phone.trim(),
          address: address.trim(),
        );
        emit(state.copyWith(
          status: EditProfileStatus.emailConfirmationSent,
          profile: updated,
          error: null,
        ));
      } else {
        final updated = state.profile?.copyWith(
          name: name.trim(),
          phone: phone.trim(),
          address: address.trim(),
        );
        emit(state.copyWith(
          status: EditProfileStatus.success,
          profile: updated,
          error: null,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: EditProfileStatus.error,
        error: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  void resetStatus() {
    emit(state.copyWith(status: EditProfileStatus.initial, error: null));
  }
}
