import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
  });

  factory UserProfile.fromSupabase(User user) {
    final meta = user.userMetadata ?? {};
    return UserProfile(
      id: user.id,
      name: meta['full_name'] as String? ??
          meta['name'] as String? ??
          meta['username'] as String? ??
          '',
      email: user.email ?? '',
      phone: meta['phone'] as String? ?? '',
      address: meta['address'] as String? ?? '',
    );
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
    );
  }
}
