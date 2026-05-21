import 'package:shoplux/features/profile/domain/models/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class ProfileRemoteDataSource {
  UserProfile getCurrentProfile();
  Future<void> updateProfile({
    required String name,
    required String phone,
    required String address,
  });
  Future<void> updateEmail(String email);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  const ProfileRemoteDataSourceImpl({required this.client});

  final SupabaseClient client;

  @override
  UserProfile getCurrentProfile() {
    final user = client.auth.currentUser;
    if (user == null) throw Exception('No authenticated user');
    return UserProfile.fromSupabase(user);
  }

  @override
  Future<void> updateProfile({
    required String name,
    required String phone,
    required String address,
  }) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) throw Exception('No authenticated user');

    await client.auth.updateUser(
      UserAttributes(
        data: {
          'full_name': name,
          'phone': phone,
          'address': address,
        },
      ),
    );

    // Persist address to the users table Location column
    await client
        .from('users')
        .update({'Location': address})
        .eq('id', userId);
  }

  @override
  Future<void> updateEmail(String email) async {
    await client.auth.updateUser(UserAttributes(email: email));
  }
}
