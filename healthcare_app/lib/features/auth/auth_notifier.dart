import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  final String? role;
  final String? userId;
  final String? userName;
  final bool isLoggedIn;

  AuthState({
    this.role,
    this.userId,
    this.userName,
    this.isLoggedIn = false,
  });

  AuthState copyWith({
    String? role,
    String? userId,
    String? userName,
    bool? isLoggedIn,
  }) {
    return AuthState(
      role: role ?? this.role,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  void login(String role, String userId, String userName) {
    state = AuthState(
      role: role,
      userId: userId,
      userName: userName,
      isLoggedIn: true,
    );
  }

  void logout() {
    state = AuthState();
  }

  bool get isDoctor => state.role == 'doctor';
  bool get isPatient => state.role == 'patient';
  bool get isAdmin => state.role == 'admin';
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
