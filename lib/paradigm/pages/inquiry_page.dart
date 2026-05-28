import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:parallel_paradigm_org/nav.dart';
import 'package:parallel_paradigm_org/paradigm/inquiry_service.dart';
import 'package:parallel_paradigm_org/paradigm/paradigm_shell.dart';
import 'package:parallel_paradigm_org/paradigm/paradigm_simulation.dart';
import 'package:parallel_paradigm_org/paradigm/widgets/pixel_motif.dart';
import 'package:parallel_paradigm_org/paradigm/widgets/paradigm_top_nav.dart';
import 'package:parallel_paradigm_org/theme.dart';

class InquiryPage extends StatefulWidget {
  const InquiryPage({super.key});

  @override
  State<InquiryPage> createState() => _InquiryPageState();
}

class _InquiryPageState extends State<InquiryPage> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _notes = TextEditingController();
  final Set<String> _focus = {'Growth'};
  bool _submitting = false;
  String? _emailError;

  @override
  void dispose() {
    _email.dispose();
    _notes.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);

  void _handleBack() {
    // Inquiry is often reached via `context.go()`, which does not create a back
    // stack entry. In that case, `pop()` is a no-op; we egress to the Vanguard.
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.vanguard);
    }
  }

  Future<void> _submit() async {
    if (_submitting) return;
    FocusManager.instance.primaryFocus?.unfocus();

    final email = InquiryService.normalizeEmail(_email.text);
    if (!_isValidEmail(email)) {
      setState(() => _emailError = email.isEmpty ? 'Email is required.' : 'Enter a valid email address.');
      return;
    }

    setState(() {
      _emailError = null;
      _submitting = true;
    });

    try {
      final lead = InquiryLead(
        email: email,
        focusAreas: _focus.toList()..sort(),
        notes: _notes.text.trim(),
      );
      await InquiryService.submit(lead);
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          duration: const Duration(seconds: 4),
          margin: const EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xl),
          content: _InquiryToast(
            tone: _InquiryToastTone.success,
            title: 'Submission received',
            message: 'We’ll reach out to $email.',
          ),
        ),
      );
      setState(() {
        _submitting = false;
        _notes.text = '';
      });
    } catch (e) {
      debugPrint('Failed to submit inquiry: $e');
      if (!mounted) return;

      final message = e.toString();
      final isNoBackend = message.contains('No backend connected') || message.contains('Supabase panel');
      final isMissingTable = message.contains("Could not find the table") ||
          message.contains("schema cache") ||
          message.contains("public.inquiry_leads");

      if (isNoBackend) {
        await showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const _SupabaseNotConnectedSheet(),
        );
      } else if (isMissingTable) {
        await showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const _SupabaseMissingTableSheet(),
        );
      } else {
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();
        messenger.showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            elevation: 0,
            duration: Duration(seconds: 4),
            margin: EdgeInsets.fromLTRB(AppSpacing.xl, 0, AppSpacing.xl, AppSpacing.xl),
            content: _InquiryToast(
              tone: _InquiryToastTone.error,
              title: 'Couldn’t submit',
              message: 'Please try again in a moment.',
            ),
          ),
        );
      }
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: ParadigmColors.bg,
      body: ParadigmShell(
        stage: ParadigmStage.inquiry,
        accessState: ParadigmAccessState.locked,
        child: EdgeSwipeBack(
          onBack: _handleBack,
          child: SafeArea(
            child: Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(
                      MediaQuery.sizeOf(context).width < 420 ? AppSpacing.lg : AppSpacing.xl,
                      124,
                      MediaQuery.sizeOf(context).width < 420 ? AppSpacing.lg : AppSpacing.xl,
                      80 + MediaQuery.viewInsetsOf(context).bottom,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 920),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Direct Inquiry'.toUpperCase(),
                              style: ParadigmTypography.mono(context).copyWith(
                                fontSize: 11,
                                letterSpacing: 2.8,
                                color: ParadigmColors.textFaint,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Tell us what outcome you want.\nWe’ll design the system that gets you there.',
                              style: text.displaySmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                height: 0.95,
                                letterSpacing: -1.5,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'We’re a technology studio for small and mid-size businesses. We improve growth, monetization, governance, security, and engagement — which compound into profitability and brand strength.',
                              style: text.bodyLarge?.copyWith(
                                height: 1.55,
                                color: ParadigmColors.textPrimary.withValues(alpha: 0.86),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: const [
                                ParadigmKeywordChip(keyword: 'Growth'),
                                ParadigmKeywordChip(keyword: 'Monetization'),
                                ParadigmKeywordChip(keyword: 'Governance'),
                                ParadigmKeywordChip(keyword: 'Security'),
                                ParadigmKeywordChip(keyword: 'Engagement'),
                              ],
                            ),
                            const SizedBox(height: 34),
                            _InquiryPanel(
                              email: _email,
                              notes: _notes,
                              focus: _focus,
                              emailError: _emailError,
                              submitting: _submitting,
                              onFocusChanged: (v) => setState(() {
                                if (_focus.contains(v)) {
                                  if (_focus.length > 1) _focus.remove(v);
                                } else {
                                  _focus.add(v);
                                }
                              }),
                              onSubmit: _submit,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                _InquiryHeader(onBack: _handleBack),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InquiryHeader extends StatelessWidget {
  const _InquiryHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      child: ParadigmTopNav(
        background: Colors.transparent,
        showBottomBorder: false,
        left: InkWell(
          onTap: () => context.go(AppRoutes.vanguard),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          child: const ParadigmBrandLockup(tagline: 'Inquiry • Olympia Lacey Design'),
        ),
        right: Wrap(
          spacing: 18,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            InkWell(
              onTap: onBack,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                child: Text(
                  '← Back'.toUpperCase(),
                  style: ParadigmTypography.mono(context).copyWith(
                    fontSize: 11,
                    letterSpacing: 3.2,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: () => context.go(AppRoutes.grid),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                child: Text(
                  'Index'.toUpperCase(),
                  style: ParadigmTypography.mono(context).copyWith(
                    fontSize: 11,
                    letterSpacing: 3.2,
                    color: ParadigmColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InquiryPanel extends StatelessWidget {
  const _InquiryPanel({
    required this.email,
    required this.notes,
    required this.focus,
    required this.onFocusChanged,
    required this.onSubmit,
    required this.submitting,
    required this.emailError,
  });

  final TextEditingController email;
  final TextEditingController notes;
  final Set<String> focus;
  final ValueChanged<String> onFocusChanged;
  final VoidCallback onSubmit;
  final bool submitting;
  final String? emailError;

  @override
  Widget build(BuildContext context) {
    final borderColor = emailError == null ? Colors.white.withValues(alpha: 0.14) : ParadigmColors.danger.withValues(alpha: 0.55);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.06),
              Colors.black.withValues(alpha: 0.55),
              Colors.black.withValues(alpha: 0.35),
            ],
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: _InquiryPanelMotif()),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What should we optimize?'.toUpperCase(),
                  style: ParadigmTypography.mono(context).copyWith(fontSize: 10, letterSpacing: 2.6, color: ParadigmColors.textFaint),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: const ['Growth', 'Monetization', 'Governance', 'Security', 'Engagement']
                      .map(
                        (k) => _FocusChip(
                          keyword: k,
                          selected: focus.contains(k),
                          onTap: () => onFocusChanged(k),
                        ),
                      )
                      .toList(growable: false),
                ),
                const SizedBox(height: 22),
                _EmailField(controller: email, borderColor: borderColor, errorText: emailError, onSubmit: onSubmit),
                const SizedBox(height: 14),
                TextField(
                  controller: notes,
                  maxLines: 4,
                  style: ParadigmTypography.mono(context).copyWith(fontSize: 11, letterSpacing: 1.8, color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'OPTIONAL: CONTEXT, CONSTRAINTS, TARGET KPI',
                    hintStyle: ParadigmTypography.mono(context).copyWith(fontSize: 10.5, letterSpacing: 2.1, color: ParadigmColors.textFaint),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.22)),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _SubmitButton(submitting: submitting, onTap: onSubmit),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'SUBMISSIONS ARE STORED SECURELY. WE ONLY USE YOUR EMAIL FOR FOLLOW-UP.',
                  style: ParadigmTypography.mono(context).copyWith(fontSize: 9.5, letterSpacing: 2.2, color: ParadigmColors.textFaint),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InquiryPanelMotif extends StatelessWidget {
  const _InquiryPanelMotif();

  @override
  Widget build(BuildContext context) {
    final accents = const [
      ParadigmColors.accentCyan,
      ParadigmColors.accentViolet,
      ParadigmColors.accentAmber,
      ParadigmColors.accentRose,
    ];

    return IgnorePointer(
      child: Opacity(
        opacity: 0.22,
        child: LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            final h = c.maxHeight;
            final count = (w * h / 52000).clamp(6, 18).round();
            return Stack(
              children: List.generate(count, (i) {
                final t = i / (count == 0 ? 1 : count);
                final dx = (math.sin(t * math.pi * 6.0) * 0.5 + 0.5) * (w - 42);
                final dy = (math.cos(t * math.pi * 5.0 + 0.8) * 0.5 + 0.5) * (h - 42);
                final color = accents[i % accents.length].withValues(alpha: 0.55);
                return Positioned(
                  left: dx,
                  top: dy,
                  child: Transform.rotate(
                    angle: (i % 7) * 0.22,
                    child: ParadigmPixelMotif(keyword: 'i$i', size: 18 + (i % 3) * 6, color: color),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}

class _FocusChip extends StatelessWidget {
  const _FocusChip({required this.keyword, required this.selected, required this.onTap});
  final String keyword;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = ParadigmKeywordPalette.colorFor(keyword);
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: Colors.white.withValues(alpha: selected ? 0.22 : 0.12)),
          color: selected ? color.withValues(alpha: 0.14) : Colors.white.withValues(alpha: 0.04),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ParadigmPixelMotif(keyword: keyword, size: 18, color: color),
            const SizedBox(width: 10),
            Text(
              keyword.toUpperCase(),
              style: ParadigmTypography.mono(context).copyWith(
                fontSize: 10,
                letterSpacing: 2.0,
                color: selected ? Colors.white : ParadigmColors.textMuted,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmailField extends StatelessWidget {
  const _EmailField({required this.controller, required this.borderColor, required this.errorText, required this.onSubmit});

  final TextEditingController controller;
  final Color borderColor;
  final String? errorText;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.send,
          style: ParadigmTypography.mono(context).copyWith(fontSize: 11, letterSpacing: 2.0, color: Colors.white),
          decoration: InputDecoration(
            hintText: 'EMAIL',
            hintStyle: ParadigmTypography.mono(context).copyWith(fontSize: 10.5, letterSpacing: 2.2, color: ParadigmColors.textFaint),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: borderColor.withValues(alpha: 0.95)),
            ),
          ),
          onSubmitted: (_) => onSubmit(),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 10),
          Text(
            errorText!.toUpperCase(),
            style: ParadigmTypography.mono(context).copyWith(fontSize: 9.5, letterSpacing: 2.2, color: ParadigmColors.danger),
          ),
        ],
      ],
    );
  }
}

class _SubmitButton extends StatefulWidget {
  const _SubmitButton({required this.submitting, required this.onTap});
  final bool submitting;
  final VoidCallback onTap;

  @override
  State<_SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<_SubmitButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final border = BorderSide(color: Colors.white.withValues(alpha: _hover ? 0.22 : 0.14));
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.fromBorderSide(border),
          color: _hover ? Colors.white : Colors.transparent,
        ),
        child: InkWell(
          onTap: widget.submitting ? null : widget.onTap,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.submitting) ...[
                  const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: ParadigmColors.success)),
                  const SizedBox(width: 12),
                ],
                Text(
                  (widget.submitting ? 'Submitting…' : 'Submit Inquiry').toUpperCase(),
                  style: ParadigmTypography.mono(context).copyWith(
                    fontSize: 11,
                    letterSpacing: 2.6,
                    color: _hover ? Colors.black : Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SupabaseMissingTableSheet extends StatelessWidget {
  const _SupabaseMissingTableSheet();

  static const String _sql = '''
-- Creates the table used by the app’s inquiry form.
-- Run this in Supabase SQL Editor.

create extension if not exists pgcrypto;

create table if not exists public.inquiry_leads (
  id uuid primary key default gen_random_uuid(),
  email text not null,
  focus_areas text[] not null default '{}'::text[],
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.inquiry_leads enable row level security;

do \$\$ begin
  create policy "Allow anon insert inquiry leads" on public.inquiry_leads
  for insert to anon
  with check (true);
exception when duplicate_object then null;
end \$\$;

create or replace function public.set_updated_at()
returns trigger language plpgsql as \$\$
begin
  new.updated_at = now();
  return new;
end \$\$;

drop trigger if exists set_updated_at on public.inquiry_leads;
create trigger set_updated_at
before update on public.inquiry_leads
for each row execute function public.set_updated_at();
''';

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.xl),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Container(
            decoration: BoxDecoration(
              color: ParadigmColors.panel,
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Backend setup required'.toUpperCase(),
                    style: ParadigmTypography.mono(context).copyWith(
                      fontSize: 11,
                      letterSpacing: 2.4,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Supabase is connected, but the app’s lead-capture table (`public.inquiry_leads`) is missing. Create it once and allow anonymous inserts; then “Submit Inquiry” will work immediately.',
                    style: text.bodyMedium?.copyWith(height: 1.5, color: ParadigmColors.textPrimary.withValues(alpha: 0.90)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'SQL to run (once)'.toUpperCase(),
                    style: ParadigmTypography.mono(context).copyWith(fontSize: 10, letterSpacing: 2.4, color: ParadigmColors.textFaint),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxHeight: 320),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                    ),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        _sql.trim(),
                        style: ParadigmTypography.mono(context).copyWith(fontSize: 11, height: 1.45, letterSpacing: 1.2, color: Colors.white.withValues(alpha: 0.92)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _SheetButton(label: 'Close', onTap: () => context.pop(), isPrimary: true),
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

class _SupabaseNotConnectedSheet extends StatelessWidget {
  const _SupabaseNotConnectedSheet();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, AppSpacing.xl),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Container(
            decoration: BoxDecoration(
              color: ParadigmColors.panel,
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No backend connected'.toUpperCase(),
                    style: ParadigmTypography.mono(context).copyWith(
                      fontSize: 11,
                      letterSpacing: 2.4,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'To enable form submissions, connect Supabase inside Dreamflow (left sidebar → Supabase panel) and complete the setup steps. Once connected, this page will submit leads directly to your Supabase database.',
                    style: text.bodyMedium?.copyWith(height: 1.5, color: ParadigmColors.textPrimary.withValues(alpha: 0.90)),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _SheetButton(label: 'Close', onTap: () => context.pop(), isPrimary: true),
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

enum _InquiryToastTone { success, error }

class _InquiryToast extends StatelessWidget {
  const _InquiryToast({required this.tone, required this.title, required this.message});

  final _InquiryToastTone tone;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final icon = tone == _InquiryToastTone.success ? Icons.check_circle_rounded : Icons.error_rounded;
    final accent = tone == _InquiryToastTone.success ? ParadigmColors.success : ParadigmColors.danger;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.78),
          border: Border.all(color: accent.withValues(alpha: 0.45)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: accent, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: ParadigmTypography.mono(context).copyWith(
                      fontSize: 10.5,
                      letterSpacing: 2.2,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      height: 1.35,
                      color: ParadigmColors.textPrimary.withValues(alpha: 0.92),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetButton extends StatefulWidget {
  const _SheetButton({required this.label, required this.onTap, required this.isPrimary});
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  State<_SheetButton> createState() => _SheetButtonState();
}

class _SheetButtonState extends State<_SheetButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final bg = _hover ? Colors.white : Colors.white.withValues(alpha: 0.92);
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: InkWell(
        onTap: widget.onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Text(
            widget.label.toUpperCase(),
            style: ParadigmTypography.mono(context).copyWith(
              fontSize: 11,
              letterSpacing: 2.4,
              color: Colors.black,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
