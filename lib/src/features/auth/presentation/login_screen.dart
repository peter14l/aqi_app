import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_theme.dart';
import '../application/auth_provider.dart';

/// Login screen with responsive design for mobile and desktop
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final error = await ref
        .read(authProvider.notifier)
        .login(_emailController.text.trim(), _passwordController.text);

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
                    'Breathe Better, Live Healthier',
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
        // Right side - Login form
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(48),
              child: _buildLoginForm(isDark),
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
              'Welcome Back',
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
            _buildLoginForm(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginForm(bool isDark) {
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
              'Login',
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color:
                    isDark ? AppColors.textPrimary : AppColors.textPrimaryDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sign in to continue',
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
            // Password field
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
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
            const SizedBox(height: 32),
            // Login button
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
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
                          'LOGIN',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
              ),
            ),
            const SizedBox(height: 24),
            // Sign up link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account? ",
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color:
                        isDark
                            ? AppColors.textSecondary
                            : AppColors.textPrimaryDark.withOpacity(0.6),
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/signup'),
                  child: Text(
                    'Sign Up',
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
