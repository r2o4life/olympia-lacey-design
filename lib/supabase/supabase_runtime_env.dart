import 'package:flutter/foundation.dart';

import 'package:parallel_paradigm_org/supabase/supabase_runtime_env_stub.dart'
    if (dart.library.html) 'package:parallel_paradigm_org/supabase/supabase_runtime_env_web.dart';

/// Runtime environment access for Supabase credentials.
///
/// Why this exists:
/// - Flutter web preview environments sometimes don't provide `--dart-define`.
/// - Dreamflow (or other hosts) may persist config in browser storage.
///
/// We only read *public* values (Supabase URL + anon key). Never store secrets.
abstract class SupabaseRuntimeEnv {
  static void debugDump() {
    try {
      SupabaseRuntimeEnvImpl.debugDump();
    } catch (e) {
      debugPrint('[SupabaseRuntimeEnv] debugDump failed: $e');
    }
  }

  static String? get(String key) {
    try {
      return SupabaseRuntimeEnvImpl.get(key);
    } catch (e) {
      debugPrint('[SupabaseRuntimeEnv] get($key) failed: $e');
      return null;
    }
  }

  static String? getAny(List<String> keys) {
    for (final k in keys) {
      final v = get(k);
      if (v != null && v.trim().isNotEmpty) return v;
    }
    return null;
  }

  /// Writes a public runtime value (Supabase URL / anon key) when supported.
  ///
  /// This exists primarily for Flutter web previews where compile-time
  /// `--dart-define` is not available.
  static bool set(String key, String value) {
    try {
      return SupabaseRuntimeEnvImpl.set(key, value);
    } catch (e) {
      debugPrint('[SupabaseRuntimeEnv] set($key) failed: $e');
      return false;
    }
  }
}
