/// Mock authentication service
/// This service provides mock authentication without real backend validation
class AuthService {
  /// Validates email format
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  /// Mock login - validates format and returns success
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Validate email format
    if (email.isEmpty) {
      return AuthResult.failure('Email is required');
    }
    if (!_isValidEmail(email)) {
      return AuthResult.failure('Invalid email format');
    }

    // Validate password
    if (password.isEmpty) {
      return AuthResult.failure('Password is required');
    }
    if (password.length < 6) {
      return AuthResult.failure('Password must be at least 6 characters');
    }

    // Mock success - accept any valid format
    return AuthResult.success(email);
  }

  /// Mock signup - validates format and returns success
  Future<AuthResult> signup({
    required String email,
    required String password,
    required String confirmPassword,
    required int? age,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));

    // Validate email format
    if (email.isEmpty) {
      return AuthResult.failure('Email is required');
    }
    if (!_isValidEmail(email)) {
      return AuthResult.failure('Invalid email format');
    }

    // Validate password
    if (password.isEmpty) {
      return AuthResult.failure('Password is required');
    }
    if (password.length < 6) {
      return AuthResult.failure('Password must be at least 6 characters');
    }

    // Validate password confirmation
    if (confirmPassword.isEmpty) {
      return AuthResult.failure('Please confirm your password');
    }
    if (password != confirmPassword) {
      return AuthResult.failure('Passwords do not match');
    }

    // Validate age
    if (age == null) {
      return AuthResult.failure('Age is required');
    }
    if (age < 13 || age > 120) {
      return AuthResult.failure('Please enter a valid age (13-120)');
    }

    // Mock success - accept any valid format
    return AuthResult.success(email, age);
  }

  /// Mock logout
  Future<void> logout() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
  }
}

/// Authentication result
class AuthResult {
  final bool isSuccess;
  final String? email;
  final int? age;
  final String? errorMessage;

  AuthResult._({
    required this.isSuccess,
    this.email,
    this.age,
    this.errorMessage,
  });

  factory AuthResult.success(String email, [int? age]) {
    return AuthResult._(isSuccess: true, email: email, age: age);
  }

  factory AuthResult.failure(String message) {
    return AuthResult._(isSuccess: false, errorMessage: message);
  }
}
