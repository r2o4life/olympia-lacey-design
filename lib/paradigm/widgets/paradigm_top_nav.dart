import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:parallel_paradigm_org/theme.dart';

/// Responsive top navigation used across the Paradigm experience.
///
/// Designed to avoid Row overflows on narrow phones while keeping the
/// “elite-agency” typographic treatment.
class ParadigmTopNav extends StatelessWidget {
  const ParadigmTopNav({
    super.key,
    required this.left,
    required this.right,
    this.padding,
    this.background = ParadigmColors.panel,
    this.showBottomBorder = true,
  });

  final Widget left;
  final Widget right;
  final EdgeInsets? padding;
  final Color background;
  final bool showBottomBorder;

  static EdgeInsets defaultPaddingFor(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final base = w < 420 ? AppSpacing.lg : AppSpacing.xl;
    return EdgeInsets.all(base);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? defaultPaddingFor(context),
      decoration: BoxDecoration(
        color: background,
        border: showBottomBorder ? Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08))) : null,
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final compact = c.maxWidth < 520;
          if (!compact) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [left, right],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(alignment: Alignment.centerLeft, child: left),
              const SizedBox(height: 12),
              Align(alignment: Alignment.centerRight, child: right),
            ],
          );
        },
      ),
    );
  }
}

/// Brand lockup for the top navigation: icon mark + word mark + optional tagline.
///
/// This keeps the “Parallel Paradigm” word mark present while remaining
/// responsive on narrow/touch form factors.
class ParadigmBrandLockup extends StatelessWidget {
  const ParadigmBrandLockup({
    super.key,
    this.tagline = 'Olympia Lacey Design • Parallel Paradigm',
    this.logoAssetPath = 'assets/images/Logo_Parallel_Paradigm_White.svg',
  });

  final String logoAssetPath;
  final String? tagline;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final isCompact = w < 420;
    final logoHeight = isCompact ? 18.0 : 20.0;

    final wordMarkStyle = ParadigmTypography.mono(context).copyWith(
      fontSize: isCompact ? 12 : 13,
      letterSpacing: isCompact ? 2.0 : 2.4,
      height: 1.1,
      color: Colors.white,
      fontWeight: FontWeight.w600,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              logoAssetPath,
              height: logoHeight,
              width: logoHeight,
              fit: BoxFit.contain,
              alignment: Alignment.centerLeft,
              // Force white in case the SVG contains non-white fills.
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              semanticsLabel: 'Olympia Lacey Design, Parallel Paradigm',
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                'OLYMPIA LACEY DESIGN',
                maxLines: isCompact ? 2 : 1,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                style: wordMarkStyle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'PARALLEL PARADIGM',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: ParadigmTypography.mono(context).copyWith(
            fontSize: 10,
            letterSpacing: 2.6,
            color: ParadigmColors.textFaint,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (tagline != null) ...[
          const SizedBox(height: 6),
          Text(
            tagline!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ParadigmTypography.mono(context).copyWith(
              fontSize: 10,
              letterSpacing: 2.6,
              color: ParadigmColors.textFaint,
            ),
          ),
        ],
      ],
    );
  }
}

/// Standardized top-nav action item used on the right side of the top bar.
///
/// This intentionally reserves a second-line height (even when [subtitle] is
/// empty) so sibling items stay vertically aligned across pages.
class ParadigmTopNavAction extends StatelessWidget {
  const ParadigmTopNavAction({
    super.key,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.alignEnd = false,
    this.bright = true,
  });

  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final bool alignEnd;
  final bool bright;

  @override
  Widget build(BuildContext context) {
    final subtitleStyle = ParadigmTypography.mono(context).copyWith(
      fontSize: 10,
      letterSpacing: 2.6,
      color: ParadigmColors.textFaint,
    );

    return InkWell(
      onTap: onTap,
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Column(
          crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label.toUpperCase(),
              style: ParadigmTypography.mono(context).copyWith(
                fontSize: 11,
                letterSpacing: 3.2,
                color: bright ? Colors.white : ParadigmColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            // Reserve the second-line height so the top labels stay aligned.
            Text(subtitle ?? '', style: subtitleStyle),
          ],
        ),
      ),
    );
  }
}

/// Mobile-friendly “edge swipe to go back” gesture.
///
/// Enabled on iOS/Android touch form factors; ignored on web/desktop.
class EdgeSwipeBack extends StatefulWidget {
  const EdgeSwipeBack({super.key, required this.child, required this.onBack});

  final Widget child;
  final VoidCallback onBack;

  @override
  State<EdgeSwipeBack> createState() => _EdgeSwipeBackState();
}

class _EdgeSwipeBackState extends State<EdgeSwipeBack> {
  Offset? _start;
  double _dx = 0;

  bool get _enabled {
    if (kIsWeb) return false;
    return switch (defaultTargetPlatform) {
      TargetPlatform.iOS || TargetPlatform.android => true,
      _ => false,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (!_enabled) return widget.child;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: (d) {
        _start = d.localPosition;
        _dx = 0;
      },
      onHorizontalDragUpdate: (d) {
        if (_start == null) return;
        // Only start tracking if gesture begins close to left edge.
        if (_start!.dx > 28) return;

        _dx += d.delta.dx;
        // Guard against vertical scroll gestures.
        if (d.delta.dy.abs() > d.delta.dx.abs()) return;
        if (_dx > 70) {
          _start = null;
          widget.onBack();
        }
      },
      onHorizontalDragEnd: (_) {
        _start = null;
        _dx = 0;
      },
      child: widget.child,
    );
  }
}
