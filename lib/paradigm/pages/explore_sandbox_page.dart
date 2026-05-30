import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:parallel_paradigm_org/nav.dart';
import 'package:parallel_paradigm_org/paradigm/paradigm_data.dart';
import 'package:parallel_paradigm_org/paradigm/paradigm_shell.dart';
import 'package:parallel_paradigm_org/paradigm/paradigm_simulation.dart';
import 'package:parallel_paradigm_org/paradigm/widgets/ontology_backdrop.dart';
import 'package:parallel_paradigm_org/paradigm/widgets/pixel_motif.dart';
import 'package:parallel_paradigm_org/theme.dart';

class ExploreSandboxPage extends StatefulWidget {
  const ExploreSandboxPage({super.key, required this.projectId, this.initialObjective, this.initialPhase});

  final String projectId;
  final String? initialObjective;
  final String? initialPhase;

  @override
  State<ExploreSandboxPage> createState() => _ExploreSandboxPageState();
}

class _ExploreSandboxPageState extends State<ExploreSandboxPage> {
  late final ParadigmProject? _project;
  late String _objective;
  String? _phase;
  late final PageController _controller;
  int _pageIndex = 0;

  Future<void> _showObjectiveSheet({required ParadigmProject project, required Color accent}) async {
    final next = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ObjectiveBottomSheet(project: project, selected: _objective, accent: accent),
    );
    if (!mounted) return;
    if (next == null || next == _objective) return;
    setState(() {
      _objective = next;
      _pageIndex = 0;
    });
    _controller.jumpToPage(0);
  }

  @override
  void initState() {
    super.initState();
    _project = ParadigmProjects.projects[widget.projectId];
    final nodes = _project?.cinematic.nodes ?? const <String, List<String>>{};
    final desiredObjective = widget.initialObjective;
    _objective = (desiredObjective != null && nodes.containsKey(desiredObjective))
        ? desiredObjective
        : (nodes.keys.isNotEmpty ? nodes.keys.first : '');
    final desiredPhase = widget.initialPhase;
    _phase = (desiredPhase != null && desiredPhase.trim().isNotEmpty) ? desiredPhase : null;
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewport = ParadigmViewport.of(context);
    final project = _project;
    if (project == null) {
      return Scaffold(
        backgroundColor: ParadigmColors.bg,
        body: SafeArea(
          child: Center(
            child: Text(
              'Sandbox not available.'.toUpperCase(),
              style: ParadigmTypography.mono(context).copyWith(color: ParadigmColors.textMuted, letterSpacing: 2.6),
            ),
          ),
        ),
      );
    }

    final accent = ParadigmKeywordPalette.colorFor(project.title);
    final objectiveSteps = project.cinematic.nodes[_objective] ?? const <String>[];
    final sdlc = objectiveSteps.map(_SdlcStep.parse).toList(growable: false);
    final beats = List.generate(sdlc.length, (i) => _StoryBeat.from(projectId: project.id, objective: _objective, step: sdlc[i], index: i));

    // Align to requested phase if provided.
    final phase = _phase;
    if (phase != null) {
      final idx = beats.indexWhere((b) => b.phase.toLowerCase() == phase.toLowerCase());
      if (idx >= 0 && _pageIndex != idx) {
        // Defer jump until after first frame.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _controller.jumpToPage(idx);
          setState(() => _pageIndex = idx);
        });
        _phase = null;
      }
    }

    return Scaffold(
      backgroundColor: ParadigmColors.bg,
      body: ParadigmShell(
        stage: ParadigmStage.explore,
        accessState: ParadigmAccessState.granted,
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    MediaQuery.sizeOf(context).width < 540 ? AppSpacing.lg * viewport.scale : AppSpacing.xl,
                    // The header is fixed-position. On short phones, reduce the
                    // reserved top padding so content doesn't get squeezed.
                    viewport.isCompactHeight ? 92 : 104,
                    MediaQuery.sizeOf(context).width < 540 ? AppSpacing.lg * viewport.scale : AppSpacing.xl,
                    viewport.isCompactHeight ? 16 : 24,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 980;
                      final phone = constraints.maxWidth < 740;

                      if (phone) {
                        return _StoryViewport(
                          accent: accent,
                          projectId: project.id,
                          objective: _objective,
                          beats: beats,
                          controller: _controller,
                          pageIndex: _pageIndex,
                          onChanged: (i) => setState(() => _pageIndex = i),
                          onOpenObjectives: () => _showObjectiveSheet(project: project, accent: accent),
                        );
                      }

                      final leftWidth = wide ? 320.0 : constraints.maxWidth;
                      final rightWidth = wide ? (constraints.maxWidth - leftWidth - 16) : constraints.maxWidth;

                      final left = SizedBox(
                        width: leftWidth,
                        child: _ObjectiveRail(
                          project: project,
                          objective: _objective,
                          accent: accent,
                          onSelect: (next) {
                            if (next == _objective) return;
                            setState(() {
                              _objective = next;
                              _pageIndex = 0;
                            });
                            _controller.jumpToPage(0);
                          },
                        ),
                      );

                      final right = SizedBox(
                        width: rightWidth,
                        child: _StoryViewport(
                          accent: accent,
                          projectId: project.id,
                          objective: _objective,
                          beats: beats,
                          controller: _controller,
                          pageIndex: _pageIndex,
                          onChanged: (i) => setState(() => _pageIndex = i),
                        ),
                      );

                      if (wide) return Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [left, const SizedBox(width: 16), Expanded(child: right)]);
                      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [left, const SizedBox(height: 16), Expanded(child: right)]);
                    },
                  ),
                ),
              ),
              _ExploreHeader(
                accent: accent,
                projectTitle: project.title,
                onBack: () => context.pop(),
                onInquiry: () => context.go(AppRoutes.inquiry),
                onIndex: () => context.go(AppRoutes.grid),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExploreHeader extends StatelessWidget {
  const _ExploreHeader({required this.accent, required this.projectTitle, required this.onBack, required this.onInquiry, required this.onIndex});

  final Color accent;
  final String projectTitle;
  final VoidCallback onBack;
  final VoidCallback onInquiry;
  final VoidCallback onIndex;

  @override
  Widget build(BuildContext context) {
    final viewport = ParadigmViewport.of(context);
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      child: Container(
        padding: viewport.insetAll(viewport.isCompactHeight ? AppSpacing.lg : AppSpacing.xl),
        decoration: BoxDecoration(
          color: ParadigmColors.panel,
          border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
        ),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _HeaderChip(label: 'Back', icon: Icons.arrow_back_rounded, accent: accent, onTap: onBack),
                Text(
                  '$projectTitle — Sandbox'.toUpperCase(),
                  style: ParadigmTypography.mono(context).copyWith(fontSize: 11, letterSpacing: 2.8, color: ParadigmColors.textMuted, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _HeaderChip(label: 'Index', icon: Icons.grid_view_rounded, accent: ParadigmColors.textMuted, onTap: onIndex, subtle: true),
                _HeaderChip(label: 'Inquiry', icon: Icons.north_east_rounded, accent: accent, onTap: onInquiry),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderChip extends StatefulWidget {
  const _HeaderChip({required this.label, required this.icon, required this.accent, required this.onTap, this.subtle = false});

  final String label;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;
  final bool subtle;

  @override
  State<_HeaderChip> createState() => _HeaderChipState();
}

class _HeaderChipState extends State<_HeaderChip> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.subtle ? Colors.white.withValues(alpha: 0.06) : widget.accent.withValues(alpha: 0.12);
    final border = widget.subtle ? Colors.white.withValues(alpha: 0.10) : widget.accent.withValues(alpha: 0.30);
    final fg = widget.subtle ? ParadigmColors.textMuted : widget.accent;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: InkWell(
        onTap: widget.onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: _hover ? bg.withValues(alpha: 0.22) : bg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: _hover ? border.withValues(alpha: 0.55) : border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 16, color: fg),
              const SizedBox(width: 8),
              Text(widget.label.toUpperCase(), style: ParadigmTypography.mono(context).copyWith(fontSize: 11, letterSpacing: 2.4, color: fg, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ObjectiveRail extends StatelessWidget {
  const _ObjectiveRail({required this.project, required this.objective, required this.accent, required this.onSelect});

  final ParadigmProject project;
  final String objective;
  final Color accent;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: ParadigmColors.panel,
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Objective'.toUpperCase(), style: ParadigmTypography.mono(context).copyWith(fontSize: 11, letterSpacing: 2.6, color: ParadigmColors.textFaint)),
              const SizedBox(height: 10),
              Text(
                // Internal (archived) guidance: "Reframe the node through customer stories."
                // Client-facing: position this as a practical exploration tool.
                'Choose an objective and step into a customer moment — then watch how each lifecycle decision changes what they feel, trust, and do next.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: ParadigmColors.textMuted, height: 1.5),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: project.cinematic.nodes.keys
                    .map(
                      (key) => _ObjectiveChip(
                        label: key,
                        selected: key == objective,
                        accent: accent,
                        onTap: () => onSelect(key),
                      ),
                    )
                    .toList(growable: false),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded, size: 18, color: ParadigmColors.textMuted),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          // Internal (archived) guidance for authors:
                          // “The SDLC thread becomes the story spine: each phase is a beat, each constraint is a scene.”
                          // Client-facing: translate SDLC into a readable walkthrough.
                          'Move through the lifecycle to see how small choices compound into outcomes — faster onboarding, cleaner revenue, stronger trust.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: ParadigmColors.textMuted, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ObjectiveChip extends StatefulWidget {
  const _ObjectiveChip({required this.label, required this.selected, required this.accent, required this.onTap});

  final String label;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  State<_ObjectiveChip> createState() => _ObjectiveChipState();
}

class _ObjectiveChipState extends State<_ObjectiveChip> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    final bg = selected ? widget.accent.withValues(alpha: 0.14) : Colors.white.withValues(alpha: 0.06);
    final border = selected ? widget.accent.withValues(alpha: 0.45) : Colors.white.withValues(alpha: 0.10);
    final fg = selected ? widget.accent : Colors.white;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: InkWell(
        onTap: widget.onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: _hover ? bg.withValues(alpha: 0.22) : bg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: _hover ? border.withValues(alpha: 0.70) : border),
          ),
          child: Text(widget.label, style: ParadigmTypography.mono(context).copyWith(fontSize: 12, letterSpacing: 0.2, color: fg, fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }
}

class _ObjectiveBottomSheet extends StatelessWidget {
  const _ObjectiveBottomSheet({required this.project, required this.selected, required this.accent});

  final ParadigmProject project;
  final String selected;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final bottomPad = media.viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.lg + bottomPad),
      child: DraggableScrollableSheet(
        initialChildSize: 0.62,
        minChildSize: 0.38,
        maxChildSize: 0.92,
        builder: (context, controller) {
          return DecoratedBox(
            decoration: BoxDecoration(
              color: ParadigmColors.panel,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.md),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Objectives'.toUpperCase(),
                          style: ParadigmTypography.mono(context).copyWith(fontSize: 11, letterSpacing: 2.6, color: ParadigmColors.textFaint),
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
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
                ),
                Expanded(
                  child: ListView(
                    controller: controller,
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
                    children: [
                      Text(
                        'Pick an objective to reframe the sandbox narrative. The story viewport will reset to beat 01.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: ParadigmColors.textMuted, height: 1.5),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: project.cinematic.nodes.keys
                            .map(
                              (key) => _ObjectiveChip(
                                label: key,
                                selected: key == selected,
                                accent: accent,
                                onTap: () => Navigator.of(context).pop(key),
                              ),
                            )
                            .toList(growable: false),
                      ),
                      const SizedBox(height: 14),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.auto_awesome_rounded, size: 18, color: accent.withValues(alpha: 0.86)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Tip: once you’re inside a beat, use Next/Prev to move through phases. Each phase is a lifecycle decision that changes what the customer feels next.',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: ParadigmColors.textMuted, height: 1.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StoryViewport extends StatefulWidget {
  const _StoryViewport({
    required this.accent,
    required this.projectId,
    required this.objective,
    required this.beats,
    required this.controller,
    required this.pageIndex,
    required this.onChanged,
    this.onOpenObjectives,
  });

  final Color accent;
  final String projectId;
  final String objective;
  final List<_StoryBeat> beats;
  final PageController controller;
  final int pageIndex;
  final ValueChanged<int> onChanged;
  final VoidCallback? onOpenObjectives;

  @override
  State<_StoryViewport> createState() => _StoryViewportState();
}

class _StoryViewportState extends State<_StoryViewport> {
  Offset _hover = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final viewport = ParadigmViewport.of(context);
    final beats = widget.beats;
    final accent = widget.accent;

    return MouseRegion(
      onHover: (e) {
        // Keep it extremely low-latency: store raw pointer in state, but throttle rebuilds.
        // (This page is mostly RepaintBoundary-driven; small rebuild here is fine.)
        setState(() => _hover = e.localPosition);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Stack(
          children: [
            Positioned.fill(
              child: RepaintBoundary(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        ParadigmColors.panel,
                        ParadigmColors.bg,
                        accent.withValues(alpha: 0.10),
                      ],
                      stops: const [0, 0.55, 1],
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: Opacity(
                  opacity: 1,
                  child: Transform.translate(
                    offset: Offset((_hover.dx - 240) * 0.012, (_hover.dy - 240) * 0.012),
                    child: ParadigmOntologyBackdrop(
                      projectId: widget.projectId,
                      keyword: widget.objective,
                      accent: accent,
                      opacity: 0.26,
                      complexity: viewport.isCompactHeight ? 0.70 : null,
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: viewport.insetAll(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ViewportTopBar(
                      accent: accent,
                      objective: widget.objective,
                      beats: beats,
                      pageIndex: widget.pageIndex,
                      controller: widget.controller,
                      onOpenObjectives: widget.onOpenObjectives,
                    ),
                    SizedBox(height: viewport.gap(14)),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.06),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                            ),
                            child: PageView.builder(
                              controller: widget.controller,
                              onPageChanged: widget.onChanged,
                              itemCount: beats.length,
                              itemBuilder: (context, i) => _StoryBeatPanel(accent: accent, beat: beats[i], index: i, total: beats.length),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ViewportTopBar extends StatelessWidget {
  const _ViewportTopBar({
    required this.accent,
    required this.objective,
    required this.beats,
    required this.pageIndex,
    required this.controller,
    this.onOpenObjectives,
  });

  final Color accent;
  final String objective;
  final List<_StoryBeat> beats;
  final int pageIndex;
  final PageController controller;
  final VoidCallback? onOpenObjectives;

  @override
  Widget build(BuildContext context) {
    final viewport = ParadigmViewport.of(context);
    final canOpenObjectives = onOpenObjectives != null;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Icon(Icons.explore_rounded, size: 18, color: accent),
            Text(
              objective,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: -0.6),
            ),
            if (canOpenObjectives)
              _MiniNavButton(
                label: 'Objectives',
                icon: Icons.tune_rounded,
                enabled: true,
                accent: accent,
                onTap: onOpenObjectives!,
              ),
            Text(
              // Internal (archived) label: "Customer-story reframe".
              // Client-facing: communicate value without process-language.
              'Customer journey'.toUpperCase(),
              style: ParadigmTypography.mono(context).copyWith(
                fontSize: viewport.isCompact ? 10.5 : 11,
                letterSpacing: viewport.isCompact ? 2.3 : 2.6,
                color: ParadigmColors.textMuted,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _NavDotRow(accent: accent, beats: beats, pageIndex: pageIndex, controller: controller),
            _MiniNavButton(
              label: 'Prev',
              icon: Icons.arrow_back_ios_new_rounded,
              enabled: pageIndex > 0,
              accent: accent,
              onTap: () {
                final next = (pageIndex - 1).clamp(0, beats.length - 1);
                controller.animateToPage(next, duration: const Duration(milliseconds: 240), curve: Curves.easeOutCubic);
              },
            ),
            _MiniNavButton(
              label: 'Next',
              icon: Icons.arrow_forward_ios_rounded,
              enabled: pageIndex < beats.length - 1,
              accent: accent,
              onTap: () {
                final next = (pageIndex + 1).clamp(0, beats.length - 1);
                controller.animateToPage(next, duration: const Duration(milliseconds: 240), curve: Curves.easeOutCubic);
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _NavDotRow extends StatelessWidget {
  const _NavDotRow({required this.accent, required this.beats, required this.pageIndex, required this.controller});

  final Color accent;
  final List<_StoryBeat> beats;
  final int pageIndex;
  final PageController controller;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(
        beats.length,
        (i) => InkWell(
          onTap: () => controller.animateToPage(i, duration: const Duration(milliseconds: 240), curve: Curves.easeOutCubic),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 10,
            width: i == pageIndex ? 26 : 10,
            decoration: BoxDecoration(
              color: i == pageIndex ? accent.withValues(alpha: 0.75) : Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: i == pageIndex ? accent.withValues(alpha: 0.60) : Colors.white.withValues(alpha: 0.10)),
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniNavButton extends StatefulWidget {
  const _MiniNavButton({required this.label, required this.icon, required this.enabled, required this.accent, required this.onTap});

  final String label;
  final IconData icon;
  final bool enabled;
  final Color accent;
  final VoidCallback onTap;

  @override
  State<_MiniNavButton> createState() => _MiniNavButtonState();
}

class _MiniNavButtonState extends State<_MiniNavButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.enabled;
    final fg = enabled ? widget.accent : ParadigmColors.textFaint;
    final bg = enabled ? widget.accent.withValues(alpha: 0.10) : Colors.white.withValues(alpha: 0.04);
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: InkWell(
        onTap: enabled ? widget.onTap : null,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: _hover && enabled ? bg.withValues(alpha: 0.22) : bg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: enabled ? widget.accent.withValues(alpha: 0.28) : Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 14, color: fg),
              const SizedBox(width: 8),
              Text(widget.label.toUpperCase(), style: ParadigmTypography.mono(context).copyWith(fontSize: 11, letterSpacing: 2.3, color: fg, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoryBeatPanel extends StatelessWidget {
  const _StoryBeatPanel({required this.accent, required this.beat, required this.index, required this.total});

  final Color accent;
  final _StoryBeat beat;
  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    final viewport = ParadigmViewport.of(context);
    final pad = viewport.insetAll(AppSpacing.lg);

    // The beat panel is content-dense; on short phones, we switch from a strict
    // vertical stack (which easily overflows) to a scroll-safe column.
    return LayoutBuilder(
      builder: (context, constraints) {
        // Even when the viewport is “tall enough”, the narrative body can be
        // long (especially on narrow phones). If we rely on a strict `Column`
        // without scrolling, the body text can force a RenderFlex overflow.
        //
        // So: always render the beat panel as a scroll-safe column, and use a
        // min-height constraint + Spacer to keep the SDLC thread visually
        // anchored near the bottom when content is short.
        final compact = viewport.isCompact || constraints.maxHeight < 640;

        final headlineStyle = Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
              height: 1.05,
              fontSize: compact ? 26 : null,
            );

        final bodyStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(color: ParadigmColors.textMuted, height: 1.55, fontSize: compact ? 14 : null);

        final metaStyle = ParadigmTypography.mono(context).copyWith(
          fontSize: compact ? 10.5 : 11,
          letterSpacing: compact ? 2.3 : 2.6,
          color: ParadigmColors.textFaint,
        );

        final header = Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _PhasePill(accent: accent, phase: beat.phase),
            Text('Beat ${(index + 1).toString().padLeft(2, '0')} / ${total.toString().padLeft(2, '0')}'.toUpperCase(), style: metaStyle),
          ],
        );

        final threadCard = ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: DecoratedBox(
            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.18), border: Border.all(color: Colors.white.withValues(alpha: 0.08))),
            child: Padding(
              padding: viewport.insetAll(AppSpacing.lg),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.schema_rounded, size: 18, color: accent.withValues(alpha: 0.85)),
                  SizedBox(width: viewport.gap(12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SDLC Thread'.toUpperCase(), style: metaStyle),
                        SizedBox(height: viewport.gap(10)),
                        Text(
                          beat.thread,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.86), height: 1.5, fontSize: compact ? 13 : null),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        final threadHeight = compact ? viewport.gap(220) : viewport.gap(240);

        return Padding(
          padding: pad,
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - pad.vertical),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    header,
                    SizedBox(height: viewport.gap(14)),
                    Text(beat.headline, style: headlineStyle),
                    SizedBox(height: viewport.gap(12)),
                    Text(beat.body, style: bodyStyle),
                    SizedBox(height: viewport.gap(18)),
                    const Spacer(),
                    SizedBox(height: threadHeight, child: threadCard),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PhasePill extends StatelessWidget {
  const _PhasePill({required this.accent, required this.phase});

  final Color accent;
  final String phase;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Text(phase.toUpperCase(), style: ParadigmTypography.mono(context).copyWith(fontSize: 11, letterSpacing: 2.6, color: accent, fontWeight: FontWeight.w900)),
    );
  }
}

@immutable
class _SdlcStep {
  const _SdlcStep({required this.phase, required this.detail, required this.raw});
  final String phase;
  final String detail;
  final String raw;

  static _SdlcStep parse(String raw) {
    final idx = raw.indexOf(':');
    if (idx <= 0) return _SdlcStep(phase: 'Phase', detail: raw.trim(), raw: raw);
    final phase = raw.substring(0, idx).trim();
    final detail = raw.substring(idx + 1).trim();
    return _SdlcStep(phase: phase.isEmpty ? 'Phase' : phase, detail: detail, raw: raw);
  }
}

@immutable
class _StoryBeat {
  const _StoryBeat({required this.phase, required this.headline, required this.body, required this.thread});
  final String phase;
  final String headline;
  final String body;
  final String thread;

  static _StoryBeat from({required String projectId, required String objective, required _SdlcStep step, required int index}) {
    final override = ParadigmNarrativeLibrary.beatFor(projectId: projectId, objective: objective, phase: step.phase);
    if (override != null) {
      return _StoryBeat(phase: step.phase, headline: override.headline, body: override.body, thread: step.raw);
    }

    final persona = _personaFor(projectId, objective);
    final verb = _verbFor(step.phase);
    final headline = '${step.phase}: $verb';
    final body = _bodyFor(projectId: projectId, objective: objective, persona: persona, phase: step.phase, detail: step.detail, index: index);
    return _StoryBeat(phase: step.phase, headline: headline, body: body, thread: step.raw);
  }

  static String _personaFor(String projectId, String objective) {
    switch (projectId) {
      case 'tipzero':
        if (objective.toLowerCase().contains('growth')) return 'a first-time merchant owner';
        if (objective.toLowerCase().contains('monet')) return 'a service worker closing a late shift';
        if (objective.toLowerCase().contains('security')) return 'an ad-network compliance analyst';
        if (objective.toLowerCase().contains('govern')) return 'an App Store reviewer';
        return 'a regular customer in a hurry';
      case 'bridge':
        if (objective.toLowerCase().contains('growth')) return 'a parent evaluating a new learning tool';
        if (objective.toLowerCase().contains('monet')) return 'a district buyer with a fixed budget';
        if (objective.toLowerCase().contains('security')) return 'a school administrator guarding student privacy';
        if (objective.toLowerCase().contains('govern')) return 'a teacher managing approvals';
        return 'a student trying to stay engaged';
      default:
        return 'a user';
    }
  }

  static String _verbFor(String phase) {
    switch (phase.toLowerCase()) {
      case 'discovery':
        return 'We find the real constraint';
      case 'signal':
        return 'We prove the wedge';
      case 'prototype':
        return 'We simulate the tradeoff';
      case 'build':
        return 'We isolate risk into boundaries';
      case 'launch':
        return 'We instrument the truth';
      case 'iterate':
        return 'We tune the loop';
      default:
        return 'We turn intent into mechanism';
    }
  }

  static String _bodyFor({required String projectId, required String objective, required String persona, required String phase, required String detail, required int index}) {
    final objectiveTag = objective.toLowerCase();
    final isMonet = objectiveTag.contains('monet');
    final isGrowth = objectiveTag.contains('growth');
    final isSec = objectiveTag.contains('security');
    final isGov = objectiveTag.contains('govern');
    final isEng = objectiveTag.contains('engagement');

    // Keep it deterministic + fast: no backend/LLM calls — purely templated.
    String setup;
    if (projectId == 'tipzero') {
      setup = 'In TipZero, $persona wants the reward to feel instant. A delay, a confusing screen, or a “why is this asking me?” moment is enough to abandon the flow.';
    } else if (projectId == 'bridge') {
      setup = 'In BridgeBound, $persona needs clarity fast. If the experience feels slow, unclear, or unsafe, they won’t come back — and they won’t recommend it.';
    } else {
      setup = 'A customer arrives with a simple goal, and the system has one job: make the next step feel inevitable.';
    }

    String focus;
    if (isMonet) {
      focus = 'The monetization moment only works if the value exchange is obvious and the ledger is provably correct.';
    } else if (isGrowth) {
      focus = 'Growth only compounds if the first loop is frictionless and the second loop is social.';
    } else if (isSec) {
      focus = 'Security isn’t a feature — it’s the boundary that keeps the narrative honest under adversarial pressure.';
    } else if (isGov) {
      focus = 'Governance is the permission to scale: rules, audits, and override paths that don’t collapse UX.';
    } else if (isEng) {
      focus = 'Engagement emerges from micro-wins, not noise — the interface must reward attention without demanding it.';
    } else {
      focus = 'The objective becomes a mechanism.';
    }

    final phaseLine = switch (phase.toLowerCase()) {
      'discovery' => 'We start by watching what the customer actually does around “$detail” — where they hesitate, what they assume, and what they refuse to tolerate.',
      'signal' => 'We choose one measurable promise inside “$detail” and make it easy to prove — so the customer feels the value before they’re asked to commit.',
      'prototype' => 'We rehearse “$detail” with a lightweight prototype, so feedback arrives early and the experience stays confident instead of complicated.',
      'build' => 'We build “$detail” with guardrails: the happy path stays effortless, and edge cases fail safely without breaking trust.',
      'launch' => 'We launch “$detail” with clarity: the customer knows what changed, and we can measure what they do next — not just what they click.',
      'iterate' => 'We iterate “$detail” by removing friction and sharpening timing until the outcome becomes repeatable, not lucky.',
      _ => 'We translate “$detail” into a shippable step that the customer can feel immediately.',
    };

    final cadence = (index % 2 == 0)
        ? 'By the end of this moment, the customer should feel one thing: “this is working.” The next phase only matters if that feeling survives.'
        : 'By the end of this moment, trust is either earned or lost. The system’s job is to protect the customer from the kind of failure they remember.';

    return '$setup\n\n$focus\n\n$phaseLine\n\n$cadence';
  }
}
