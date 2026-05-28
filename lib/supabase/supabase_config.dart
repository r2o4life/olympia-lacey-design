import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  /// Prefer compile-time env vars for deployments:
  /// - SUPABASE_URL
  /// - SUPABASE_ANON_KEY
  ///
  /// In Dreamflow, connect Supabase via the Supabase panel (no CLI required).
  /// If env vars are missing, we run the app without a backend.
  static String get supabaseUrl => const String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static String get anonKey => const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  static bool get isConfigured => supabaseUrl.trim().isNotEmpty && anonKey.trim().isNotEmpty;

  static Future<void> initialize() async {
    if (!isConfigured) {
      debugPrint('[SupabaseConfig] Not configured. Connect Supabase via Dreamflow panel.');
      return;
    }
    await Supabase.initialize(url: supabaseUrl, anonKey: anonKey, debug: kDebugMode);
  }

  static SupabaseClient get client => Supabase.instance.client;
  static GoTrueClient get auth => client.auth;
}

/// Generic database service for CRUD operations
class SupabaseService {
  static void _ensureConfigured() {
    if (!SupabaseConfig.isConfigured) {
      throw Exception('No backend connected. Open the Supabase panel in Dreamflow and complete setup.');
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
      _ensureConfigured();
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
      _ensureConfigured();
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
      _ensureConfigured();
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
      _ensureConfigured();
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
      _ensureConfigured();
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
      _ensureConfigured();
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
    _ensureConfigured();
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
