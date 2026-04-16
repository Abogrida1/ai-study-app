import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final Map<String, dynamic> profile;

  const AuthAuthenticated(this.profile);

  @override
  List<Object?> get props => [profile];

  String? get userId => profile['id'];
  String? get role => profile['role'];
  String? get fullName => profile['full_name'];
  String? get universityId => profile['university_id'];
  String? get email => profile['email'];
  String? get avatarUrl => profile['avatar_url'];

  bool get isStudent => role == 'student';
  bool get isDoctor => role == 'doctor';
  bool get isTA => role == 'ta';
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
