import 'package:shoplux/features/profile/domain/models/user_profile.dart';

abstract interface class ProfileRepository {
  UserProfile getCurrentProfile();

  Future<void> updateProfile({
    required String name,
    required String phone,
    required String address,
  });

  Future<void> updateEmail(String email);
}
