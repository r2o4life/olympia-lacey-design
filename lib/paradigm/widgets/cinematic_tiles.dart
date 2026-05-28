import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:parallel_paradigm_org/paradigm/widgets/pixel_motif.dart';
import 'package:parallel_paradigm_org/theme.dart';

/// A cinematic, near-full-viewport tile that leans into hover-driven transforms
/// and parallax effects (Flutter web equivalent of “CSS transform/filter”).
///
/// - Desktop/web: hover + cursor tracking drives perspective tilt + glow.
/// - Mobile: tap + scroll still feels “panel-like” without hover.
class CinematicTile extends StatefulWidget {
  const CinematicTile({
    super.key,
    required this.kicker,
    required this.title,
    required this.subtitle,
    required this.keywords,
    required this.accent,
    required this.onTap,
    this.actionLabel,
    this.height,
    this.interactiveKeywords = false,
    this.demoSet = CinematicDemoSet.experienceTech,
    this.demoTemplate,
    this.initialKeyword,
    this.onKeywordChanged,
  });

  final String kicker;
  final String title;
  final String subtitle;
  final List<String> keywords;
  final Color accent;
  final VoidCallback onTap;
  final String? actionLabel;
  final double? height;
  final bool interactiveKeywords;
  final CinematicDemoSet demoSet;

  /// Optional per-tile template data for the progressive disclosure sandbox.
  /// When provided, the demo viewport will render a low-latency “live template”
  /// based on `keyword -> sub nodes`.
  final Map<String, List<String>>? demoTemplate;

  /// When [interactiveKeywords] is true, this allows the parent to control the
  /// initial active keyword (objective) selection.
  final String? initialKeyword;

  /// Emits the active keyword whenever it changes (including clearing).
  ///
  /// Useful for routing flows where an "Explore" CTA should carry the current
  /// objective selection into a full sandbox view.
  final ValueChanged<String?>? onKeywordChanged;

  @override
  State<CinematicTile> createState() => _CinematicTileState();
}

enum CinematicDemoSet {
  experienceTech,
  proofExecution,
  commission,
}

class _CinematicTileState extends State<CinematicTile> {
  bool _hover = false;
  Offset _pointer = Offset.zero;

  String? _activeKeyword;
  String? _activeBusiness;

  @override
  void initState() {
    super.initState();
    if (widget.interactiveKeywords) {
      final desired = widget.initialKeyword;
      if (desired != null && widget.keywords.contains(desired)) {
        _activeKeyword = desired;
        _activeBusiness = _pickBusinessTemplate(desired);
      }
    }
  }

  @override
  void didUpdateWidget(covariant CinematicTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.interactiveKeywords) return;

    // If the parent changes the desired initial keyword, respect it.
    if (widget.initialKeyword != oldWidget.initialKeyword) {
      final desired = widget.initialKeyword;
      if (desired == null || desired.trim().isEmpty) {
        if (_activeKeyword != null) {
          setState(() {
            _activeKeyword = null;
            _activeBusiness = null;
          });
        }
        return;
      }

      if (widget.keywords.contains(desired) && _activeKeyword != desired) {
        setState(() {
          _activeKeyword = desired;
          _activeBusiness = _pickBusinessTemplate(desired);
        });
      }
    }
  }

  static const Map<CinematicDemoSet, Map<String, List<String>>> _templates = {
    CinematicDemoSet.experienceTech: {
      'Hover': [
        'Puppy Grooming Service',
        'Vintage Camera Repair',
        'Cold Brew Micro-Roastery',
        'Mobile Bike Tune-Ups',
        'Custom Candle Atelier',
      ],
      'Parallax': [
        'Boutique Travel Planner',
        'Eco-Landscape Studio',
        'Local Food Tour Operator',
        'Indie Bookshop + Cafe',
        'Modern Museum Exhibit',
      ],
      'Filters': [
        'Skincare Lab Landing Page',
        'Wedding Film Studio',
        'Art Print Marketplace',
        'Specialty Tea Brand',
        'Architectural Portfolio',
      ],
      'Transforms': [
        'Fitness Coaching Program',
        'SaaS Pricing Calculator',
        'Restaurant Tasting Menu',
        'Real Estate Showcase',
        'Event Ticketing Drop',
      ],
      'Motion': [
        'Product Launch Countdown',
        'Nonprofit Impact Report',
        'Podcast Network Hub',
        'New Album Release Site',
        'Conference Schedule',
      ],
    },
    CinematicDemoSet.proofExecution: {
      'Outcomes': ['Retention lift', 'Conversion lift', 'CAC efficiency', 'Activation rate', 'Revenue per visit'],
      'Systems': ['Routing + state', 'Design tokens', 'Data layer', 'Instrumentation', 'Release pipeline'],
      'Instrumentation': ['Event stream', 'Performance marks', 'Error tracing', 'Session replay hooks', 'Funnel analysis'],
      'Governance': ['Guardrails', 'Security posture', 'Access control', 'Quality gates', 'Content integrity'],
    },
    CinematicDemoSet.commission: {
      'Discovery': ['Scope', 'Constraints', 'Signals', 'Audience', 'Timeline'],
      'Prototype': ['Interaction model', 'Motion language', 'Component kit', 'Risk spike', 'Clickable demo'],
      'Delivery': ['Build', 'QA', 'Performance', 'Launch', 'Handoff'],
      'Iteration': ['Measure', 'Learn', 'Refine', 'Ship', 'Repeat'],
    },
  };

  void _toggleKeyword(String keyword) {
    if (!widget.interactiveKeywords) return;
    setState(() {
      if (_activeKeyword == keyword) {
        _activeKeyword = null;
        _activeBusiness = null;
      } else {
        _activeKeyword = keyword;
        _activeBusiness = _pickBusinessTemplate(keyword);
      }
    });
    widget.onKeywordChanged?.call(_activeKeyword);
  }

  String _pickBusinessTemplate(String keyword) {
    final list = widget.demoTemplate?[keyword] ?? _templates[widget.demoSet]?[keyword];
    if (list == null || list.isEmpty) return 'Modern Service Studio';
    final r = math.Random(DateTime.now().microsecondsSinceEpoch);
    return list[r.nextInt(list.length)];
  }

  void _handleHover(Offset local, Size s) {
    if (s.width <= 1 || s.height <= 1) return;
    // Normalize pointer in [-1, 1] but clamp a bit tighter so extreme-corner
    // hovers don't produce dramatic transforms that reduce usability.
    final nx = (local.dx / s.width) * 2 - 1;
    final ny = (local.dy / s.height) * 2 - 1;
    const maxAbs = 0.78;
    setState(() => _pointer = Offset(nx.clamp(-maxAbs, maxAbs), ny.clamp(-maxAbs, maxAbs)));
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final h = widget.height ?? (MediaQuery.sizeOf(context).height * 0.92);

    // Avoid hover transforms on touch devices.
    final hoverEnabled = kIsWeb || {
      TargetPlatform.macOS,
      TargetPlatform.windows,
      TargetPlatform.linux,
    }.contains(defaultTargetPlatform);

    final demoMode = widget.interactiveKeywords && _activeKeyword != null;

    // When a keyword demo is open we intentionally pause the large tile motion so
    // the demo viewport reads as the “active” region.
    final hoverT = hoverEnabled && _hover && !demoMode ? 1.0 : 0.0;
    // Keep tilt subtle: the tile should feel reactive without letting the
    // transform dominate the interaction (buttons/chips must remain usable).
    final tiltX = _pointer.dy * -0.055 * hoverT;
    final tiltY = _pointer.dx * 0.070 * hoverT;
    final parallax = Offset(_pointer.dx * 12, _pointer.dy * 9);

    final baseBorder = BorderSide(color: Colors.white.withValues(alpha: _hover ? 0.20 : 0.12));
    final glow = widget.accent.withValues(alpha: _hover ? 0.26 : 0.12);

    return LayoutBuilder(
      builder: (context, c) {
        final tileSize = Size(c.maxWidth, h);
        return MouseRegion(
          onEnter: (_) => setState(() => _hover = true),
          onExit: (_) => setState(() {
            _hover = false;
            _pointer = Offset.zero;
          }),
          onHover: hoverEnabled ? (e) => _handleHover(e.localPosition, tileSize) : null,
          cursor: demoMode ? SystemMouseCursors.basic : SystemMouseCursors.click,
          child: AnimatedContainer(
            // Keep a small easing window on enter/exit, but let pointer updates be
            // immediate (state-driven) for low perceived latency.
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            height: h,
            // Important: avoid double padding (outer + inner) which shrinks the
            // usable viewport area and can cause keyword/objective chip clipping.
            // The inner content padding already provides the desired breathing room.
            padding: EdgeInsets.zero,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: hoverT),
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              builder: (context, t, child) {
            final scale = 1 + (0.012 * t);
            final lift = -6 * t;
            final blur = 5.0 * t;
            final sheen = 0.10 + (0.18 * t);

            // Visual transform: only apply perspective tilt to non-interactive
            // background layers. Foreground content stays stable for usability
            // and consistent hit testing.
            final bgMatrix = Matrix4.identity()
              ..setEntry(3, 2, 0.0016)
              ..rotateX(tiltX)
              ..rotateY(tiltY)
              ..scale(1.0 + 0.010 * t);

            // Gentle lift/scale on the overall tile, but keep hit testing in the
            // original rect so buttons/chips don't become "hard to hit" near
            // corners.
            final tileMatrix = Matrix4.identity()..translate(0.0, lift)..scale(scale);

            return Transform(
              alignment: Alignment.center,
              transform: tileMatrix,
              transformHitTests: false,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.xl),
                // Important: the full-tile tap handler must NOT sit as a top-most
                // overlay in the Stack, otherwise it will intercept taps intended
                // for interactive sub-nodes (keyword chips / action button).
                //
                // Wrapping the Stack with InkWell allows child InkWells to win the
                // gesture arena, while still letting "empty space" trigger the
                // primary tile action.
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: demoMode ? null : widget.onTap,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Background (tilt/parallax lives here).
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Transform(
                              alignment: Alignment.center,
                              transform: bgMatrix,
                              transformHitTests: false,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  // “CSS background layer” — gradient + subtle vignette.
                                  DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: ParadigmColors.bg,
                                      gradient: LinearGradient(
                                        begin: Alignment(-0.9 + _pointer.dx * 0.15, -0.8 + _pointer.dy * 0.12),
                                        end: Alignment(0.9 - _pointer.dx * 0.15, 0.8 - _pointer.dy * 0.12),
                                        colors: [
                                          Colors.white.withValues(alpha: 0.04 + 0.02 * t),
                                          widget.accent.withValues(alpha: 0.10 + 0.10 * t),
                                          Colors.black.withValues(alpha: 0.60),
                                        ],
                                        stops: const [0.0, 0.55, 1.0],
                                      ),
                                      border: Border.fromBorderSide(baseBorder),
                                    ),
                                  ),

                                  // “CSS filter layer” — animated blur/glass.
                                  Positioned.fill(
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                                      child: Container(color: Colors.transparent),
                                    ),
                                  ),

                                  // Motif field (parallax).
                                  Positioned.fill(
                                    child: Transform.translate(
                                      offset: parallax,
                                      child: _MotifField(accent: widget.accent),
                                    ),
                                  ),

                                  // Sheen.
                                  Positioned.fill(
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: const Alignment(-1.0, -0.6),
                                          end: const Alignment(1.0, 0.6),
                                          colors: [
                                            Colors.white.withValues(alpha: sheen),
                                            Colors.white.withValues(alpha: 0.0),
                                            Colors.white.withValues(alpha: 0.06 + 0.06 * t),
                                          ],
                                          stops: const [0.0, 0.55, 1.0],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Content + optional demo viewport.
                        Padding(
                          padding: EdgeInsets.all(isWideLayout(context) ? AppSpacing.xl : AppSpacing.lg),
                          child: _CinematicTileContent(
                            kicker: widget.kicker,
                            title: widget.title,
                            subtitle: widget.subtitle,
                            keywords: widget.keywords,
                            accent: widget.accent,
                            actionLabel: widget.actionLabel,
                            hover: _hover,
                            interactiveKeywords: widget.interactiveKeywords,
                            demoSet: widget.demoSet,
                            demoTemplate: widget.demoTemplate,
                            activeKeyword: _activeKeyword,
                            activeBusiness: _activeBusiness,
                            onKeywordTap: _toggleKeyword,
                            onActionTap: widget.onTap,
                            demoMode: demoMode,
                          ),
                        ),

                        // Edge vignette.
                        Positioned.fill(
                          child: IgnorePointer(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(color: glow, blurRadius: 48, spreadRadius: 2, offset: const Offset(0, 18)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
              },
            ),
          ),
        );
      },
    );
  }
}

bool isWideLayout(BuildContext context) => MediaQuery.sizeOf(context).width >= 980;

class _CinematicTileContent extends StatelessWidget {
  const _CinematicTileContent({
    required this.kicker,
    required this.title,
    required this.subtitle,
    required this.keywords,
    required this.accent,
    required this.actionLabel,
    required this.hover,
    required this.interactiveKeywords,
    required this.demoSet,
    required this.demoTemplate,
    required this.activeKeyword,
    required this.activeBusiness,
    required this.onKeywordTap,
    required this.onActionTap,
    required this.demoMode,
  });

  final String kicker;
  final String title;
  final String subtitle;
  final List<String> keywords;
  final Color accent;
  final String? actionLabel;
  final bool hover;
  final bool interactiveKeywords;
  final CinematicDemoSet demoSet;
  final Map<String, List<String>>? demoTemplate;
  final String? activeKeyword;
  final String? activeBusiness;
  final ValueChanged<String> onKeywordTap;
  final VoidCallback onActionTap;
  final bool demoMode;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final isWide = MediaQuery.sizeOf(context).width >= 980;

    // MECE overflow guard (content > fixed tile height): allow the narrative
    // stack (kicker/title/subtitle/chips) to scroll while keeping the primary
    // action pinned to the bottom. This prevents RenderFlex overflows (yellow/
    // black stripes) when keywords are long or wrap into extra lines.
    final scrollBehavior = ScrollConfiguration.of(context).copyWith(scrollbars: false, overscroll: false);

    final narrative = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          kicker.toUpperCase(),
          style: ParadigmTypography.mono(context).copyWith(
            fontSize: 11,
            letterSpacing: 3.0,
            color: Colors.white.withValues(alpha: 0.86),
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          title,
          style: text.displaySmall?.copyWith(
            fontWeight: FontWeight.w900,
            height: 0.95,
            letterSpacing: -1.6,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 14),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Text(
            subtitle,
            style: text.bodyLarge?.copyWith(height: 1.55, color: ParadigmColors.textPrimary.withValues(alpha: 0.86)),
          ),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: keywords.map((k) {
            if (!interactiveKeywords) return ParadigmKeywordChip(keyword: k);
            final selected = activeKeyword == k;
            return _InteractiveKeywordChip(keyword: k, selected: selected, onTap: () => onKeywordTap(k));
          }).toList(growable: false),
        ),
      ],
    );

    final left = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ScrollConfiguration(
            behavior: scrollBehavior,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(padding: const EdgeInsets.only(bottom: 14), child: narrative),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomLeft,
          child: _CinematicAction(
            label: (actionLabel ?? 'Enter').toUpperCase(),
            accent: accent,
            hover: hover && !demoMode,
            // Even when a keyword demo is open, the primary action should remain
            // actionable (e.g., "Explore" should still open the full sandbox and
            // carry the current selection). We only disable the *full-tile* tap
            // surface when demoMode is active (handled in the parent InkWell).
            onTap: onActionTap,
          ),
        ),
      ],
    );

    final demo = AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(position: Tween(begin: const Offset(0, 0.06), end: Offset.zero).animate(anim), child: child),
      ),
      child: activeKeyword == null
          ? const SizedBox.shrink()
          : _KeywordDemoViewport(
              key: ValueKey('${activeKeyword}_$activeBusiness'),
              keyword: activeKeyword!,
              accent: accent,
              business: activeBusiness ?? 'Modern Service Studio',
              demoSet: demoSet,
              demoTemplate: demoTemplate,
              onClose: () => onKeywordTap(activeKeyword!),
            ),
    );

    if (!interactiveKeywords) return left;

    if (!isWide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: left),
          if (activeKeyword != null) ...[
            const SizedBox(height: 18),
            SizedBox(height: 220, child: demo),
          ],
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 22),
        SizedBox(width: 360, child: demo),
      ],
    );
  }
}

class _InteractiveKeywordChip extends StatefulWidget {
  const _InteractiveKeywordChip({required this.keyword, required this.selected, required this.onTap});
  final String keyword;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_InteractiveKeywordChip> createState() => _InteractiveKeywordChipState();
}

class _InteractiveKeywordChipState extends State<_InteractiveKeywordChip> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final color = ParadigmKeywordPalette.colorFor(widget.keyword);
    final borderAlpha = widget.selected
        ? 0.26
        : _hover
            ? 0.20
            : 0.14;
    // Keep chips readable under all tile hover/sheens by anchoring to a dark
    // glass base + accent tint (instead of relying on low-alpha tinted fills).
    final bgAlpha = widget.selected
        ? 0.22
        : _hover
            ? 0.16
            : 0.12;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: widget.onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: Colors.white.withValues(alpha: borderAlpha + (_hover ? 0.06 : 0.0))),
            color: Colors.black.withValues(alpha: 0.28 + (widget.selected ? 0.08 : 0.0)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withValues(alpha: bgAlpha), Colors.white.withValues(alpha: 0.04), Colors.black.withValues(alpha: 0.28)],
            ),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ParadigmPixelMotif(keyword: widget.keyword, size: 16, color: color),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  widget.keyword.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ParadigmTypography.mono(context).copyWith(
                    fontSize: 10,
                    letterSpacing: 2.0,
                    color: Colors.white.withValues(alpha: widget.selected ? 0.98 : 0.88),
                    fontWeight: widget.selected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
              if (widget.selected) ...[
                const SizedBox(width: 10),
                Icon(Icons.close_rounded, size: 16, color: Colors.white.withValues(alpha: 0.85)),
              ],
            ],
            ),
          ),
        ),
      ),
    );
  }
}

class _KeywordDemoViewport extends StatelessWidget {
  const _KeywordDemoViewport({
    super.key,
    required this.keyword,
    required this.accent,
    required this.business,
    required this.demoSet,
    required this.demoTemplate,
    required this.onClose,
  });

  final String keyword;
  final Color accent;
  final String business;
  final CinematicDemoSet demoSet;
  final Map<String, List<String>>? demoTemplate;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final labelStyle = ParadigmTypography.mono(context).copyWith(
      fontSize: 10,
      letterSpacing: 2.6,
      color: ParadigmColors.textFaint,
      fontWeight: FontWeight.w700,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      colors: [
                        accent.withValues(alpha: 0.22),
                        ParadigmColors.bg,
                        Colors.white.withValues(alpha: 0.06),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text('LIVE SAMPLE'.toUpperCase(), style: labelStyle)),
                      InkWell(
                        onTap: onClose,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Icon(Icons.close_rounded, size: 18, color: Colors.white.withValues(alpha: 0.85)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    keyword.toUpperCase(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.6,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    business.toUpperCase(),
                    style: ParadigmTypography.mono(context).copyWith(
                      fontSize: 10.5,
                      letterSpacing: 2.4,
                      color: Colors.white.withValues(alpha: 0.86),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Expanded(child: _KeywordDemoBody(keyword: keyword, accent: accent, business: business, demoSet: demoSet, demoTemplate: demoTemplate)),
                  const SizedBox(height: 10),
                  Text('SELECT ANOTHER NODE TO GENERATE A NEW TEMPLATE.'.toUpperCase(), style: labelStyle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KeywordDemoBody extends StatelessWidget {
  const _KeywordDemoBody({required this.keyword, required this.accent, required this.business, required this.demoSet, required this.demoTemplate});
  final String keyword;
  final Color accent;
  final String business;
  final CinematicDemoSet demoSet;
  final Map<String, List<String>>? demoTemplate;

  @override
  Widget build(BuildContext context) {
    final template = demoTemplate;
    if (template != null) {
      return _CustomNarrativeDemo(accent: accent, title: keyword, items: template[keyword] ?? const []);
    }
    return switch (demoSet) {
      CinematicDemoSet.experienceTech => switch (keyword) {
          'Hover' => _HoverDemo(accent: accent, business: business),
          'Parallax' => _ParallaxDemo(accent: accent, business: business),
          'Filters' => _FiltersDemo(accent: accent, business: business),
          'Transforms' => _TransformsDemo(accent: accent, business: business),
          'Motion' => _MotionDemo(accent: accent, business: business),
          _ => _HoverDemo(accent: accent, business: business),
        },
      CinematicDemoSet.proofExecution => switch (keyword) {
          'Outcomes' => _OutcomesDemo(accent: accent, label: business),
          'Systems' => _SystemsDemo(accent: accent, label: business),
          'Instrumentation' => _InstrumentationDemo(accent: accent, label: business),
          'Governance' => _GovernanceDemo(accent: accent, label: business),
          _ => _OutcomesDemo(accent: accent, label: business),
        },
      CinematicDemoSet.commission => switch (keyword) {
          'Discovery' => _DiscoveryDemo(accent: accent, label: business),
          'Prototype' => _PrototypeDemo(accent: accent, label: business),
          'Delivery' => _DeliveryDemo(accent: accent, label: business),
          'Iteration' => _IterationDemo(accent: accent, label: business),
          _ => _DiscoveryDemo(accent: accent, label: business),
        },
    };
  }
}

class _CustomNarrativeDemo extends StatefulWidget {
  const _CustomNarrativeDemo({required this.accent, required this.title, required this.items});
  final Color accent;
  final String title;
  final List<String> items;

  @override
  State<_CustomNarrativeDemo> createState() => _CustomNarrativeDemoState();
}

class _CustomNarrativeDemoState extends State<_CustomNarrativeDemo> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = ParadigmTypography.mono(context)
        .copyWith(fontSize: 9.5, letterSpacing: 2.2, color: Colors.white.withValues(alpha: 0.78), fontWeight: FontWeight.w700);
    final items = widget.items.isEmpty ? const ['Discovery → Prototype → Build → Launch → Iterate'] : widget.items;

    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = Curves.easeInOut.transform((_c.value % 1.0));
        final shimmerA = 0.06 + 0.10 * (0.5 + 0.5 * math.sin(_c.value * math.pi * 2));
        return ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              gradient: LinearGradient(
                begin: Alignment(-1.0 + t * 0.35, -0.8),
                end: Alignment(1.0 - t * 0.35, 0.8),
                colors: [
                  widget.accent.withValues(alpha: 0.12 + shimmerA),
                  Colors.white.withValues(alpha: 0.03),
                  Colors.black.withValues(alpha: 0.20),
                ],
              ),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SDLC THREAD'.toUpperCase(), style: labelStyle),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: math.min(items.length, 5),
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final localT = (t + i * 0.14) % 1.0;
                      final a = 0.10 + 0.16 * (0.5 + 0.5 * math.sin(localT * math.pi * 2));
                      return _NarrativeStepCard(accent: widget.accent, alpha: a, text: items[i]);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NarrativeStepCard extends StatelessWidget {
  const _NarrativeStepCard({required this.accent, required this.alpha, required this.text});
  final Color accent;
  final double alpha;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10 + alpha * 0.35)),
        color: Colors.black.withValues(alpha: 0.26),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent.withValues(alpha: 0.10 + alpha), Colors.white.withValues(alpha: 0.03), Colors.black.withValues(alpha: 0.18)],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: accent.withValues(alpha: 0.55 + alpha * 0.35), borderRadius: BorderRadius.circular(99)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.88), height: 1.25),
            ),
          ),
        ],
      ),
    );
  }
}

class _OutcomesDemo extends StatefulWidget {
  const _OutcomesDemo({required this.accent, required this.label});
  final Color accent;
  final String label;

  @override
  State<_OutcomesDemo> createState() => _OutcomesDemoState();
}

class _OutcomesDemoState extends State<_OutcomesDemo> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = ParadigmTypography.mono(context)
        .copyWith(fontSize: 9.5, letterSpacing: 2.2, color: Colors.white.withValues(alpha: 0.78), fontWeight: FontWeight.w700);
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_c.value);
        final a = 0.10 + 0.16 * t;
        return ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Signal preview'.toUpperCase(), style: labelStyle),
                const SizedBox(height: 10),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: _MetricCard(title: 'ACTIVATION', value: '+${(12 + 18 * t).toStringAsFixed(1)}%', accent: widget.accent, alpha: a)),
                      const SizedBox(width: 10),
                      Expanded(child: _MetricCard(title: 'RETENTION', value: '+${(6 + 14 * (1 - t)).toStringAsFixed(1)}%', accent: widget.accent, alpha: a)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(child: _MetricCard(title: 'LATENCY', value: '${(38 - 18 * t).toStringAsFixed(0)}ms', accent: widget.accent, alpha: a)),
                      const SizedBox(width: 10),
                      Expanded(child: _MetricCard(title: 'ERROR RATE', value: '${(0.9 - 0.5 * t).toStringAsFixed(2)}%', accent: widget.accent, alpha: a)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.value, required this.accent, required this.alpha});
  final String title;
  final String value;
  final Color accent;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [accent.withValues(alpha: 0.22 + alpha), Colors.white.withValues(alpha: 0.06), Colors.black.withValues(alpha: 0.40)],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title.toUpperCase(), style: ParadigmTypography.mono(context).copyWith(fontSize: 9.5, letterSpacing: 2.2, color: Colors.white.withValues(alpha: 0.78))),
            const Spacer(),
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.6, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class _SystemsDemo extends StatefulWidget {
  const _SystemsDemo({required this.accent, required this.label});
  final Color accent;
  final String label;

  @override
  State<_SystemsDemo> createState() => _SystemsDemoState();
}

class _SystemsDemoState extends State<_SystemsDemo> {
  int _active = 1;

  @override
  Widget build(BuildContext context) {
    final items = const ['ROUTES', 'TOKENS', 'DATA', 'OBSERVE', 'RELEASE'];
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.04), border: Border.all(color: Colors.white.withValues(alpha: 0.12))),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('System map'.toUpperCase(),
                style: ParadigmTypography.mono(context).copyWith(fontSize: 9.5, letterSpacing: 2.2, color: Colors.white.withValues(alpha: 0.78))),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(items.length, (i) {
                final selected = i == _active;
                return InkWell(
                  onTap: () => setState(() => _active = i),
                  splashColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: Colors.white.withValues(alpha: selected ? 0.26 : 0.14)),
                      color: widget.accent.withValues(alpha: selected ? 0.18 : 0.06),
                    ),
                    child: Text(items[i],
                        style: ParadigmTypography.mono(context).copyWith(
                          fontSize: 9.5,
                          letterSpacing: 2.0,
                          color: selected ? Colors.white : ParadigmColors.textMuted,
                          fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                        )),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 140),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: _SystemPanel(key: ValueKey(_active), accent: widget.accent, index: _active),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SystemPanel extends StatelessWidget {
  const _SystemPanel({super.key, required this.accent, required this.index});
  final Color accent;
  final int index;

  @override
  Widget build(BuildContext context) {
    final icon = switch (index) {
      0 => Icons.route_rounded,
      1 => Icons.palette_rounded,
      2 => Icons.storage_rounded,
      3 => Icons.query_stats_rounded,
      _ => Icons.rocket_launch_rounded,
    };
    final title = switch (index) {
      0 => 'Routing + hierarchy',
      1 => 'Design tokens',
      2 => 'Data contracts',
      3 => 'Observability',
      _ => 'Release pipeline',
    };
    final body = switch (index) {
      0 => 'A consistent journey graph. Nothing is “lost”.',
      1 => 'Palette, type, spacing—centralized and enforced.',
      2 => 'Typed models. Predictable payloads. No mystery fields.',
      3 => 'Events, traces, and performance marks—always on.',
      _ => 'Build, QA, deploy—repeatable and auditable.',
    };

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [accent.withValues(alpha: 0.22), Colors.white.withValues(alpha: 0.06), Colors.black.withValues(alpha: 0.35)],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: Colors.white.withValues(alpha: 0.92)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(body, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: ParadigmColors.textMuted, height: 1.5)),
          ],
        ),
      ),
    );
  }
}

class _InstrumentationDemo extends StatefulWidget {
  const _InstrumentationDemo({required this.accent, required this.label});
  final Color accent;
  final String label;

  @override
  State<_InstrumentationDemo> createState() => _InstrumentationDemoState();
}

class _InstrumentationDemoState extends State<_InstrumentationDemo> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.40), border: Border.all(color: Colors.white.withValues(alpha: 0.12))),
        padding: const EdgeInsets.all(14),
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final t = _c.value;
            final lines = List.generate(10, (i) {
              final p = (t + i * 0.12) % 1.0;
              final alpha = 0.20 + 0.60 * (1 - (p - 0.5).abs() * 2).clamp(0, 1);
              final verb = ['tap', 'hover', 'scroll', 'route', 'render'][i % 5];
              return Opacity(
                opacity: alpha,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '[event] $verb • ${(1200 + 80 * math.sin((t + i) * 6.28)).toStringAsFixed(0)}μs'.toUpperCase(),
                    style: ParadigmTypography.mono(context).copyWith(fontSize: 9.5, letterSpacing: 2.2, color: Colors.white.withValues(alpha: 0.86)),
                  ),
                ),
              );
            });
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Live event stream'.toUpperCase(),
                  style: ParadigmTypography.mono(context).copyWith(fontSize: 9.5, letterSpacing: 2.2, color: Colors.white.withValues(alpha: 0.78))),
              const SizedBox(height: 10),
              Expanded(child: SingleChildScrollView(physics: const NeverScrollableScrollPhysics(), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: lines))),
            ]);
          },
        ),
      ),
    );
  }
}

class _GovernanceDemo extends StatefulWidget {
  const _GovernanceDemo({required this.accent, required this.label});
  final Color accent;
  final String label;

  @override
  State<_GovernanceDemo> createState() => _GovernanceDemoState();
}

class _GovernanceDemoState extends State<_GovernanceDemo> {
  bool _gate = true;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.04), border: Border.all(color: Colors.white.withValues(alpha: 0.12))),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Governance gate'.toUpperCase(),
                style: ParadigmTypography.mono(context).copyWith(fontSize: 9.5, letterSpacing: 2.2, color: Colors.white.withValues(alpha: 0.78))),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [widget.accent.withValues(alpha: _gate ? 0.22 : 0.10), Colors.black.withValues(alpha: 0.35)],
                  ),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(_gate ? Icons.verified_rounded : Icons.warning_rounded, color: Colors.white.withValues(alpha: 0.92), size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _gate ? 'Checks passed. Content can ship.' : 'Gate failed. Block release.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.86), height: 1.5),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Switch.adaptive(
                      value: _gate,
                      onChanged: (v) => setState(() => _gate = v),
                      activeColor: Colors.white,
                      activeTrackColor: widget.accent.withValues(alpha: 0.55),
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.white.withValues(alpha: 0.18),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Text(
                'Governance is not a meeting. It is a switch that blocks bad states.'.toUpperCase(),
                style: ParadigmTypography.mono(context).copyWith(fontSize: 9.5, letterSpacing: 2.2, color: ParadigmColors.textFaint, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiscoveryDemo extends StatefulWidget {
  const _DiscoveryDemo({required this.accent, required this.label});
  final Color accent;
  final String label;

  @override
  State<_DiscoveryDemo> createState() => _DiscoveryDemoState();
}

class _DiscoveryDemoState extends State<_DiscoveryDemo> {
  double _signal = 0.6;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.04), border: Border.all(color: Colors.white.withValues(alpha: 0.12))),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Discovery dial'.toUpperCase(),
                style: ParadigmTypography.mono(context).copyWith(fontSize: 9.5, letterSpacing: 2.2, color: Colors.white.withValues(alpha: 0.78))),
            const SizedBox(height: 10),
            Text('Move from “nice-to-have” to “must-ship”'.toUpperCase(),
                style: ParadigmTypography.mono(context).copyWith(fontSize: 9.5, letterSpacing: 2.2, color: ParadigmColors.textMuted)),
            const SizedBox(height: 10),
            Expanded(
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: CircularProgressIndicator(
                        value: _signal,
                        strokeWidth: 6,
                        color: widget.accent.withValues(alpha: 0.95),
                        backgroundColor: Colors.white.withValues(alpha: 0.10),
                      ),
                    ),
                    Text(
                      '${(_signal * 100).toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                activeTrackColor: Colors.white,
                inactiveTrackColor: Colors.white.withValues(alpha: 0.18),
                thumbColor: Colors.white,
                overlayColor: Colors.transparent,
              ),
              child: Slider(value: _signal, onChanged: (v) => setState(() => _signal = v)),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrototypeDemo extends StatefulWidget {
  const _PrototypeDemo({required this.accent, required this.label});
  final Color accent;
  final String label;

  @override
  State<_PrototypeDemo> createState() => _PrototypeDemoState();
}

class _PrototypeDemoState extends State<_PrototypeDemo> {
  int _state = 0;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.04), border: Border.all(color: Colors.white.withValues(alpha: 0.12))),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Prototype states'.toUpperCase(),
                style: ParadigmTypography.mono(context).copyWith(fontSize: 9.5, letterSpacing: 2.2, color: Colors.white.withValues(alpha: 0.78))),
            const SizedBox(height: 10),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _state = (_state + 1) % 3),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 140),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(position: Tween(begin: const Offset(0, 0.04), end: Offset.zero).animate(anim), child: child),
                  ),
                  child: _PrototypeFrame(key: ValueKey(_state), accent: widget.accent, state: _state),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text('Tap to cycle: layout → motion → CTA'.toUpperCase(),
                style: ParadigmTypography.mono(context).copyWith(fontSize: 9.5, letterSpacing: 2.2, color: ParadigmColors.textFaint)),
          ],
        ),
      ),
    );
  }
}

class _PrototypeFrame extends StatelessWidget {
  const _PrototypeFrame({super.key, required this.accent, required this.state});
  final Color accent;
  final int state;

  @override
  Widget build(BuildContext context) {
    final label = switch (state) { 0 => 'WIREFRAME', 1 => 'MOTION PASS', _ => 'CTA STATE' };
    final icon = switch (state) { 0 => Icons.grid_view_rounded, 1 => Icons.motion_photos_on_rounded, _ => Icons.ads_click_rounded };
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [accent.withValues(alpha: 0.20 + 0.06 * state), Colors.black.withValues(alpha: 0.40)]),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(icon, size: 18, color: Colors.white.withValues(alpha: 0.92)), const SizedBox(width: 10), Text(label, style: ParadigmTypography.mono(context).copyWith(fontSize: 10, letterSpacing: 2.6, color: Colors.white))]),
            const Spacer(),
            Align(
              alignment: Alignment.bottomLeft,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  color: state == 2 ? Colors.white : Colors.transparent,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_outward_rounded, size: 18, color: state == 2 ? Colors.black : Colors.white),
                    const SizedBox(width: 10),
                    Text('VIEW'.toUpperCase(), style: ParadigmTypography.mono(context).copyWith(fontSize: 10, letterSpacing: 2.4, fontWeight: FontWeight.w800, color: state == 2 ? Colors.black : Colors.white)),
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

class _DeliveryDemo extends StatefulWidget {
  const _DeliveryDemo({required this.accent, required this.label});
  final Color accent;
  final String label;

  @override
  State<_DeliveryDemo> createState() => _DeliveryDemoState();
}

class _DeliveryDemoState extends State<_DeliveryDemo> {
  double _progress = 0.25;

  @override
  Widget build(BuildContext context) {
    final stages = const ['BUILD', 'QA', 'PERF', 'LAUNCH'];
    final idx = (_progress * (stages.length - 1)).round().clamp(0, stages.length - 1);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.04), border: Border.all(color: Colors.white.withValues(alpha: 0.12))),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Delivery pipeline'.toUpperCase(),
                style: ParadigmTypography.mono(context).copyWith(fontSize: 9.5, letterSpacing: 2.2, color: Colors.white.withValues(alpha: 0.78))),
            const SizedBox(height: 12),
            Row(
              children: List.generate(stages.length, (i) {
                final active = i <= idx;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i == stages.length - 1 ? 0 : 8),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: active ? widget.accent.withValues(alpha: 0.85) : Colors.white.withValues(alpha: 0.10),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            Text(
              stages[idx],
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, color: Colors.white),
            ),
            const Spacer(),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                activeTrackColor: Colors.white,
                inactiveTrackColor: Colors.white.withValues(alpha: 0.18),
                thumbColor: Colors.white,
                overlayColor: Colors.transparent,
              ),
              child: Slider(value: _progress, onChanged: (v) => setState(() => _progress = v)),
            ),
          ],
        ),
      ),
    );
  }
}

class _IterationDemo extends StatefulWidget {
  const _IterationDemo({required this.accent, required this.label});
  final Color accent;
  final String label;

  @override
  State<_IterationDemo> createState() => _IterationDemoState();
}

class _IterationDemoState extends State<_IterationDemo> {
  bool _variantA = true;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.04), border: Border.all(color: Colors.white.withValues(alpha: 0.12))),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Iteration toggle'.toUpperCase(),
                style: ParadigmTypography.mono(context).copyWith(fontSize: 9.5, letterSpacing: 2.2, color: Colors.white.withValues(alpha: 0.78))),
            const SizedBox(height: 12),
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [widget.accent.withValues(alpha: _variantA ? 0.22 : 0.14), Colors.black.withValues(alpha: 0.40)],
                  ),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_variantA ? 'Variant A' : 'Variant B',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, color: Colors.white)),
                    const SizedBox(height: 8),
                    Text(
                      _variantA ? 'Higher clarity. Lower visual noise.' : 'Higher energy. More motion.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: ParadigmColors.textMuted, height: 1.5),
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: InkWell(
                        onTap: () => setState(() => _variantA = !_variantA),
                        splashColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            color: Colors.white,
                            border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.swap_horiz_rounded, size: 18, color: Colors.black),
                              const SizedBox(width: 10),
                              Text('Swap'.toUpperCase(),
                                  style: ParadigmTypography.mono(context)
                                      .copyWith(fontSize: 10, letterSpacing: 2.4, fontWeight: FontWeight.w800, color: Colors.black)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text('Iteration is a switch, not a rewrite.'.toUpperCase(),
                style: ParadigmTypography.mono(context).copyWith(fontSize: 9.5, letterSpacing: 2.2, color: ParadigmColors.textFaint)),
          ],
        ),
      ),
    );
  }
}

class _HoverDemo extends StatefulWidget {
  const _HoverDemo({required this.accent, required this.business});
  final Color accent;
  final String business;

  @override
  State<_HoverDemo> createState() => _HoverDemoState();
}

class _HoverDemoState extends State<_HoverDemo> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = _hover ? 1.0 : 0.0;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: Colors.white.withValues(alpha: 0.14 + 0.10 * t)),
          color: widget.accent.withValues(alpha: 0.08 + 0.08 * t),
        ),
        child: Center(
          child: Transform.scale(
            scale: 1 + 0.03 * t,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.pets_rounded, color: Colors.white.withValues(alpha: 0.92), size: 26),
                const SizedBox(height: 10),
                Text(
                  widget.business,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Hover to preview CTA state',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: ParadigmColors.textMuted),
                ),
                const SizedBox(height: 12),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    color: _hover ? Colors.white : Colors.transparent,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_outward_rounded, size: 18, color: _hover ? Colors.black : Colors.white),
                      const SizedBox(width: 10),
                      Text(
                        'Book a slot'.toUpperCase(),
                        style: ParadigmTypography.mono(context).copyWith(
                          fontSize: 10,
                          letterSpacing: 2.4,
                          fontWeight: FontWeight.w800,
                          color: _hover ? Colors.black : Colors.white,
                        ),
                      ),
                    ],
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

class _ParallaxDemo extends StatefulWidget {
  const _ParallaxDemo({required this.accent, required this.business});
  final Color accent;
  final String business;

  @override
  State<_ParallaxDemo> createState() => _ParallaxDemoState();
}

class _ParallaxDemoState extends State<_ParallaxDemo> {
  Offset _p = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        return MouseRegion(
          onHover: (e) {
            final box = context.findRenderObject();
            if (box is! RenderBox) return;
            final local = box.globalToLocal(e.position);
            final nx = (local.dx / c.maxWidth) * 2 - 1;
            final ny = (local.dy / c.maxHeight) * 2 - 1;
            setState(() => _p = Offset(nx.clamp(-1, 1), ny.clamp(-1, 1)));
          },
          onExit: (_) => setState(() => _p = Offset.zero),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Stack(
              fit: StackFit.expand,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(-0.8 + _p.dx * 0.15, -0.7 + _p.dy * 0.12),
                      end: Alignment(0.8 - _p.dx * 0.15, 0.7 - _p.dy * 0.12),
                      colors: [
                        Colors.white.withValues(alpha: 0.08),
                        widget.accent.withValues(alpha: 0.20),
                        Colors.black.withValues(alpha: 0.40),
                      ],
                    ),
                  ),
                ),
                Transform.translate(
                  offset: Offset(_p.dx * 12, _p.dy * 10),
                  child: Align(
                    alignment: Alignment.center,
                    child: Icon(Icons.public_rounded, color: Colors.white.withValues(alpha: 0.18), size: 140),
                  ),
                ),
                Transform.translate(
                  offset: Offset(_p.dx * 22, _p.dy * 18),
                  child: Align(
                    alignment: const Alignment(0.2, -0.2),
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.accent.withValues(alpha: 0.22),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Move cursor to shift depth'.toUpperCase(),
                        style: ParadigmTypography.mono(context).copyWith(fontSize: 9.5, letterSpacing: 2.2, color: Colors.white.withValues(alpha: 0.78)),
                      ),
                      const Spacer(),
                      Text(
                        widget.business,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FiltersDemo extends StatefulWidget {
  const _FiltersDemo({required this.accent, required this.business});
  final Color accent;
  final String business;

  @override
  State<_FiltersDemo> createState() => _FiltersDemoState();
}

class _FiltersDemoState extends State<_FiltersDemo> {
  double _t = 0.35;

  List<double> _saturationMatrix(double saturation) {
    // Standard saturation matrix.
    final inv = 1 - saturation;
    final r = 0.213 * inv;
    final g = 0.715 * inv;
    final b = 0.072 * inv;
    return [
      r + saturation, g, b, 0, 0,
      r, g + saturation, b, 0, 0,
      r, g, b + saturation, 0, 0,
      0, 0, 0, 1, 0,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final sat = 0.15 + (_t * 1.35);
    final blur = 0.0 + (_t * 6.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColorFiltered(
            colorFilter: ColorFilter.matrix(_saturationMatrix(sat)),
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.accent.withValues(alpha: 0.45),
                      Colors.white.withValues(alpha: 0.10),
                      Colors.black.withValues(alpha: 0.60),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.business,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  'Adjust filter intensity'.toUpperCase(),
                  style: ParadigmTypography.mono(context).copyWith(fontSize: 9.5, letterSpacing: 2.2, color: Colors.white.withValues(alpha: 0.78)),
                ),
                const Spacer(),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                    activeTrackColor: Colors.white,
                    inactiveTrackColor: Colors.white.withValues(alpha: 0.18),
                    thumbColor: Colors.white,
                    overlayColor: Colors.transparent,
                  ),
                  child: Slider(
                    value: _t,
                    onChanged: (v) => setState(() => _t = v),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TransformsDemo extends StatefulWidget {
  const _TransformsDemo({required this.accent, required this.business});
  final Color accent;
  final String business;

  @override
  State<_TransformsDemo> createState() => _TransformsDemoState();
}

class _TransformsDemoState extends State<_TransformsDemo> {
  double _t = 0.25;

  @override
  Widget build(BuildContext context) {
    final angle = (_t - 0.5) * 0.9;
    final scale = 0.92 + _t * 0.22;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.business,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, color: Colors.white),
              ),
              const SizedBox(height: 6),
              Text(
                'Transform the badge'.toUpperCase(),
                style: ParadigmTypography.mono(context).copyWith(fontSize: 9.5, letterSpacing: 2.2, color: ParadigmColors.textMuted),
              ),
              const Spacer(),
              Center(
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateZ(angle)..scale(scale),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      color: widget.accent.withValues(alpha: 0.18),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome_mosaic_rounded, size: 18, color: Colors.white.withValues(alpha: 0.92)),
                        const SizedBox(width: 10),
                        Text(
                          'PRIMARY'.toUpperCase(),
                          style: ParadigmTypography.mono(context).copyWith(fontSize: 10, letterSpacing: 2.6, color: Colors.white, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Spacer(),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                  activeTrackColor: Colors.white,
                  inactiveTrackColor: Colors.white.withValues(alpha: 0.18),
                  thumbColor: Colors.white,
                  overlayColor: Colors.transparent,
                ),
                child: Slider(value: _t, onChanged: (v) => setState(() => _t = v)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MotionDemo extends StatefulWidget {
  const _MotionDemo({required this.accent, required this.business});
  final Color accent;
  final String business;

  @override
  State<_MotionDemo> createState() => _MotionDemoState();
}

class _MotionDemoState extends State<_MotionDemo> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.business,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, color: Colors.white),
            ),
            const SizedBox(height: 6),
            Text(
              'Micro-motion (low amplitude)'.toUpperCase(),
              style: ParadigmTypography.mono(context).copyWith(fontSize: 9.5, letterSpacing: 2.2, color: ParadigmColors.textMuted),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: _c,
                  builder: (context, _) {
                    final t = Curves.easeInOut.transform(_c.value);
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 220,
                          height: 2,
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(999)),
                          child: Align(
                            alignment: Alignment(-1 + 2 * t, 0),
                            child: Container(
                              width: 70,
                              height: 2,
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Transform.translate(
                          offset: Offset(0, -2 + 4 * (1 - t)),
                          child: Icon(Icons.play_arrow_rounded, color: widget.accent.withValues(alpha: 0.95), size: 42),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            Text(
              'Motion is readable when everything else is quiet.'.toUpperCase(),
              style: ParadigmTypography.mono(context).copyWith(fontSize: 9.5, letterSpacing: 2.2, color: ParadigmColors.textFaint),
            ),
          ],
        ),
      ),
    );
  }
}

class _CinematicAction extends StatelessWidget {
  const _CinematicAction({required this.label, required this.accent, required this.hover, required this.onTap});

  final String label;
  final Color accent;
  final bool hover;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = hover ? Colors.black : Colors.white;
    final bg = hover ? Colors.white : Colors.transparent;
    final border = BorderSide(color: Colors.white.withValues(alpha: hover ? 0.22 : 0.14));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: bg,
        border: Border.fromBorderSide(border),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.play_arrow_rounded, color: fg, size: 18),
              const SizedBox(width: 10),
              Text(
                label,
                style: ParadigmTypography.mono(context).copyWith(
                  fontSize: 11,
                  letterSpacing: 2.6,
                  color: fg,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 12),
              Container(width: 18, height: 2, color: accent.withValues(alpha: hover ? 0.9 : 0.55)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MotifField extends StatelessWidget {
  const _MotifField({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final h = c.maxHeight;
        final count = math.max(10, (w * h / 32000).round());
        return Stack(
          children: List.generate(count, (i) {
            final t = i / count;
            final dx = (math.sin(t * math.pi * 6.0) * 0.5 + 0.5) * (w - 40);
            final dy = (math.cos(t * math.pi * 5.0 + 1.1) * 0.5 + 0.5) * (h - 40);
            final size = 16.0 + (i % 4) * 6.0;
            final alpha = 0.08 + (i % 5) * 0.02;
            final color = accent.withValues(alpha: alpha);
            return Positioned(
              left: dx,
              top: dy,
              child: Transform.rotate(
                angle: (i % 7) * 0.22,
                child: ParadigmPixelMotif(keyword: 'm$i', size: size, color: color),
              ),
            );
          }),
        );
      },
    );
  }
}
