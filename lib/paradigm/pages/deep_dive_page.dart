import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:parallel_paradigm_org/nav.dart';
import 'package:parallel_paradigm_org/paradigm/paradigm_data.dart';
import 'package:parallel_paradigm_org/paradigm/paradigm_shell.dart';
import 'package:parallel_paradigm_org/paradigm/paradigm_simulation.dart';
import 'package:parallel_paradigm_org/paradigm/upp_v4_spec.dart';
import 'package:parallel_paradigm_org/paradigm/widgets/cinematic_tiles.dart';
import 'package:parallel_paradigm_org/paradigm/widgets/paradigm_top_nav.dart';
import 'package:parallel_paradigm_org/paradigm/widgets/pixel_motif.dart';
import 'package:parallel_paradigm_org/theme.dart';

class DeepDivePage extends StatefulWidget {
  const DeepDivePage({super.key, required this.projectId});

  final String projectId;

  @override
  State<DeepDivePage> createState() => _DeepDivePageState();
}

class _DeepDivePageState extends State<DeepDivePage> {
  late final ParadigmProject? _project;
  String? _selectedObjective;

  @override
  void initState() {
    super.initState();
    _project = ParadigmProjects.projects[widget.projectId];
  }

  @override
  Widget build(BuildContext context) {
    final project = _project;
    return Scaffold(
      backgroundColor: ParadigmColors.bg,
      body: ParadigmShell(
        stage: ParadigmStage.deepDive,
        accessState: ParadigmAccessState.locked,
        child: project == null
            ? SafeArea(
                child: Center(
                  child: Text(
                    'Project not found.'.toUpperCase(),
                    style: ParadigmTypography.mono(context).copyWith(color: ParadigmColors.textMuted, letterSpacing: 2.6),
                  ),
                ),
              )
            : EdgeSwipeBack(
                onBack: () => context.go(AppRoutes.grid),
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
                              constraints: const BoxConstraints(maxWidth: 980),
                              child: _DeepDiveContent(
                                project: project,
                                 selectedObjective: _selectedObjective,
                                 onSelectedObjectiveChanged: (next) => setState(() => _selectedObjective = next),
                              ),
                            ),
                          ),
                        ),
                      ),
                      _DeepDiveHeader(
                        onBack: () => context.go(AppRoutes.grid),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _DeepDiveContent extends StatelessWidget {
  const _DeepDiveContent({required this.project, required this.selectedObjective, required this.onSelectedObjectiveChanged});

  final ParadigmProject project;
  final String? selectedObjective;
  final ValueChanged<String?> onSelectedObjectiveChanged;

  @override
  Widget build(BuildContext context) {
    const upp = UppV4Engine();
    final viewportW = MediaQuery.sizeOf(context).width;
    final accent = ParadigmKeywordPalette.colorFor(project.title);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Index Node ${project.index}'.toUpperCase(),
          style: ParadigmTypography.mono(context).copyWith(fontSize: 12, letterSpacing: 2.6, color: ParadigmColors.textFaint),
        ),
        const SizedBox(height: 10),
        Text(
          project.title.toUpperCase(),
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -2.2,
            height: 0.85,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 18),
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
        const SizedBox(height: 44),

        CinematicTile(
          kicker: project.cinematic.kicker,
          title: project.cinematic.title,
          subtitle: project.cinematic.subtitle,
          keywords: project.cinematic.nodes.keys.toList(growable: false),
          accent: accent,
          onTap: () => context.push(AppRoutes.projectExplore(project.id, objective: selectedObjective)),
          actionLabel: 'Explore',
          // Use more of the viewport so longer objective lists never clip.
          // (The tile also internally guards overflow with a scrollable narrative.)
          height: () {
            final s = MediaQuery.sizeOf(context);
            final target = s.height * (s.width >= 980 ? 0.62 : 0.70);
            return target.clamp(560.0, 740.0);
          }(),
          interactiveKeywords: true,
          demoTemplate: project.cinematic.nodes,
          initialKeyword: selectedObjective,
          onKeywordChanged: onSelectedObjectiveChanged,
          art: project.id == 'bridge'
              ? upp.bridgeboundTileArtifacts(tileId: 'deepdive.hero', accent: accent, viewportWidth: viewportW)
              : null,
        ),
      ],
    );
  }
}

class _DeepDiveHeader extends StatelessWidget {
  const _DeepDiveHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
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
            _BackChip(onTap: onBack),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                InkWell(
                  onTap: () => context.go(AppRoutes.inquiry),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  child: Text(
                    'Start Inquiry'.toUpperCase(),
                    style: ParadigmTypography.mono(context).copyWith(
                      fontSize: 11,
                      letterSpacing: 2.6,
                      color: ParadigmColors.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BackChip extends StatefulWidget {
  const _BackChip({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_BackChip> createState() => _BackChipState();
}

class _BackChipState extends State<_BackChip> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: InkWell(
        onTap: widget.onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _hover ? 0.7 : 1.0,
          child: Text(
            '← Return to Grid'.toUpperCase(),
            style: ParadigmTypography.mono(context).copyWith(
              fontSize: 11,
              letterSpacing: 2.6,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
