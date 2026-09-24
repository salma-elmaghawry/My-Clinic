import 'package:supabase_flutter/supabase_flutter.dart' show User;
import 'package:my_clinic/features/auth/domain/entities/auth_user.dart';

class AuthUserModel {
  final String id;
  final String email;
  final String name;

  const AuthUserModel({required this.id, required this.email, this.name = ''});

  factory AuthUserModel.fromSupabaseUser(User user) {
    return AuthUserModel(
      id: user.id,
      email: user.email ?? '',
      name: (user.userMetadata?['name'] as String?) ?? '',
    );
  }

  AuthUser toEntity() => AuthUser(id: id, email: email, name: name);
}
