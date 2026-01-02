import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final bool needsEmailVerification;

  AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.needsEmailVerification = false,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool? needsEmailVerification,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
      needsEmailVerification: needsEmailVerification ?? this.needsEmailVerification,
    );
  }

  bool get isAuthenticated => user != null;
  bool get isEmailVerified => user?.emailVerified ?? false;
}

class AuthNotifier extends StateNotifier<AuthState> {
  FirebaseAuth? _auth;
  bool _isFirebaseAvailable = false;

  AuthNotifier() : super(AuthState()) {
    _initFirebase();
  }

  Future<void> _initFirebase() async {
    try {
      _auth = FirebaseAuth.instance;
      _isFirebaseAvailable = true;
      
      // Listen to auth state changes
      _auth!.authStateChanges().listen((user) {
        state = state.copyWith(user: user);
      });
    } catch (e) {
      _isFirebaseAvailable = false;
      print('Firebase not available: $e');
    }
  }

  // Register with Email & Password
  Future<bool> registerWithEmail(String email, String password, String name) async {
    if (!_isFirebaseAvailable || _auth == null) {
      state = state.copyWith(
        errorMessage: 'Firebase উপলব্ধ নেই। অফলাইন মোডে চালিয়ে যান।',
      );
      return false;
    }
    
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // Create user
      final userCredential = await _auth!.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(name.trim());
      
      // Send email verification
      await userCredential.user?.sendEmailVerification();
      
      // Sign out so user must verify first
      await _auth!.signOut();
      
      state = state.copyWith(
        user: null,
        isLoading: false,
        needsEmailVerification: true,
        successMessage: 'অ্যাকাউন্ট তৈরি হয়েছে! ইমেইল ভেরিফাই করে লগইন করুন।',
      );
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getErrorMessage(e.code),
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getErrorMessage(e.toString()),
      );
      return false;
    }
  }

  // Login with Email & Password
  Future<bool> loginWithEmail(String email, String password) async {
    if (!_isFirebaseAvailable || _auth == null) {
      state = state.copyWith(
        errorMessage: 'Firebase উপলব্ধ নেই। অফলাইন মোডে চালিয়ে যান।',
      );
      return false;
    }
    
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final userCredential = await _auth!.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      // Check if email is verified
      if (userCredential.user != null && !userCredential.user!.emailVerified) {
        // Send another verification email
        await userCredential.user!.sendEmailVerification();
        await _auth!.signOut();
        
        state = state.copyWith(
          user: null,
          isLoading: false,
          needsEmailVerification: true,
          errorMessage: 'ইমেইল ভেরিফাই করা হয়নি। নতুন ভেরিফিকেশন লিংক পাঠানো হয়েছে।',
        );
        return false;
      }
      
      state = state.copyWith(
        user: userCredential.user,
        isLoading: false,
        needsEmailVerification: false,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getErrorMessage(e.code),
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getErrorMessage(e.toString()),
      );
      return false;
    }
  }

  // Forgot Password
  Future<bool> forgotPassword(String email) async {
    if (!_isFirebaseAvailable || _auth == null) {
      state = state.copyWith(
        errorMessage: 'Firebase উপলব্ধ নেই।',
      );
      return false;
    }
    
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      await _auth!.sendPasswordResetEmail(email: email.trim());
      
      state = state.copyWith(
        isLoading: false,
        successMessage: 'পাসওয়ার্ড রিসেট লিংক পাঠানো হয়েছে!',
      );
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getErrorMessage(e.code),
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _getErrorMessage(e.toString()),
      );
      return false;
    }
  }

  // Resend verification email
  Future<bool> resendVerificationEmail(String email, String password) async {
    if (!_isFirebaseAvailable || _auth == null) {
      state = state.copyWith(
        errorMessage: 'Firebase উপলব্ধ নেই।',
      );
      return false;
    }
    
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);
      
      // Sign in temporarily to send verification
      final userCredential = await _auth!.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      await userCredential.user?.sendEmailVerification();
      await _auth!.signOut();
      
      state = state.copyWith(
        isLoading: false,
        successMessage: 'নতুন ভেরিফিকেশন লিংক পাঠানো হয়েছে!',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'ভেরিফিকেশন লিংক পাঠাতে সমস্যা হয়েছে',
      );
      return false;
    }
  }

  // Update Display Name
  Future<bool> updateDisplayName(String name) async {
    if (!_isFirebaseAvailable || _auth == null || _auth!.currentUser == null) {
      state = state.copyWith(
        errorMessage: 'লগইন করা হয়নি',
      );
      return false;
    }
    
    try {
      await _auth!.currentUser!.updateDisplayName(name);
      await _auth!.currentUser!.reload();
      state = state.copyWith(user: _auth!.currentUser);
      return true;
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'নাম আপডেট করতে সমস্যা হয়েছে',
      );
      return false;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      state = state.copyWith(isLoading: true);
      await _auth?.signOut();
      state = state.copyWith(
        user: null,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'সাইন আউট ব্যর্থ হয়েছে',
      );
    }
  }

  // Skip authentication (offline mode)
  void skipAuthentication() {
    state = state.copyWith(isLoading: false, user: null);
  }

  // Clear messages
  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }

  // Error messages in Bengali
  String _getErrorMessage(String code) {
    if (code.contains('email-already-in-use')) {
      return 'এই ইমেইল আগে থেকেই রেজিস্টার্ড';
    } else if (code.contains('invalid-email')) {
      return 'ইমেইল ঠিকানা সঠিক নয়';
    } else if (code.contains('weak-password')) {
      return 'পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের হতে হবে';
    } else if (code.contains('user-not-found')) {
      return 'এই ইমেইলে কোনো অ্যাকাউন্ট নেই';
    } else if (code.contains('wrong-password')) {
      return 'পাসওয়ার্ড ভুল হয়েছে';
    } else if (code.contains('user-disabled')) {
      return 'এই অ্যাকাউন্ট নিষ্ক্রিয় করা হয়েছে';
    } else if (code.contains('too-many-requests')) {
      return 'অনেক বেশি চেষ্টা হয়েছে। কিছুক্ষণ পর আবার চেষ্টা করুন';
    } else if (code.contains('invalid-credential')) {
      return 'ইমেইল বা পাসওয়ার্ড ভুল';
    } else {
      return 'কিছু সমস্যা হয়েছে। আবার চেষ্টা করুন';
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
