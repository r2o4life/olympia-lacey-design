import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:parallel_paradigm_org/supabase/supabase_runtime_env.dart';
import 'package:parallel_paradigm_org/supabase/supabase_project_defaults.dart';

class SupabaseConfig {
  /// Prefer compile-time env vars for deployments:
  /// - SUPABASE_URL
  /// - SUPABASE_ANON_KEY
  ///
  /// In Dreamflow, connect Supabase via the Supabase panel (no CLI required).
  /// If env vars are missing, we run the app without a backend.
  // Dreamflow / CI systems sometimes use different `--dart-define` keys.
  // We accept a small set of common aliases to reduce "connected but not detected" cases.
  static String? _cachedUrl;
  static String? _cachedAnonKey;
  static bool _didInitialize = false;
  static bool _initializing = false;
  static bool _loggedNotConfigured = false;

  static String _firstNonEmpty(List<String?> values) {
    for (final v in values) {
      if (v == null) continue;
      final t = v.trim();
      if (t.isNotEmpty) return t;
    }
    return '';
  }

  static String get supabaseUrl {
    final cached = _cachedUrl;
    if (cached != null && cached.trim().isNotEmpty) return cached;

    const primary = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    const alias1 = String.fromEnvironment('SUPABASE_PROJECT_URL', defaultValue: '');
    const alias2 = String.fromEnvironment('SUPABASE_API_URL', defaultValue: '');
    const alias3 = String.fromEnvironment('SUPABASE_ENDPOINT', defaultValue: '');
    const alias4 = String.fromEnvironment('SUPABASE_PROJECT_ENDPOINT', defaultValue: '');
    const dreamflow1 = String.fromEnvironment('DREAMFLOW_SUPABASE_URL', defaultValue: '');
    const dreamflow2 = String.fromEnvironment('DREAMFLOW_SUPABASE_PROJECT_URL', defaultValue: '');
    const dreamflow3 = String.fromEnvironment('DREAMFLOW_SUPABASE_PROJECT_ENDPOINT', defaultValue: '');

    final runtime = SupabaseRuntimeEnv.getAny(const [
      'SUPABASE_URL',
      'SUPABASE_PROJECT_URL',
      'SUPABASE_API_URL',
      'SUPABASE_ENDPOINT',
      'SUPABASE_PROJECT_ENDPOINT',
      'DREAMFLOW_SUPABASE_URL',
      'DREAMFLOW_SUPABASE_PROJECT_URL',
      'DREAMFLOW_SUPABASE_PROJECT_ENDPOINT',
    ]);

    final resolved = _firstNonEmpty([
      primary,
      alias1,
      alias2,
      alias3,
      alias4,
      dreamflow1,
      dreamflow2,
      dreamflow3,
      runtime,
      // Final fallback: project defaults (safe for client apps).
      SupabaseProjectDefaults.url,
    ]);
    // IMPORTANT: only cache non-empty values. In Dreamflow, the Supabase panel can
    // inject runtime values after a user connects, and caching an empty string
    // would permanently lock the app into "not configured".
    if (resolved.trim().isNotEmpty) _cachedUrl = resolved;
    return resolved;
  }

  static String get anonKey {
    final cached = _cachedAnonKey;
    if (cached != null && cached.trim().isNotEmpty) return cached;

    const primary = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');
    const alias1 = String.fromEnvironment('SUPABASE_PUBLIC_ANON_KEY', defaultValue: '');
    const alias2 = String.fromEnvironment('SUPABASE_ANON_PUBLIC_KEY', defaultValue: '');
    const alias3 = String.fromEnvironment('SUPABASE_KEY', defaultValue: '');
    const alias4 = String.fromEnvironment('SUPABASE_ANON', defaultValue: '');
    const alias5 = String.fromEnvironment('SUPABASE_ANON_TOKEN', defaultValue: '');
    const dreamflow1 = String.fromEnvironment('DREAMFLOW_SUPABASE_ANON_KEY', defaultValue: '');
    const dreamflow2 = String.fromEnvironment('DREAMFLOW_SUPABASE_PUBLIC_ANON_KEY', defaultValue: '');
    const dreamflow3 = String.fromEnvironment('DREAMFLOW_SUPABASE_ANON_PUBLIC_KEY', defaultValue: '');

    final runtime = SupabaseRuntimeEnv.getAny(const [
      'SUPABASE_ANON_KEY',
      'SUPABASE_PUBLIC_ANON_KEY',
      'SUPABASE_ANON_PUBLIC_KEY',
      'SUPABASE_KEY',
      'SUPABASE_ANON',
      'SUPABASE_ANON_TOKEN',
      'DREAMFLOW_SUPABASE_ANON_KEY',
      'DREAMFLOW_SUPABASE_PUBLIC_ANON_KEY',
      'DREAMFLOW_SUPABASE_ANON_PUBLIC_KEY',
    ]);

    final resolved = _firstNonEmpty([
      primary,
      alias1,
      alias2,
      alias3,
      alias4,
      alias5,
      dreamflow1,
      dreamflow2,
      dreamflow3,
      runtime,
      // Final fallback: project defaults (safe for client apps).
      SupabaseProjectDefaults.anonKey,
    ]);
    if (resolved.trim().isNotEmpty) _cachedAnonKey = resolved;
    return resolved;
  }

  static bool get isConfigured => supabaseUrl.trim().isNotEmpty && anonKey.trim().isNotEmpty;

  static bool get isInitialized => _didInitialize;

  /// Initializes Supabase *if* credentials are present.
  ///
  /// This is safe to call multiple times; it will no-op after first init.
  static Future<void> initialize() async {
    if (_didInitialize || _initializing) return;

    if (!isConfigured) {
      if (!_loggedNotConfigured) {
        _loggedNotConfigured = true;
        final urlPresent = supabaseUrl.trim().isNotEmpty;
        final keyPresent = anonKey.trim().isNotEmpty;
        debugPrint(
          '[SupabaseConfig] Not configured. (Missing SUPABASE_URL=${urlPresent ? "present" : "missing"} / SUPABASE_ANON_KEY=${keyPresent ? "present" : "missing"}. Expected via dart-defines or web runtime env).',
        );
        SupabaseRuntimeEnv.debugDump();
      }
      return;
    }

    _initializing = true;
    try {
      _loggedNotConfigured = false;
      final url = supabaseUrl.trim();
      final trimmedKey = anonKey.trim();
      final maskedKey = trimmedKey.isEmpty ? '' : '${trimmedKey.substring(0, trimmedKey.length < 8 ? trimmedKey.length : 8)}…';
      debugPrint('[SupabaseConfig] Initializing Supabase: url=$url anonKey=$maskedKey');
      await Supabase.initialize(url: url, anonKey: trimmedKey, debug: kDebugMode);
      _didInitialize = true;
    } catch (e) {
      debugPrint('[SupabaseConfig] initialize failed: $e');
      rethrow;
    } finally {
      _initializing = false;
    }
  }

  /// Ensures Supabase is initialized. If credentials appear later (e.g. a user
  /// connects Supabase in Dreamflow while the preview is already running), this
  /// allows the app to recover without requiring a full page refresh.
  static Future<void> ensureInitialized() async {
    if (_didInitialize) return;
    await initialize();
  }

  static SupabaseClient get client => Supabase.instance.client;
  static GoTrueClient get auth => client.auth;
}

/// Generic database service for CRUD operations
class SupabaseService {
  static Future<void> _ensureReady() async {
    // Attempt lazy init first.
    await SupabaseConfig.ensureInitialized();
    if (!SupabaseConfig.isConfigured) {
      throw Exception('No backend connected.');
    }
    if (!SupabaseConfig.isInitialized) {
      throw Exception('Supabase not initialized yet.');
    }
  }

  /// Select multiple records from a table
  static Future<List<Map<String, dynamic>>> select(
    String table, {
    String? select,
    Map<String, dynamic>? filters,
    String? orderBy,
    bool ascending = true,
    int? limit,
  }) async {
    try {
      await _ensureReady();
      dynamic query = SupabaseConfig.client.from(table).select(select ?? '*');

      // Apply filters
      if (filters != null) {
        for (final entry in filters.entries) {
          query = query.eq(entry.key, entry.value);
        }
      }

      // Apply ordering
      if (orderBy != null) {
        query = query.order(orderBy, ascending: ascending);
      }

      // Apply limit
      if (limit != null) {
        query = query.limit(limit);
      }

      return await query;
    } catch (e) {
      throw _handleDatabaseError('select', table, e);
    }
  }

  /// Select a single record from a table
  static Future<Map<String, dynamic>?> selectSingle(
    String table, {
    String? select,
    required Map<String, dynamic> filters,
  }) async {
    try {
      await _ensureReady();
      dynamic query = SupabaseConfig.client.from(table).select(select ?? '*');

      for (final entry in filters.entries) {
        query = query.eq(entry.key, entry.value);
      }

      return await query.maybeSingle();
    } catch (e) {
      throw _handleDatabaseError('selectSingle', table, e);
    }
  }

  /// Insert a record into a table
  static Future<void> insert(
    String table,
    Map<String, dynamic> data,
  ) async {
    try {
      await _ensureReady();
      // Don't call `.select()` here.
      // Many secure/RLS setups allow anonymous INSERT but *not* SELECT.
      // PostgREST will error if we request the inserted row back.
      await SupabaseConfig.client.from(table).insert(data);
    } catch (e) {
      throw _handleDatabaseError('insert', table, e);
    }
  }

  /// Insert multiple records into a table
  static Future<void> insertMultiple(
    String table,
    List<Map<String, dynamic>> data,
  ) async {
    try {
      await _ensureReady();
      await SupabaseConfig.client.from(table).insert(data);
    } catch (e) {
      throw _handleDatabaseError('insertMultiple', table, e);
    }
  }

  /// Update records in a table
  static Future<List<Map<String, dynamic>>> update(
    String table,
    Map<String, dynamic> data, {
    required Map<String, dynamic> filters,
  }) async {
    try {
      await _ensureReady();
      dynamic query = SupabaseConfig.client.from(table).update(data);

      for (final entry in filters.entries) {
        query = query.eq(entry.key, entry.value);
      }

      return await query.select();
    } catch (e) {
      throw _handleDatabaseError('update', table, e);
    }
  }

  /// Delete records from a table
  static Future<void> delete(
    String table, {
    required Map<String, dynamic> filters,
  }) async {
    try {
      await _ensureReady();
      dynamic query = SupabaseConfig.client.from(table).delete();

      for (final entry in filters.entries) {
        query = query.eq(entry.key, entry.value);
      }

      await query;
    } catch (e) {
      throw _handleDatabaseError('delete', table, e);
    }
  }

  /// Get direct table reference for complex queries
  static SupabaseQueryBuilder from(String table) {
    // NOTE: this remains sync for advanced callers, but we still guard against
    // obvious misconfiguration.
    if (!SupabaseConfig.isConfigured || !SupabaseConfig.isInitialized) {
      throw Exception('Supabase not ready.');
    }
    return SupabaseConfig.client.from(table);
  }

  /// Handle database errors
  static Exception _handleDatabaseError(
    String operation,
    String table,
    dynamic error,
  ) {
    if (error is PostgrestException) {
      final code = error.code;
      final details = error.details;
      final hint = error.hint;
      final parts = <String>[
        'Failed to $operation on $table: ${error.message}',
        if (code != null && code.isNotEmpty) 'code=$code',
        if (details != null && details.toString().trim().isNotEmpty) 'details=$details',
        if (hint != null && hint.toString().trim().isNotEmpty) 'hint=$hint',
      ];
      return Exception(parts.join(' | '));
    } else {
      return Exception('Failed to $operation from $table: ${error.toString()}');
    }
  }
}
