// Authentication Manager - Base interface for auth implementations
//
// This abstract class and mixins define the contract for authentication systems.
// Implement this with concrete classes for Firebase, Supabase, or local auth.
//
// Usage:
// 1. Create a concrete class extending AuthManager
// 2. Mix in the required authentication provider mixins
// 3. Implement all abstract methods with your auth provider logic

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:parallel_paradigm_org/supabase/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Core authentication operations that all auth implementations must provide
abstract class AuthManager {
  Future<void> signOut();
  Future<void> deleteUser(BuildContext context);
  Future<void> updateEmail({required String email, required BuildContext context});
  Future<void> resetPassword({required String email, required BuildContext context});

  /// For Supabase, email verification is typically handled via auth settings
  /// (confirmation emails on signup, email-change confirmation, etc.).
  Future<void> sendEmailVerification({required User user});

  /// Returns the latest user object, or null if signed out.
  Future<User?> refreshUser();
}

// Email/password authentication mixin
mixin EmailSignInManager on AuthManager {
  Future<User?> signInWithEmail(
    BuildContext context,
    String email,
    String password,
  );

  Future<User?> createAccountWithEmail(
    BuildContext context,
    String email,
    String password,
  );
}

/// Supabase-backed auth implementation.
///
/// Notes:
/// - Account deletion generally requires a server-side privileged call.
/// - Email verification flows are governed by Supabase project settings.
class SupabaseAuthManager extends AuthManager with EmailSignInManager {
  @override
  Future<User?> createAccountWithEmail(BuildContext context, String email, String password) async {
    try {
      final res = await SupabaseConfig.auth.signUp(email: email, password: password);
      return res.user;
    } on AuthException catch (e) {
      debugPrint('[Auth] signUp failed: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[Auth] signUp failed: $e');
      rethrow;
    }
  }

  @override
  Future<User?> signInWithEmail(BuildContext context, String email, String password) async {
    try {
      final res = await SupabaseConfig.auth.signInWithPassword(email: email, password: password);
      return res.user;
    } on AuthException catch (e) {
      debugPrint('[Auth] signIn failed: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[Auth] signIn failed: $e');
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await SupabaseConfig.auth.signOut();
    } catch (e) {
      debugPrint('[Auth] signOut failed: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteUser(BuildContext context) async {
    // Supabase user deletion requires the Service Role key (server-side) or an Edge Function.
    debugPrint('[Auth] deleteUser requested but not supported client-side for Supabase.');
    throw Exception('Account deletion requires a server-side privileged call.');
  }

  @override
  Future<void> updateEmail({required String email, required BuildContext context}) async {
    try {
      await SupabaseConfig.auth.updateUser(UserAttributes(email: email));
    } on AuthException catch (e) {
      debugPrint('[Auth] updateEmail failed: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[Auth] updateEmail failed: $e');
      rethrow;
    }
  }

  @override
  Future<void> resetPassword({required String email, required BuildContext context}) async {
    try {
      await SupabaseConfig.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      debugPrint('[Auth] resetPassword failed: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[Auth] resetPassword failed: $e');
      rethrow;
    }
  }

  @override
  Future<void> sendEmailVerification({required User user}) async {
    // Supabase does not expose a direct "send verification" method on User like Firebase.
    // Verification is typically triggered via signup or email change confirmation.
    debugPrint('[Auth] sendEmailVerification called (no-op for Supabase). userId=${user.id}');
  }

  @override
  Future<User?> refreshUser() async {
    try {
      final res = await SupabaseConfig.auth.getUser();
      return res.user;
    } catch (e) {
      debugPrint('[Auth] refreshUser failed: $e');
      rethrow;
    }
  }
}

// Anonymous authentication for guest users
mixin AnonymousSignInManager on AuthManager {
  Future<User?> signInAnonymously(BuildContext context);
}

// Apple Sign-In authentication (iOS/web)
mixin AppleSignInManager on AuthManager {
  Future<User?> signInWithApple(BuildContext context);
}

// Google Sign-In authentication (all platforms)
mixin GoogleSignInManager on AuthManager {
  Future<User?> signInWithGoogle(BuildContext context);
}

// JWT token authentication for custom backends
mixin JwtSignInManager on AuthManager {
  Future<User?> signInWithJwtToken(
    BuildContext context,
    String jwtToken,
  );
}

// Phone number authentication with SMS verification
mixin PhoneSignInManager on AuthManager {
  Future beginPhoneAuth({
    required BuildContext context,
    required String phoneNumber,
    required void Function(BuildContext) onCodeSent,
  });

  Future verifySmsCode({
    required BuildContext context,
    required String smsCode,
  });
}

// Facebook Sign-In authentication
mixin FacebookSignInManager on AuthManager {
  Future<User?> signInWithFacebook(BuildContext context);
}

// Microsoft Sign-In authentication (Azure AD)
mixin MicrosoftSignInManager on AuthManager {
  Future<User?> signInWithMicrosoft(
    BuildContext context,
    List<String> scopes,
    String tenantId,
  );
}

// GitHub Sign-In authentication (OAuth)
mixin GithubSignInManager on AuthManager {
  Future<User?> signInWithGithub(BuildContext context);
}
