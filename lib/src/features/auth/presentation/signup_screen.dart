import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_theme.dart';
import '../application/auth_provider.dart';

/// Signup screen with responsive design for mobile and desktop
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _ageController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  String _getPasswordStrength(String password) {
    if (password.isEmpty) return '';
    if (password.length < 6) return 'Weak';
    if (password.length < 10) return 'Medium';
    return 'Strong';
  }

  Color _getPasswordStrengthColor(String password, bool isDark) {
    final strength = _getPasswordStrength(password);
    if (strength == 'Weak') return AppColors.error;
    if (strength == 'Medium') return AppColors.warning;
    if (strength == 'Strong') return AppColors.success;
    return isDark
        ? AppColors.textTertiary
        : AppColors.textPrimaryDark.withOpacity(0.3);
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final age = int.tryParse(_ageController.text.trim());
    final error = await ref
        .read(authProvider.notifier)
        .signup(
          _emailController.text.trim(),
          _passwordController.text,
          _confirmPasswordController.text,
          age,
        );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (error != null) {
      setState(() => _errorMessage = error);
    } else {
      // Navigate to home screen
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 800;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.aqiGreenBackground,
      body: SafeArea(
        child:
            isDesktop
                ? _buildDesktopLayout(isDark)
                : _buildMobileLayout(isDark),
      ),
    );
  }

  Widget _buildDesktopLayout(bool isDark) {
    return Row(
      children: [
        // Left side - Branding
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors:
                    isDark
                        ? [
                          AppColors.neonCyan.withOpacity(0.2),
                          AppColors.neonPurple.withOpacity(0.2),
                        ]
                        : [
                          AppColors.textPrimaryDark.withOpacity(0.1),
                          AppColors.textPrimaryDark.withOpacity(0.05),
                        ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors:
                            isDark
                                ? [
                                  AppColors.neonCyan,
                                  AppColors.neonCyan.withOpacity(0.6),
                                ]
                                : [
                                  AppColors.textPrimaryDark,
                                  AppColors.textPrimaryDark.withOpacity(0.7),
                                ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isDark
                                  ? AppColors.neonCyan
                                  : AppColors.textPrimaryDark)
                              .withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.air, size: 60, color: Colors.white),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'AQI Assistant',
                    style: GoogleFonts.outfit(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color:
                          isDark
                              ? AppColors.textPrimary
                              : AppColors.textPrimaryDark,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Join Us Today',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      color:
                          isDark
                              ? AppColors.neonCyan
                              : AppColors.textPrimaryDark.withOpacity(0.7),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Right side - Signup form
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(48),
              child: _buildSignupForm(isDark),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(bool isDark) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors:
                      isDark
                          ? [
                            AppColors.neonCyan,
                            AppColors.neonCyan.withOpacity(0.6),
                          ]
                          : [
                            AppColors.textPrimaryDark,
                            AppColors.textPrimaryDark.withOpacity(0.7),
                          ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDark
                            ? AppColors.neonCyan
                            : AppColors.textPrimaryDark)
                        .withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(Icons.air, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              'AQI Assistant',
              style: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color:
                    isDark ? AppColors.textPrimary : AppColors.textPrimaryDark,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create Your Account',
              style: GoogleFonts.outfit(
                fontSize: 16,
                color:
                    isDark
                        ? AppColors.neonCyan
                        : AppColors.textPrimaryDark.withOpacity(0.7),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 48),
            _buildSignupForm(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildSignupForm(bool isDark) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.all(32),
      decoration:
          isDark
              ? AppTheme.glassDecoration()
              : BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 0,
                  ),
                ],
              ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Sign Up',
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color:
                    isDark ? AppColors.textPrimary : AppColors.textPrimaryDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your account to get started',
              style: GoogleFonts.outfit(
                fontSize: 14,
                color:
                    isDark
                        ? AppColors.textSecondary
                        : AppColors.textPrimaryDark.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 32),
            // Error message
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: AppColors.error, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            // Email field
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email',
                prefixIcon: Icon(
                  Icons.email_outlined,
                  color:
                      isDark ? AppColors.neonCyan : AppColors.textPrimaryDark,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email is required';
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return 'Invalid email format';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Age field
            TextFormField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Age',
                hintText: 'Enter your age',
                prefixIcon: Icon(
                  Icons.cake_outlined,
                  color:
                      isDark ? AppColors.neonCyan : AppColors.textPrimaryDark,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Age is required';
                }
                final age = int.tryParse(value);
                if (age == null) {
                  return 'Please enter a valid number';
                }
                if (age < 13 || age > 120) {
                  return 'Age must be between 13 and 120';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Password field
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              onChanged:
                  (value) => setState(() {}), // Rebuild for strength indicator
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
                prefixIcon: Icon(
                  Icons.lock_outline,
                  color:
                      isDark ? AppColors.neonCyan : AppColors.textPrimaryDark,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color:
                        isDark
                            ? AppColors.textSecondary
                            : AppColors.textPrimaryDark.withOpacity(0.6),
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password is required';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            // Password strength indicator
            if (_passwordController.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: _passwordController.text.length / 15,
                      backgroundColor:
                          isDark
                              ? AppColors.darkCard
                              : AppColors.textPrimaryDark.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getPasswordStrengthColor(
                          _passwordController.text,
                          isDark,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getPasswordStrength(_passwordController.text),
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: _getPasswordStrengthColor(
                        _passwordController.text,
                        isDark,
                      ),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            // Confirm password field
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                hintText: 'Re-enter your password',
                prefixIcon: Icon(
                  Icons.lock_outline,
                  color:
                      isDark ? AppColors.neonCyan : AppColors.textPrimaryDark,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color:
                        isDark
                            ? AppColors.textSecondary
                            : AppColors.textPrimaryDark.withOpacity(0.6),
                  ),
                  onPressed: () {
                    setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword,
                    );
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            // Signup button
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSignup,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isDark ? AppColors.neonCyan : AppColors.textPrimaryDark,
                  foregroundColor:
                      isDark ? AppColors.darkBackground : AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    _isLoading
                        ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDark
                                  ? AppColors.darkBackground
                                  : AppColors.white,
                            ),
                          ),
                        )
                        : Text(
                          'SIGN UP',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 24),
            // Login link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color:
                        isDark
                            ? AppColors.textSecondary
                            : AppColors.textPrimaryDark.withOpacity(0.6),
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text(
                    'Login',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color:
                          isDark
                              ? AppColors.neonCyan
                              : AppColors.textPrimaryDark,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
