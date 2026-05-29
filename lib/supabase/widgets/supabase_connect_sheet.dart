import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:parallel_paradigm_org/supabase/supabase_config.dart';
import 'package:parallel_paradigm_org/supabase/supabase_runtime_env.dart';
import 'package:parallel_paradigm_org/theme.dart';

/// Debug-only helper UI to provide Supabase URL/anon key at runtime.
///
/// Why: in some web preview environments, `--dart-define` values are not
/// available, even though Supabase is “connected” in the IDE.
class SupabaseConnectSheet extends StatefulWidget {
  const SupabaseConnectSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const SupabaseConnectSheet(),
      );

  @override
  State<SupabaseConnectSheet> createState() => _SupabaseConnectSheetState();
}

class _SupabaseConnectSheetState extends State<SupabaseConnectSheet> {
  final _url = TextEditingController(text: SupabaseConfig.supabaseUrl);
  final _anon = TextEditingController(text: SupabaseConfig.anonKey);
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _url.dispose();
    _anon.dispose();
    super.dispose();
  }

  bool _looksLikeUrl(String v) => v.startsWith('https://') && v.contains('.supabase.co');

  Future<void> _save() async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final url = _url.text.trim();
      final anon = _anon.text.trim();
      if (!_looksLikeUrl(url)) {
        setState(() => _error = 'Enter a valid Supabase URL (https://<ref>.supabase.co).');
        return;
      }
      if (anon.split('.').length < 2 || anon.length < 20) {
        setState(() => _error = 'Enter a valid anon key (JWT-like string).');
        return;
      }

      final ok1 = SupabaseRuntimeEnv.set('SUPABASE_URL', url);
      final ok2 = SupabaseRuntimeEnv.set('SUPABASE_ANON_KEY', anon);
      if (!ok1 || !ok2) {
        setState(() => _error = 'Could not persist values in browser storage.');
        return;
      }

      // Attempt init immediately so the outbox can flush.
      await SupabaseConfig.ensureInitialized();

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      debugPrint('[SupabaseConnectSheet] save failed: $e');
      setState(() => _error = 'Failed to initialize Supabase. Check console logs.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();

    final media = MediaQuery.of(context);
    final text = Theme.of(context).textTheme;
    final bottomPad = media.viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.lg + bottomPad),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: ParadigmColors.panel,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.cloud_done, color: Colors.white.withValues(alpha: 0.92), size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Supabase runtime config (debug)'.toUpperCase(),
                          style: ParadigmTypography.mono(context).copyWith(
                            fontSize: 11,
                            letterSpacing: 2.6,
                            color: ParadigmColors.textFaint,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: _saving ? null : () => Navigator.of(context).pop(),
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(Icons.close, color: Colors.white.withValues(alpha: 0.86), size: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'This is only needed when the preview can’t see your connected Supabase credentials. Values are stored in browser storage as SUPABASE_URL and SUPABASE_ANON_KEY.',
                    style: text.bodyMedium?.copyWith(height: 1.5, color: ParadigmColors.textPrimary.withValues(alpha: 0.86)),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _url,
                    enabled: !_saving,
                    style: text.bodyMedium?.copyWith(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Supabase URL',
                      hintText: 'https://<project-ref>.supabase.co',
                      errorText: _error,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _anon,
                    enabled: !_saving,
                    style: text.bodyMedium?.copyWith(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Anon key',
                      hintText: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
                    ),
                    maxLines: 3,
                    minLines: 1,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _saving ? null : () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text('Cancel', style: text.labelLarge?.copyWith(color: Colors.white.withValues(alpha: 0.9))),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: _saving ? null : _save,
                          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                          child: _saving
                              ? SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white.withValues(alpha: 0.92)),
                                )
                              : Text('Save & initialize', style: text.labelLarge?.copyWith(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
