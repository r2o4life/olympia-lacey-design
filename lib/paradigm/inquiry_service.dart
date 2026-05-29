import 'package:flutter/foundation.dart';

import 'package:parallel_paradigm_org/supabase/supabase_config.dart';

/// Inquiry lead capture.
///
/// Uses Supabase when available; falls back to debug logging if initialization
/// fails (so the UX still works in preview/dev).
class InquiryLead {
  const InquiryLead({required this.email, required this.focusAreas, required this.notes});

  final String email;
  final List<String> focusAreas;
  final String notes;

  Map<String, dynamic> toJson() => {
    'email': email,
    // Matches the deployed Supabase schema.
    'focus_areas': focusAreas,
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
      debugPrint('[InquiryService] submit() start email=${normalizeEmail(lead.email)} focus=${lead.focusAreas.join(",")} notesLen=${lead.notes.length}');
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

      await SupabaseService.insert('inquiry_leads', {
        'email': normalizeEmail(lead.email),
        'focus_areas': lead.focusAreas,
        'notes': lead.notes,
      });
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
        notes: notes,
      ),
    );
  }
}

enum InquirySubmitResult {
  /// Insert reached Supabase successfully.
  insertedRemote,
}
