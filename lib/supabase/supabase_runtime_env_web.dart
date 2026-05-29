// Web-only runtime env reader.
//
// Uses browser localStorage and window globals as sources.
// The Supabase anon key is public and safe to expose on web.

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'dart:convert';

import 'package:flutter/foundation.dart';

abstract class SupabaseRuntimeEnvImpl {
  static String? get(String key) {
    // 0) query params (useful for debugging / temporary overrides)
    final qp = Uri.base.queryParameters[key] ?? Uri.base.queryParameters[key.toLowerCase()];
    if (qp != null && qp.trim().isNotEmpty) return qp;

    // 0b) hash params (some hosts inject config via location.hash)
    final hashParams = _hashQueryParameters();
    final hp = hashParams[key] ?? hashParams[key.toLowerCase()];
    if (hp != null && hp.trim().isNotEmpty) return hp;

    // 1) localStorage (most likely for preview hosts)
    final fromStorage = html.window.localStorage[key];
    if (fromStorage != null && fromStorage.trim().isNotEmpty) return fromStorage;

    // 1b) sessionStorage (some previews avoid persistence)
    final fromSession = html.window.sessionStorage[key];
    if (fromSession != null && fromSession.trim().isNotEmpty) return fromSession;

    // 2) window global (if host injects a JS object)
    final dynamic w = html.window;
    try {
      final dynamic value = (w as dynamic)[key];
      if (value is String && value.trim().isNotEmpty) return value;
    } catch (_) {
      // Ignore; accessing arbitrary window keys can throw in some environments.
    }

    // 2b) common global objects (e.g. __ENV__, env, DREAMFLOW, etc.)
    final fromGlobals = _tryReadFromKnownGlobalObjects(key);
    if (fromGlobals != null && fromGlobals.trim().isNotEmpty) return fromGlobals;

    // 3) Heuristic scan (Dreamflow/preview hosts may store config under unknown keys)
    final heur = _heuristicScan(key);
    if (heur != null && heur.trim().isNotEmpty) {
      try {
        html.window.localStorage[key] = heur;
      } catch (_) {}
      return heur;
    }
    return null;
  }

  static bool set(String key, String value) {
    final v = value.trim();
    if (v.isEmpty) return false;
    try {
      html.window.localStorage[key] = v;
      return true;
    } catch (_) {
      try {
        html.window.sessionStorage[key] = v;
        return true;
      } catch (_) {
        return false;
      }
    }
  }

  static void debugDump() {
    if (!kDebugMode) return;
    try {
      final keys = html.window.localStorage.keys.toList()..sort();
      final interesting = keys.where((k) {
        final lk = k.toLowerCase();
        return lk.contains('supabase') || lk.contains('anon') || lk.contains('jwt') || lk.contains('project');
      }).take(80).toList();
      debugPrint('[SupabaseRuntimeEnv] localStorage keys (filtered, up to 80): ${interesting.join(', ')}');

      final sessionKeys = html.window.sessionStorage.keys.toList()..sort();
      final sessionInteresting = sessionKeys.where((k) {
        final lk = k.toLowerCase();
        return lk.contains('supabase') || lk.contains('anon') || lk.contains('jwt') || lk.contains('project');
      }).take(80).toList();
      if (sessionInteresting.isNotEmpty) {
        debugPrint('[SupabaseRuntimeEnv] sessionStorage keys (filtered, up to 80): ${sessionInteresting.join(', ')}');
      }

      final hashParams = _hashQueryParameters();
      final hashInteresting = hashParams.keys.where((k) {
        final lk = k.toLowerCase();
        return lk.contains('supabase') || lk.contains('anon') || lk.contains('project');
      }).take(40).toList();
      if (hashInteresting.isNotEmpty) {
        debugPrint('[SupabaseRuntimeEnv] hash params keys (filtered): ${hashInteresting.join(', ')}');
      }

      final url = _heuristicFindUrl();
      final key = _heuristicFindAnonKey();
      debugPrint('[SupabaseRuntimeEnv] heuristic url: ${url ?? '(none)'}');
      debugPrint('[SupabaseRuntimeEnv] heuristic anon key: ${key == null ? '(none)' : '${key.substring(0, key.length < 8 ? key.length : 8)}…'}');

      final globalsUrl = _tryReadFromKnownGlobalObjects('SUPABASE_URL');
      final globalsKey = _tryReadFromKnownGlobalObjects('SUPABASE_ANON_KEY');
      if (globalsUrl != null) debugPrint('[SupabaseRuntimeEnv] globals url: $globalsUrl');
      if (globalsKey != null) {
        debugPrint('[SupabaseRuntimeEnv] globals anon key: ${globalsKey.substring(0, globalsKey.length < 8 ? globalsKey.length : 8)}…');
      }
    } catch (e) {
      debugPrint('[SupabaseRuntimeEnv] debugDump error: $e');
    }
  }

  static Map<String, String> _hashQueryParameters() {
    try {
      final hash = html.window.location.hash; // includes leading '#'
      if (hash.isEmpty) return const {};
      final withoutHash = hash.startsWith('#') ? hash.substring(1) : hash;
      final idx = withoutHash.indexOf('?');
      final query = idx >= 0 ? withoutHash.substring(idx + 1) : withoutHash;
      if (query.trim().isEmpty) return const {};
      return Uri.splitQueryString(query);
    } catch (_) {
      return const {};
    }
  }

  static String? _tryReadFromKnownGlobalObjects(String requestedKey) {
    // Some hosts inject config under an object rather than as top-level window keys.
    // We try a small set of common patterns.
    const objects = <String>[
      '__ENV__',
      'ENV',
      'env',
      '__DREAMFLOW__',
      'DREAMFLOW',
      'dreamflow',
      '__CONFIG__',
      'CONFIG',
      'config',
      '__APP_CONFIG__',
      'APP_CONFIG',
    ];

    final variants = <String>{
      requestedKey,
      requestedKey.toLowerCase(),
      requestedKey.toUpperCase(),
    }.toList();

    final dynamic w = html.window;
    for (final objName in objects) {
      dynamic obj;
      try {
        obj = (w as dynamic)[objName];
      } catch (_) {
        continue;
      }
      if (obj == null) continue;
      for (final k in variants) {
        try {
          final dynamic v = (obj as dynamic)[k];
          if (v is String && v.trim().isNotEmpty) return v.trim();
        } catch (_) {
          // ignore
        }
      }
    }

    // process.env (some bundlers emulate this)
    try {
      final dynamic process = (w as dynamic)['process'];
      final dynamic env = process == null ? null : (process as dynamic)['env'];
      if (env != null) {
        for (final k in variants) {
          try {
            final dynamic v = (env as dynamic)[k];
            if (v is String && v.trim().isNotEmpty) return v.trim();
          } catch (_) {}
        }
      }
    } catch (_) {}

    return null;
  }

  static String? _heuristicScan(String requestedKey) {
    final k = requestedKey.toUpperCase();
    if (k.contains('URL')) return _heuristicFindUrl();
    if (k.contains('ANON') || k.contains('KEY')) return _heuristicFindAnonKey();
    return null;
  }

  static String? _heuristicFindUrl() {
    // If the host only provides the anon key (common in some preview setups), we
    // can derive the project ref from the JWT payload and construct the URL.
    final derived = _deriveUrlFromAnonJwt();
    if (derived != null) return derived;

    final urlRegex = RegExp(r'^https://[a-zA-Z0-9-]+\.supabase\.co/?$');

    // Check all localStorage values.
    for (final key in html.window.localStorage.keys) {
      final v = html.window.localStorage[key];
      if (v == null) continue;
      final t = v.trim();
      if (t.isEmpty) continue;
      if (urlRegex.hasMatch(t)) return t.endsWith('/') ? t.substring(0, t.length - 1) : t;
      if (t.startsWith('https://') && t.contains('.supabase.co')) return t;

      // JSON blob that contains a Supabase URL.
      final fromJson = _extractSupabaseUrlFromJsonBlob(t);
      if (fromJson != null) return fromJson;
    }

    // Check sessionStorage values.
    for (final key in html.window.sessionStorage.keys) {
      final v = html.window.sessionStorage[key];
      if (v == null) continue;
      final t = v.trim();
      if (t.isEmpty) continue;
      if (urlRegex.hasMatch(t)) return t.endsWith('/') ? t.substring(0, t.length - 1) : t;
      if (t.startsWith('https://') && t.contains('.supabase.co')) return t;

      final fromJson = _extractSupabaseUrlFromJsonBlob(t);
      if (fromJson != null) return fromJson;
    }

    // Also check window globals for common patterns.
    final dynamic w = html.window;
    const commonKeys = [
      'SUPABASE_URL',
      'supabaseUrl',
      'supabase_url',
      'DREAMFLOW_SUPABASE_URL',
    ];
    for (final k in commonKeys) {
      try {
        final dynamic value = (w as dynamic)[k];
        if (value is String && value.trim().isNotEmpty && value.contains('.supabase.co')) return value.trim();
      } catch (_) {}
    }

    // Finally, try known global objects.
    final fromGlobals = _tryReadFromKnownGlobalObjects('SUPABASE_URL');
    if (fromGlobals != null && fromGlobals.contains('.supabase.co')) return fromGlobals;
    return null;
  }

  static String? _deriveUrlFromAnonJwt() {
    try {
      final anon = _heuristicFindAnonKey();
      if (anon == null || anon.trim().isEmpty) return null;
      final ref = _extractSupabaseRefFromJwt(anon.trim());
      if (ref == null || ref.trim().isEmpty) return null;
      return 'https://$ref.supabase.co';
    } catch (_) {
      return null;
    }
  }

  static String? _extractSupabaseRefFromJwt(String jwt) {
    final parts = jwt.split('.');
    if (parts.length < 2) return null;
    final payload = parts[1];
    final decoded = _decodeBase64UrlToString(payload);
    if (decoded == null) return null;
    final obj = jsonDecode(decoded);
    if (obj is! Map<String, dynamic>) return null;
    final ref = obj['ref'];
    return ref is String ? ref : null;
  }

  static String? _decodeBase64UrlToString(String input) {
    try {
      var normalized = input.replaceAll('-', '+').replaceAll('_', '/');
      while (normalized.length % 4 != 0) {
        normalized += '=';
      }
      final bytes = base64Decode(normalized);
      return utf8.decode(bytes);
    } catch (_) {
      return null;
    }
  }

  static String? _heuristicFindAnonKey() {
    // A Supabase anon key is a JWT. Many unrelated strings can look like a JWT
    // (e.g. version numbers like "2.102.0"), so we validate the payload.
    final jwtRegex = RegExp(r'^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$');

    bool isValidSupabaseAnonJwt(String candidate) {
      final t = candidate.trim();
      // Real anon keys are long; this also filters out "2.102.0" style values.
      if (t.length < 40) return false;
      if (!jwtRegex.hasMatch(t)) return false;
      try {
        final ref = _extractSupabaseRefFromJwt(t);
        if (ref == null || ref.trim().isEmpty) return false;
        // Supabase project refs are lowercase alphanumeric.
        final refOk = RegExp(r'^[a-z0-9]+$').hasMatch(ref);
        return refOk;
      } catch (_) {
        return false;
      }
    }

    for (final key in html.window.localStorage.keys) {
      final v = html.window.localStorage[key];
      if (v == null) continue;
      final t = v.trim();
      if (t.isEmpty) continue;
      if (isValidSupabaseAnonJwt(t)) return t;

      final fromJson = _extractJwtFromJsonBlob(t);
      if (fromJson != null && isValidSupabaseAnonJwt(fromJson)) return fromJson;
    }

    for (final key in html.window.sessionStorage.keys) {
      final v = html.window.sessionStorage[key];
      if (v == null) continue;
      final t = v.trim();
      if (t.isEmpty) continue;
      if (isValidSupabaseAnonJwt(t)) return t;
      final fromJson = _extractJwtFromJsonBlob(t);
      if (fromJson != null && isValidSupabaseAnonJwt(fromJson)) return fromJson;
    }

    final dynamic w = html.window;
    const commonKeys = [
      'SUPABASE_ANON_KEY',
      'supabaseAnonKey',
      'supabase_anon_key',
      'DREAMFLOW_SUPABASE_ANON_KEY',
    ];
    for (final k in commonKeys) {
      try {
        final dynamic value = (w as dynamic)[k];
        if (value is String && isValidSupabaseAnonJwt(value)) return value.trim();
      } catch (_) {}
    }

    final fromGlobals = _tryReadFromKnownGlobalObjects('SUPABASE_ANON_KEY');
    if (fromGlobals != null && isValidSupabaseAnonJwt(fromGlobals)) return fromGlobals;
    return null;
  }

  static String? _extractSupabaseUrlFromJsonBlob(String value) {
    final t = value.trim();
    if (!(t.startsWith('{') || t.startsWith('['))) return null;

    // Avoid dart:convert dependency here; keep it very lightweight and resilient.
    // Regex-search for a URL shaped like a Supabase project.
    final match = RegExp(r'https://[a-zA-Z0-9-]+\.supabase\.co').firstMatch(t);
    if (match == null) return null;
    return match.group(0);
  }

  static String? _extractJwtFromJsonBlob(String value) {
    final t = value.trim();
    if (!(t.startsWith('{') || t.startsWith('['))) return null;
    final jwtRegex = RegExp(r'[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+');
    final match = jwtRegex.firstMatch(t);
    return match?.group(0);
  }
}
