import 'package:equatable/equatable.dart';

import '../../../models/user_model.dart';

enum AuthStatus {
  initial,
  loading,
  otpSent,
  authenticated,
  unauthenticated,
  passwordResetSuccess,
  failure,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final UserModel? user;

  /// Preserved across states for the OTP and forgot-password flows.
  final String? email;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.email,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? email,
    String? errorMessage,
  }) =>
      AuthState(
        status: status ?? this.status,
        user: user ?? this.user,
        email: email ?? this.email,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  /// Clears errorMessage so that re-emitting the same status triggers listeners.
  AuthState copyWithError(String message) => AuthState(
        status: AuthStatus.failure,
        user: user,
        email: email,
        errorMessage: message,
      );

  @override
  List<Object?> get props => [status, user, email, errorMessage];
}
