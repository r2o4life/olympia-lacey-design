import 'package:flutter/foundation.dart';

import 'package:parallel_paradigm_org/supabase/supabase_config.dart';

/// Inquiry lead capture.
///
/// Uses Supabase when available; falls back to debug logging if initialization
/// fails (so the UX still works in preview/dev).
class InquiryLead {
  const InquiryLead({
    required this.email,
    required this.focusAreas,
    required this.surface,
    required this.modules,
    required this.notes,
  });

  final String email;
  final List<String> focusAreas;
  /// Mutually exclusive “primary build surface”.
  final String surface;
  /// Multi-select modules/presets.
  final List<String> modules;
  final String notes;

  Map<String, dynamic> toJson() => {
    'email': email,
    // Matches the deployed Supabase schema.
    'focus_areas': focusAreas,
    // These fields may not exist in older deployments; see submit() fallback.
    'surface': surface,
    'modules': modules,
    'notes': notes,
  };
}

class InquiryService {
  static DateTime? _lastSubmission;
  static const Duration _cooldown = Duration(seconds: 2);

  static String normalizeEmail(String email) => email.trim().toLowerCase();

  static Future<InquirySubmitResult> submit(InquiryLead lead) async {
    final now = DateTime.now();
    final last = _lastSubmission;
    if (last != null && now.difference(last) < _cooldown) {
      throw Exception('Please wait a moment and try again.');
    }

    try {
      debugPrint(
        '[InquiryService] submit() start email=${normalizeEmail(lead.email)} '
        'surface=${lead.surface} modules=${lead.modules.join(",")} '
        'focus=${lead.focusAreas.join(",")} notesLen=${lead.notes.length}',
      );
      _lastSubmission = now;

      // Hard requirement: only submit when Supabase is truly available.
      // No local queue / silent fallback in production.
      if (!SupabaseConfig.isConfigured) {
        throw Exception('Supabase not configured.');
      }
      await SupabaseConfig.ensureInitialized();
      if (!SupabaseConfig.isInitialized) {
        throw Exception('Supabase not initialized.');
      }

      final normalizedEmail = normalizeEmail(lead.email);

      // Backward compatible payload strategy:
      // 1) Try inserting structured fields (surface/modules) if the table supports them.
      // 2) If the DB schema is older (missing columns), fall back to inserting only
      //    the original columns and embed the structured info into notes.
      final structuredData = <String, dynamic>{
        'email': normalizedEmail,
        'focus_areas': lead.focusAreas,
        'surface': lead.surface,
        'modules': lead.modules,
        'notes': lead.notes,
      };

      try {
        await SupabaseService.insert('inquiry_leads', structuredData);
      } catch (e) {
        final raw = e.toString().toLowerCase();
        // PostgREST can report missing columns in multiple ways:
        // - Postgres: "column ... does not exist"
        // - PostgREST schema cache: "Could not find the 'modules' column ... in the schema cache" (PGRST204)
        final looksLikeMissingColumn =
            (raw.contains('does not exist') && raw.contains('column')) ||
            (raw.contains('could not find') && raw.contains('column') && raw.contains('schema cache')) ||
            raw.contains('pgrst204');
        if (!looksLikeMissingColumn) rethrow;

        debugPrint('[InquiryService] inquiry_leads schema missing columns; retrying with legacy payload. err=$e');
        final enrichedNotes = [
          if (lead.surface.trim().isNotEmpty) 'surface=${lead.surface}',
          if (lead.modules.isNotEmpty) 'modules=${lead.modules.join(",")}',
          if (lead.notes.trim().isNotEmpty) lead.notes.trim(),
        ].join(' | ');

        await SupabaseService.insert('inquiry_leads', {
          'email': normalizedEmail,
          'focus_areas': lead.focusAreas,
          'notes': enrichedNotes,
        });
      }
      debugPrint('[InquiryService] submit() success');
      return InquirySubmitResult.insertedRemote;
    } catch (e) {
      debugPrint('[InquiryService] submit failed: $e');

      // Allow a quick retry if the insert failed.
      _lastSubmission = null;
      rethrow;
    }
  }

  static Future<void> submitTelemetryGateLead({
    required String email,
    required String projectId,
    required String projectTitle,
    required String lens,
  }) {
    final normalized = normalizeEmail(email);
    final notes = [
      'source=telemetry_gate',
      'project_id=$projectId',
      'project_title=${projectTitle.replaceAll('\n', ' ').trim()}',
      'lens=$lens',
    ].join(' | ');

    return submit(
      InquiryLead(
        email: normalized,
        focusAreas: const ['CaseStudy'],
        surface: 'Case Study',
        modules: const ['Explore Sandbox'],
        notes: notes,
      ),
    );
  }
}

enum InquirySubmitResult {
  /// Insert reached Supabase successfully.
  insertedRemote,
}
