import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/auth_state.dart';
import '../data/auth_service.dart';

/// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// Auth state notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState());

  /// Login with email and password
  Future<String?> login(String email, String password) async {
    final result = await _authService.login(email: email, password: password);

    if (result.isSuccess) {
      state = AuthState(isAuthenticated: true, userEmail: result.email);
      return null; // Success
    } else {
      return result.errorMessage; // Error message
    }
  }

  /// Sign up with email, password, and age
  Future<String?> signup(
    String email,
    String password,
    String confirmPassword,
    int? age,
  ) async {
    final result = await _authService.signup(
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      age: age,
    );

    if (result.isSuccess) {
      state = AuthState(
        isAuthenticated: true,
        userEmail: result.email,
        userAge: result.age,
      );
      return null; // Success
    } else {
      return result.errorMessage; // Error message
    }
  }

  /// Logout
  Future<void> logout() async {
    await _authService.logout();
    state = const AuthState();
  }
}

/// Auth state provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});
