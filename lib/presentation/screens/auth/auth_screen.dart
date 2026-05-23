import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/services/firestore_sync_service.dart';
import '../../providers/auth_provider.dart';
import '../main_shell.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLogin = true;
  bool _isForgotPassword = false;
  bool _showVerificationScreen = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MainShell()),
    );
  }

  Future<void> _restoreDataFromCloud() async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 12),
              const Text('ক্লাউড থেকে ডেটা লোড হচ্ছে...'),
            ],
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
      );
    }

    try {
      await firestoreSyncService.restoreAllData();
    } catch (e) {
      print('Error restoring data: $e');
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final authNotifier = ref.read(authProvider.notifier);

    if (_isForgotPassword) {
      final success = await authNotifier.forgotPassword(_emailController.text);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('পাসওয়ার্ড রিসেট লিংক পাঠানো হয়েছে!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
        setState(() {
          _isForgotPassword = false;
        });
      }
    } else if (_isLogin) {
      final success = await authNotifier.loginWithEmail(
        _emailController.text,
        _passwordController.text,
      );
      if (success && mounted) {
        await _restoreDataFromCloud();
        _navigateToHome();
      }
    } else {
      final success = await authNotifier.registerWithEmail(
        _emailController.text,
        _passwordController.text,
        _nameController.text,
      );
      if (success && mounted) {
        setState(() {
          _showVerificationScreen = true;
        });
      }
    }
  }

  Future<void> _resendVerification() async {
    final authNotifier = ref.read(authProvider.notifier);
    final success = await authNotifier.resendVerificationEmail(
      _emailController.text,
      _passwordController.text,
    );
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('নতুন ভেরিফিকেশন লিংক পাঠানো হয়েছে!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  void _goBackToLogin() {
    setState(() {
      _showVerificationScreen = false;
      _isLogin = true;
    });
  }

  void _handleSkip() {
    ref.read(authProvider.notifier).skipAuthentication();
    _navigateToHome();
  }

  void _showLanguagePicker() {
    final cs = Theme.of(context).colorScheme;
    final currentLang = context.locale.languageCode;

    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.onSurface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'language_select'.tr(),
              style: TextStyle(
                color: cs.primary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _langOption(
              ctx: ctx,
              flag: '🇧🇩',
              label: 'বাংলা',
              sublabel: 'Bengali',
              langCode: 'bn',
              isSelected: currentLang == 'bn',
              cs: cs,
            ),
            const SizedBox(height: 8),
            _langOption(
              ctx: ctx,
              flag: '🇬🇧',
              label: 'English',
              sublabel: 'ইংরেজি',
              langCode: 'en',
              isSelected: currentLang == 'en',
              cs: cs,
            ),
          ],
        ),
      ),
    );
  }

  Widget _langOption({
    required BuildContext ctx,
    required String flag,
    required String label,
    required String sublabel,
    required String langCode,
    required bool isSelected,
    required ColorScheme cs,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        ctx.setLocale(Locale(langCode));
        Navigator.pop(ctx);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? cs.primary.withOpacity(0.12)
              : cs.surfaceContainerHighest.withOpacity(0.4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? cs.primary.withOpacity(0.4)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    sublabel,
                    style: TextStyle(
                      color: cs.onSurface.withOpacity(0.55),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: cs.primary, size: 22),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final cs = Theme.of(context).colorScheme;

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: cs.error,
          ),
        );
      }
      if (next.needsEmailVerification && !previous!.needsEmailVerification) {
        setState(() {
          _showVerificationScreen = true;
        });
      }
    });

    if (_showVerificationScreen) {
      return _buildVerificationScreen(authState);
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Logo
                  Image.asset('assets/images/logo.png', width: 90, height: 90),
                  const SizedBox(height: 12),

                  // App title
                  Text(
                    'app_title'.tr(),
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Subtitle / mode label
                  Text(
                    _isForgotPassword
                        ? 'forgot_password_title'.tr()
                        : _isLogin
                        ? 'login_title'.tr()
                        : 'register_title'.tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: cs.onSurface.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Name field (only for register)
                        if (!_isLogin && !_isForgotPassword)
                          _buildTextField(
                            controller: _nameController,
                            label: 'name'.tr(),
                            icon: Icons.person_outline,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'নাম লিখুন';
                              }
                              return null;
                            },
                          ),

                        // Email field
                        _buildTextField(
                          controller: _emailController,
                          label: 'email'.tr(),
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'ইমেইল লিখুন';
                            }
                            if (!value.contains('@')) {
                              return 'সঠিক ইমেইল লিখুন';
                            }
                            return null;
                          },
                        ),

                        // Password field
                        if (!_isForgotPassword)
                          _buildTextField(
                            controller: _passwordController,
                            label: 'password'.tr(),
                            icon: Icons.lock_outline,
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: cs.onSurface.withOpacity(0.6),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'পাসওয়ার্ড লিখুন';
                              }
                              if (value.length < 6) {
                                return 'কমপক্ষে ৬ অক্ষর দিন';
                              }
                              return null;
                            },
                          ),

                        // Confirm Password field (only for register)
                        if (!_isLogin && !_isForgotPassword)
                          _buildTextField(
                            controller: _confirmPasswordController,
                            label: 'confirm_password'.tr(),
                            icon: Icons.lock_outline,
                            obscureText: _obscureConfirmPassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: cs.onSurface.withOpacity(0.6),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'পাসওয়ার্ড নিশ্চিত করুন';
                              }
                              if (value != _passwordController.text) {
                                return 'পাসওয়ার্ড মিলছে না';
                              }
                              return null;
                            },
                          ),

                        // Forgot Password link
                        if (_isLogin && !_isForgotPassword)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  _isForgotPassword = true;
                                });
                              },
                              child: Text(
                                'forgot_password_link'.tr(),
                                style: TextStyle(
                                  color: cs.primary.withOpacity(0.8),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(height: 24),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: authState.isLoading
                                ? null
                                : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: cs.primary,
                              foregroundColor: cs.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: authState.isLoading
                                ? SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: cs.onPrimary,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    _isForgotPassword
                                        ? 'submit_reset'.tr()
                                        : _isLogin
                                        ? 'submit_login'.tr()
                                        : 'submit_register'.tr(),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Toggle Login/Register or Back
                        if (_isForgotPassword)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isForgotPassword = false;
                              });
                            },
                            child: Text(
                              'back_to_login'.tr(),
                              style: TextStyle(
                                color: cs.onSurface.withOpacity(0.6),
                                fontSize: 14,
                              ),
                            ),
                          )
                        else
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _isLogin
                                    ? 'no_account'.tr()
                                    : 'have_account'.tr(),
                                style: TextStyle(
                                  color: cs.onSurface.withOpacity(0.6),
                                  fontSize: 14,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isLogin = !_isLogin;
                                    _formKey.currentState?.reset();
                                  });
                                },
                                child: Text(
                                  _isLogin
                                      ? 'register'.tr()
                                      : 'submit_login'.tr(),
                                  style: TextStyle(
                                    color: cs.primary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(height: 16),

                        // Divider
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: cs.onSurface.withOpacity(0.2),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Text(
                                'or'.tr(),
                                style: TextStyle(
                                  color: cs.onSurface.withOpacity(0.4),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: cs.onSurface.withOpacity(0.2),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Skip Button (Offline Mode)
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton(
                            onPressed: _handleSkip,
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: cs.onSurface.withOpacity(0.2),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.cloud_off,
                                  color: cs.onSurface.withOpacity(0.6),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'offline_mode'.tr(),
                                  style: TextStyle(
                                    color: cs.onSurface.withOpacity(0.6),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Info text
                        Text(
                          'offline_info'.tr(),
                          style: TextStyle(
                            color: cs.onSurface.withOpacity(0.5),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Language switcher button (top-right)
            Positioned(
              top: 8,
              right: 8,
              child: TextButton.icon(
                onPressed: _showLanguagePicker,
                icon: Icon(Icons.language_rounded, size: 18, color: cs.primary),
                label: Text(
                  context.locale.languageCode == 'bn' ? 'EN' : 'বাং',
                  style: TextStyle(
                    color: cs.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        style: TextStyle(color: cs.onSurface),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: cs.onSurface.withOpacity(0.6)),
          prefixIcon: Icon(icon, color: cs.onSurface.withOpacity(0.6)),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: cs.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: cs.onSurface.withOpacity(0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: cs.primary),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: cs.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: cs.error),
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationScreen(AuthState authState) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.mark_email_unread_outlined,
                  size: 80,
                  color: cs.primary,
                ),
              ),
              const SizedBox(height: 32),

              Text(
                'ইমেইল ভেরিফাই করুন',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: cs.primary,
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'আপনার ইমেইল ঠিকানায় একটি ভেরিফিকেশন লিংক পাঠানো হয়েছে। লিংকে ক্লিক করে ইমেইল ভেরিফাই করুন, তারপর লগইন করুন।',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: cs.onSurface.withOpacity(0.7),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.onSurface.withOpacity(0.1)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.email,
                      color: cs.onSurface.withOpacity(0.6),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _emailController.text,
                      style: TextStyle(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _goBackToLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'submit_login'.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextButton.icon(
                onPressed: authState.isLoading ? null : _resendVerification,
                icon: authState.isLoading
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: cs.primary,
                        ),
                      )
                    : const Icon(Icons.refresh, size: 18),
                label: Text(
                  authState.isLoading ? 'পাঠানো হচ্ছে...' : 'আবার লিংক পাঠান',
                  style: TextStyle(
                    color: cs.primary.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: cs.primary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: cs.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'ইমেইল না পেলে স্প্যাম ফোল্ডার চেক করুন',
                        style: TextStyle(
                          color: cs.onSurface.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
