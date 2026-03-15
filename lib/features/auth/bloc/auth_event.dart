import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class SignupRequested extends AuthEvent {
  final String name;
  final String username;
  final String email;
  final String password;

  const SignupRequested({
    required this.name,
    required this.username,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [name, username, email, password];
}

class OtpVerified extends AuthEvent {
  final String email;
  final String otp;

  const OtpVerified({required this.email, required this.otp});

  @override
  List<Object?> get props => [email, otp];
}

class OtpResendRequested extends AuthEvent {
  final String email;

  const OtpResendRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class ForgotPasswordRequested extends AuthEvent {
  final String email;

  const ForgotPasswordRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

class PasswordResetRequested extends AuthEvent {
  final String email;
  final String otp;
  final String newPassword;

  const PasswordResetRequested({
    required this.email,
    required this.otp,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [email, otp, newPassword];
}
