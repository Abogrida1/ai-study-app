import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String role;
  final String fullName;
  final String universityId;
  final String? avatarUrl;

  const UserEntity({
    required this.id,
    required this.email,
    required this.role,
    required this.fullName,
    required this.universityId,
    this.avatarUrl,
  });

  bool get isStudent => role == 'student';
  bool get isDoctor => role == 'doctor';
  bool get isTA => role == 'ta';

  @override
  List<Object?> get props => [id, email, role, fullName, universityId, avatarUrl];
}
