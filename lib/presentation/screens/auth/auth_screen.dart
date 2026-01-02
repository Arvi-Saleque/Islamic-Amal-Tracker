import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/firestore_sync_service.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';

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
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  Future<void> _restoreDataFromCloud() async {
    // Show loading indicator
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12),
              Text('ক্লাউড থেকে ডেটা লোড হচ্ছে...'),
            ],
          ),
          duration: Duration(seconds: 2),
          backgroundColor: Color(0xFF1A1A1A),
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
          const SnackBar(
            content: Text('পাসওয়ার্ড রিসেট লিংক পাঠানো হয়েছে!'),
            backgroundColor: Color(0xFF4CAF50),
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
        // Auto restore data from cloud on login
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
        const SnackBar(
          content: Text('নতুন ভেরিফিকেশন লিংক পাঠানো হয়েছে!'),
          backgroundColor: Color(0xFF4CAF50),
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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Show error message
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
      // Show verification screen when needed
      if (next.needsEmailVerification && !previous!.needsEmailVerification) {
        setState(() {
          _showVerificationScreen = true;
        });
      }
    });

    // Show verification screen
    if (_showVerificationScreen) {
      return _buildVerificationScreen(authState);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              // App Icon & Title
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGold.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_fix_high,
                  size: 60,
                  color: AppTheme.primaryGold,
                ),
              ),
              const SizedBox(height: 24),
              
              const Text(
                'আমল ট্র্যাকার',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGold,
                ),
              ),
              const SizedBox(height: 8),
              
              Text(
                _isForgotPassword 
                    ? 'পাসওয়ার্ড রিসেট করুন'
                    : _isLogin 
                        ? 'আপনার অ্যাকাউন্টে লগইন করুন' 
                        : 'নতুন অ্যাকাউন্ট তৈরি করুন',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 40),
              
              // Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Name field (only for register)
                    if (!_isLogin && !_isForgotPassword)
                      _buildTextField(
                        controller: _nameController,
                        label: 'আপনার নাম',
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
                      label: 'ইমেইল',
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
                    
                    // Password field (not for forgot password)
                    if (!_isForgotPassword)
                      _buildTextField(
                        controller: _passwordController,
                        label: 'পাসওয়ার্ড',
                        icon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
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
                        label: 'পাসওয়ার্ড নিশ্চিত করুন',
                        icon: Icons.lock_outline,
                        obscureText: _obscureConfirmPassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
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
                            'পাসওয়ার্ড ভুলে গেছেন?',
                            style: TextStyle(
                              color: AppTheme.primaryGold.withOpacity(0.8),
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
                        onPressed: authState.isLoading ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGold,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: authState.isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _isForgotPassword 
                                    ? 'রিসেট লিংক পাঠান'
                                    : _isLogin 
                                        ? 'লগইন করুন' 
                                        : 'রেজিস্টার করুন',
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
                          '← লগইন এ ফিরে যান',
                          style: TextStyle(
                            color: Colors.grey[400],
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
                                ? 'অ্যাকাউন্ট নেই?' 
                                : 'অ্যাকাউন্ট আছে?',
                            style: TextStyle(
                              color: Colors.grey[400],
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
                              _isLogin ? 'রেজিস্টার করুন' : 'লগইন করুন',
                              style: const TextStyle(
                                color: AppTheme.primaryGold,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    
                    const SizedBox(height: 32),
                    
                    // Divider
                    Row(
                      children: [
                        Expanded(
                          child: Divider(color: Colors.grey[700]),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'অথবা',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Skip Button (Offline Mode)
                    OutlinedButton(
                      onPressed: _handleSkip,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey[700]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.cloud_off,
                            color: Colors.grey[400],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'অফলাইনে চালিয়ে যান',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Info text
                    Text(
                      'অফলাইন মোডে ডেটা শুধু এই ডিভাইসে সেভ থাকবে',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 11,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(icon, color: Colors.grey[400]),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: const Color(0xFF1A1A1A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[800]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.primaryGold),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationScreen(AuthState authState) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Email Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGold.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_unread_outlined,
                  size: 80,
                  color: AppTheme.primaryGold,
                ),
              ),
              const SizedBox(height: 32),
              
              const Text(
                'ইমেইল ভেরিফাই করুন',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGold,
                ),
              ),
              const SizedBox(height: 16),
              
              Text(
                'আপনার ইমেইল ঠিকানায় একটি ভেরিফিকেশন লিংক পাঠানো হয়েছে। লিংকে ক্লিক করে ইমেইল ভেরিফাই করুন, তারপর লগইন করুন।',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[400],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[800]!),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.email, color: Colors.grey[400], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _emailController.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              
              // Login Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _goBackToLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGold,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'লগইন করুন',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Resend Button
              TextButton.icon(
                onPressed: authState.isLoading ? null : _resendVerification,
                icon: authState.isLoading 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.primaryGold,
                        ),
                      )
                    : const Icon(Icons.refresh, size: 18),
                label: Text(
                  authState.isLoading ? 'পাঠানো হচ্ছে...' : 'আবার লিংক পাঠান',
                  style: TextStyle(
                    color: AppTheme.primaryGold.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'ইমেইল না পেলে স্প্যাম ফোল্ডার চেক করুন',
                        style: TextStyle(
                          color: Colors.blue[200],
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
