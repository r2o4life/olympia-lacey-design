import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:parallel_paradigm_org/nav.dart';
import 'package:parallel_paradigm_org/paradigm/paradigm_data.dart';
import 'package:parallel_paradigm_org/paradigm/paradigm_shell.dart';
import 'package:parallel_paradigm_org/paradigm/paradigm_simulation.dart';
import 'package:parallel_paradigm_org/paradigm/widgets/pixel_motif.dart';
import 'package:parallel_paradigm_org/paradigm/widgets/paradigm_top_nav.dart';
import 'package:parallel_paradigm_org/theme.dart';

class GridPage extends StatelessWidget {
  const GridPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ParadigmColors.bg,
      body: ParadigmShell(
        stage: ParadigmStage.grid,
        accessState: ParadigmAccessState.locked,
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
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
                    child: const ParadigmBrandLockup(),
                  ),
                  right: Wrap(
                    spacing: 18,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ParadigmTopNavAction(label: 'Inquiry', subtitle: '', onTap: () => context.go(AppRoutes.inquiry), bright: true),
                      _IndexBlock(onTap: () => context.go(AppRoutes.grid)),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 104),
                child: ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.sizeOf(context).width < 420 ? AppSpacing.lg : AppSpacing.xl,
                    vertical: AppSpacing.xl,
                  ),
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1120),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Index'.toUpperCase(),
                              style: ParadigmTypography.mono(context).copyWith(
                                fontSize: 11,
                                letterSpacing: 2.8,
                                color: ParadigmColors.textFaint,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Olympia Lacey Design • Parallel Paradigm — proof of execution, rendered as systems.',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 14),
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
                            const SizedBox(height: 28),
                            ...ParadigmProjects.projects.entries
                                .map((e) => _ProjectRow(project: e.value, onTap: () => context.go(AppRoutes.project(e.key))))
                                .toList(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IndexBlock extends StatelessWidget {
  const _IndexBlock({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final showLocation = w >= 380;
    return ParadigmTopNavAction(
      label: 'Index',
      subtitle: showLocation ? 'Lacey, WA' : '',
      onTap: onTap,
      bright: false,
      alignEnd: true,
    );
  }
}

class _ProjectRow extends StatefulWidget {
  const _ProjectRow({required this.project, required this.onTap});

  final ParadigmProject project;
  final VoidCallback onTap;

  @override
  State<_ProjectRow> createState() => _ProjectRowState();
}

class _ProjectRowState extends State<_ProjectRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: _hover ? 18 : 0, vertical: 22),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
            top: const BorderSide(color: Colors.transparent),
          ),
        ),
        child: InkWell(
          onTap: widget.onTap,
          splashColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.project.index} — ${widget.project.focus}'.toUpperCase(),
                      style: ParadigmTypography.mono(context).copyWith(
                        fontSize: 10,
                        letterSpacing: 2.6,
                        color: ParadigmColors.textFaint,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.project.title.toUpperCase(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.8,
                        height: 0.9,
                        color: _hover ? ParadigmColors.textMuted : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _hover ? 1 : 0.6,
                child: Icon(Icons.arrow_outward, color: ParadigmColors.textFaint, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
