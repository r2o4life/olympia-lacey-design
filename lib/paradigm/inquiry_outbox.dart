import 'package:flutter/foundation.dart';
/// Deprecated: local inquiry queuing has been removed.
///
/// This file intentionally remains (no-op) to prevent stale imports in old
/// branches/checkpoints from breaking analysis.
class InquiryOutbox {
  static Future<void> enqueue(Map<String, dynamic> leadJson) async => debugPrint('[InquiryOutbox] ignored enqueue (deprecated).');
  static Future<List<Map<String, dynamic>>> peekAll() async => const [];
  static Future<void> replaceAll(List<Map<String, dynamic>> items) async => debugPrint('[InquiryOutbox] ignored replaceAll (deprecated).');
}
