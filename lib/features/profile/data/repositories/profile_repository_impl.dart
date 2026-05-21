import 'package:shoplux/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:shoplux/features/profile/domain/models/user_profile.dart';
import 'package:shoplux/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl({required this.dataSource});

  final ProfileRemoteDataSource dataSource;

  @override
  UserProfile getCurrentProfile() => dataSource.getCurrentProfile();

  @override
  Future<void> updateProfile({
    required String name,
    required String phone,
    required String address,
  }) =>
      dataSource.updateProfile(name: name, phone: phone, address: address);

  @override
  Future<void> updateEmail(String email) => dataSource.updateEmail(email);
}
