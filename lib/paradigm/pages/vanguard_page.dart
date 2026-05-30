import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:parallel_paradigm_org/nav.dart';
import 'package:parallel_paradigm_org/paradigm/paradigm_shell.dart';
import 'package:parallel_paradigm_org/paradigm/paradigm_simulation.dart';
import 'package:parallel_paradigm_org/paradigm/widgets/cinematic_tiles.dart';
import 'package:parallel_paradigm_org/paradigm/widgets/paradigm_top_nav.dart';
import 'package:parallel_paradigm_org/theme.dart';

class VanguardPage extends StatelessWidget {
  const VanguardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ParadigmColors.bg,
      body: ParadigmShell(
        stage: ParadigmStage.vanguard,
        accessState: ParadigmAccessState.locked,
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: _CinematicLanding(
                  onInquiry: () => context.go(AppRoutes.inquiry),
                  onIndex: () => context.go(AppRoutes.grid),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: ParadigmTopNav(
                  background: Colors.transparent,
                  showBottomBorder: false,
                  // Avoid repeating “Parallel Paradigm” in the lockup: the word mark
                  // is already rendered as a dedicated line inside ParadigmBrandLockup.
                  left: const ParadigmBrandLockup(tagline: null),
                  right: _TopRightNav(
                    onInquiry: () => context.go(AppRoutes.inquiry),
                    onIndex: () => context.go(AppRoutes.grid),
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

class _CinematicLanding extends StatefulWidget {
  const _CinematicLanding({required this.onInquiry, required this.onIndex});

  final VoidCallback onInquiry;
  final VoidCallback onIndex;

  @override
  State<_CinematicLanding> createState() => _CinematicLandingState();
}

class _CinematicLandingState extends State<_CinematicLanding> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final padding = ParadigmTopNav.defaultPaddingFor(context);
    final topPad = 112 + padding.top;
    return Padding(
      padding: EdgeInsets.fromLTRB(padding.left, topPad, padding.right, padding.bottom),
      child: Stack(
        children: [
          PageView(
            controller: _controller,
            scrollDirection: Axis.vertical,
            children: [
              CinematicTile(
                kicker: 'Olympia Lacey Design',
                title: 'A cinematic web studio\ninside Parallel Paradigm.',
                subtitle:
                    'This experience is a living proof: motion, hover states, perspective, blur, gradient mapping, and micro-interactions — built in Flutter Web as a stand-in for “anything CSS can do.”',
                keywords: const ['Hover', 'Parallax', 'Filters', 'Transforms', 'Motion'],
                accent: ParadigmColors.accentCyan,
                interactiveKeywords: true,
                demoSet: CinematicDemoSet.experienceTech,
                actionLabel: 'Scroll',
                onTap: () {
                  _controller.nextPage(duration: const Duration(milliseconds: 520), curve: Curves.easeOutCubic);
                },
              ),
              CinematicTile(
                kicker: 'Proof of execution',
                title: 'Case studies as\ninteractive sequences.',
                subtitle:
                    'Enter the archive to see systems, outcomes, and instrumentation. Each project expands into a gated deep dive — engineered for signal, not noise.',
                keywords: const ['Outcomes', 'Systems', 'Instrumentation', 'Governance'],
                accent: ParadigmColors.accentViolet,
                interactiveKeywords: true,
                demoSet: CinematicDemoSet.proofExecution,
                actionLabel: 'Enter index',
                onTap: widget.onIndex,
              ),
              CinematicTile(
                kicker: 'Direct line',
                title: 'Commission a build\nor prototype.',
                subtitle:
                    'If you have a target outcome, we’ll design the system. The inquiry funnel stays — but it’s no longer the homepage’s only objective.',
                keywords: const ['Discovery', 'Prototype', 'Delivery', 'Iteration'],
                accent: ParadigmColors.accentAmber,
                interactiveKeywords: true,
                demoSet: CinematicDemoSet.commission,
                actionLabel: 'Start inquiry',
                onTap: widget.onInquiry,
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    'SCROLL • HOVER • CLICK'.toUpperCase(),
                    style: ParadigmTypography.mono(context).copyWith(
                      fontSize: 10,
                      letterSpacing: 3.0,
                      color: ParadigmColors.textFaint,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopRightNav extends StatelessWidget {
  const _TopRightNav({required this.onInquiry, required this.onIndex});

  final VoidCallback onInquiry;
  final VoidCallback onIndex;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final showLocation = w >= 380;
    return Wrap(
      spacing: 18,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ParadigmTopNavAction(label: 'Inquiry', subtitle: showLocation ? '' : null, onTap: onInquiry, bright: true),
        ParadigmTopNavAction(
          label: 'Index',
          subtitle: showLocation ? 'Lacey, WA' : null,
          onTap: onIndex,
          bright: true,
          alignEnd: true,
        ),
      ],
    );
  }
}
