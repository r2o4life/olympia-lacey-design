import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A subtle, case-study–aware background artifact that conveys “what world we’re in”.
///
/// Why this exists: the previous large pixel/checker motif reads as decorative UI,
/// not as an ontology of the phenomenon described by the case study.
///
/// This widget renders a low-contrast, animated diagram layer that varies by
/// [projectId] while staying consistent with the overall Paradigm aesthetic.
class ParadigmOntologyBackdrop extends StatefulWidget {
  const ParadigmOntologyBackdrop({
    super.key,
    required this.projectId,
    required this.keyword,
    required this.accent,
    this.opacity = 0.22,
    this.complexity,
  });

  /// Known values in this repo include: `tipzero`, `bridge`.
  final String projectId;

  /// Used to make the diagram deterministic per objective.
  final String keyword;

  /// Accent tint for the diagram layer.
  final Color accent;

  /// Overall opacity multiplier.
  final double opacity;

  /// Optional hint to reduce paint complexity on very small viewports.
  /// If null, complexity auto-scales by canvas size.
  final double? complexity;

  @override
  State<ParadigmOntologyBackdrop> createState() => _ParadigmOntologyBackdropState();
}

class _ParadigmOntologyBackdropState extends State<ParadigmOntologyBackdrop> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 18))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _OntologyBackdropPainter(
              projectId: widget.projectId,
              keyword: widget.keyword,
              accent: widget.accent,
              t: _controller.value,
              opacity: widget.opacity,
              complexity: widget.complexity,
            ),
          );
        },
      ),
    );
  }
}

class _OntologyBackdropPainter extends CustomPainter {
  _OntologyBackdropPainter({required this.projectId, required this.keyword, required this.accent, required this.t, required this.opacity, required this.complexity});

  final String projectId;
  final String keyword;
  final Color accent;
  final double t;
  final double opacity;
  final double? complexity;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final isTipZero = projectId.toLowerCase().contains('tip');
    final isBridge = projectId.toLowerCase().contains('bridge');

    final seed = _stableHash('$projectId::$keyword');
    final rng = math.Random(seed);

    // Complexity factor: 1.0 = full detail, lower = fewer primitives.
    final autoComplexity = (size.shortestSide / 760).clamp(0.62, 1.0);
    final c = (complexity ?? autoComplexity).clamp(0.55, 1.0);

    // Global drift to make it feel alive but not distracting.
    final dx = math.sin(t * math.pi * 2) * 10;
    final dy = math.cos(t * math.pi * 2) * 8;
    canvas.translate(dx, dy);

    final baseStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.08 * opacity);

    final accentStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = accent.withValues(alpha: 0.18 * opacity);

    final glowStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..color = accent.withValues(alpha: 0.08 * opacity);

    final haloStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..color = accent.withValues(alpha: 0.05 * opacity);

    final dot = Paint()..color = Colors.white.withValues(alpha: 0.10 * opacity);
    final accentDot = Paint()..color = accent.withValues(alpha: 0.20 * opacity);

    // A faint field of “stars” so the layer doesn't look like a flat pattern.
    final stars = (42 * c).round().clamp(18, 42);
    for (int i = 0; i < stars; i++) {
      final p = Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height);
      final r = (rng.nextDouble() * 1.3) + 0.4;
      canvas.drawCircle(p, r, dot);
    }

    if (isTipZero) {
      _paintTipZero(canvas, size, rng, baseStroke, accentStroke, glowStroke, haloStroke, accentDot);
    } else if (isBridge) {
      _paintBridge(canvas, size, rng, baseStroke, accentStroke, glowStroke, haloStroke, accentDot);
    } else {
      _paintGeneric(canvas, size, rng, baseStroke, accentStroke, glowStroke, haloStroke, accentDot);
    }
  }

  void _paintTipZero(
    Canvas canvas,
    Size size,
    math.Random rng,
    Paint baseStroke,
    Paint accentStroke,
    Paint glowStroke,
    Paint haloStroke,
    Paint accentDot,
  ) {
    // TIPZERO = “checkout physiology”: flow lines + nodes + token pulses.
    // Visual metaphor: a set of parallel rails (POS → user → worker) with
    // liquidity/token nodes interleaving.
    final lanes = (5 * (complexity ?? 1.0)).round().clamp(3, 5);
    final top = size.height * 0.16;
    final bottom = size.height * 0.88;
    final laneGap = (bottom - top) / (lanes - 1);

    for (int i = 0; i < lanes; i++) {
      final y = top + laneGap * i;
      final path = Path();
      path.moveTo(-24, y);
      final cp1 = Offset(size.width * 0.28, y + (rng.nextDouble() - 0.5) * 40);
      final cp2 = Offset(size.width * 0.62, y + (rng.nextDouble() - 0.5) * 40);
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, size.width + 24, y);
      canvas.drawPath(path, baseStroke);

      // Accented “pulse segment” to hint at value movement.
      final segStart = size.width * (0.18 + rng.nextDouble() * 0.18);
      final segEnd = segStart + size.width * (0.16 + rng.nextDouble() * 0.12);
      final pulse = Path();
      pulse.moveTo(segStart, y);
      pulse.cubicTo(segStart + 40, y - 12, segEnd - 40, y + 12, segEnd, y);
      canvas.drawPath(pulse, glowStroke);
      canvas.drawPath(pulse, accentStroke);

      // Nodes on each lane.
      final nodes = (4 + rng.nextInt(3));
      for (int n = 0; n < nodes; n++) {
        final x = size.width * (0.10 + rng.nextDouble() * 0.82);
        final r = 3.0 + rng.nextDouble() * 3.2;
        canvas.drawCircle(Offset(x, y), r, accentDot);
        canvas.drawCircle(Offset(x, y), r + 8, haloStroke);
        canvas.drawCircle(Offset(x, y), r + 4, glowStroke);
      }
    }

    // Token glyphs (small rounded squares) that read like “units”.
    final tokens = (10 * (complexity ?? 1.0)).round().clamp(5, 10);
    for (int i = 0; i < tokens; i++) {
      final center = Offset(size.width * (0.12 + rng.nextDouble() * 0.76), size.height * (0.18 + rng.nextDouble() * 0.70));
      final s = 10.0 + rng.nextDouble() * 16;
      final rect = RRect.fromRectAndRadius(Rect.fromCenter(center: center, width: s, height: s), const Radius.circular(4));
      canvas.drawRRect(rect, baseStroke);
      if (i.isEven) canvas.drawRRect(rect, accentStroke);
    }
  }

  void _paintBridge(
    Canvas canvas,
    Size size,
    math.Random rng,
    Paint baseStroke,
    Paint accentStroke,
    Paint glowStroke,
    Paint haloStroke,
    Paint accentDot,
  ) {
    // BRIDGEBOUND = “feedback loop bridge”: hubs + links + message capsules.
    // Visual metaphor: families, teachers, students, district — connected by
    // lightweight signals.
    final hubs = <Offset>[
      Offset(size.width * 0.22, size.height * 0.32),
      Offset(size.width * 0.48, size.height * 0.56),
      Offset(size.width * 0.76, size.height * 0.28),
      Offset(size.width * 0.70, size.height * 0.76),
    ];

    for (final h in hubs) {
      canvas.drawCircle(h, 6.5, accentDot);
      canvas.drawCircle(h, 22, haloStroke);
      canvas.drawCircle(h, 16, glowStroke);
    }

    // Links between hubs.
    for (int i = 0; i < hubs.length; i++) {
      for (int j = i + 1; j < hubs.length; j++) {
        if (rng.nextDouble() < 0.35) continue;
        final a = hubs[i];
        final b = hubs[j];
        final mid = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2 + (rng.nextDouble() - 0.5) * 40);
        final path = Path()..moveTo(a.dx, a.dy);
        path.quadraticBezierTo(mid.dx, mid.dy, b.dx, b.dy);
        canvas.drawPath(path, baseStroke);
        if ((i + j).isEven) canvas.drawPath(path, accentStroke);
      }
    }

    // Satellite nodes around hubs.
    for (final h in hubs) {
      final satellites = 7 + rng.nextInt(6);
      for (int s = 0; s < satellites; s++) {
        final angle = rng.nextDouble() * math.pi * 2;
        final dist = 40 + rng.nextDouble() * 90;
        final p = Offset(h.dx + math.cos(angle) * dist, h.dy + math.sin(angle) * dist);
        if (p.dx < 0 || p.dy < 0 || p.dx > size.width || p.dy > size.height) continue;
        canvas.drawCircle(p, 3.0, accentDot);
        final path = Path()..moveTo(h.dx, h.dy);
        path.quadraticBezierTo((h.dx + p.dx) / 2, (h.dy + p.dy) / 2, p.dx, p.dy);
        canvas.drawPath(path, baseStroke);
      }
    }

    // Message capsules: represent “signals” traveling.
    final capsules = (9 * (complexity ?? 1.0)).round().clamp(4, 9);
    for (int i = 0; i < capsules; i++) {
      final center = Offset(size.width * (0.10 + rng.nextDouble() * 0.84), size.height * (0.14 + rng.nextDouble() * 0.76));
      final w = 26 + rng.nextDouble() * 42;
      final h = 12 + rng.nextDouble() * 10;
      final rect = RRect.fromRectAndRadius(Rect.fromCenter(center: center, width: w, height: h), const Radius.circular(999));
      canvas.drawRRect(rect, baseStroke);
      if (i % 3 == 0) canvas.drawRRect(rect, accentStroke);
    }
  }

  void _paintGeneric(
    Canvas canvas,
    Size size,
    math.Random rng,
    Paint baseStroke,
    Paint accentStroke,
    Paint glowStroke,
    Paint haloStroke,
    Paint accentDot,
  ) {
    // Fallback: a sparse constellation so the UI still feels alive.
    final pts = List.generate(18, (_) => Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height), growable: false);
    for (int i = 0; i < pts.length; i++) {
      final p = pts[i];
      canvas.drawCircle(p, 3.5, accentDot);
      if (i > 0) canvas.drawLine(pts[i - 1], p, i.isEven ? accentStroke : baseStroke);
    }

    final halo = Rect.fromCircle(center: Offset(size.width * 0.6, size.height * 0.4), radius: size.shortestSide * 0.38);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [accent.withValues(alpha: 0.10 * opacity), Colors.transparent],
        stops: const [0, 1],
      ).createShader(halo);
    canvas.drawRect(Offset.zero & size, paint);
    canvas.drawCircle(Offset(size.width * 0.6, size.height * 0.4), size.shortestSide * 0.35, haloStroke);
    canvas.drawCircle(Offset(size.width * 0.6, size.height * 0.4), size.shortestSide * 0.30, glowStroke);
  }

  int _stableHash(String s) {
    // FNV-1a 32-bit.
    const int prime = 0x01000193;
    int hash = 0x811C9DC5;
    for (final code in s.codeUnits) {
      hash ^= code;
      hash = (hash * prime) & 0xFFFFFFFF;
    }
    return hash;
  }

  @override
  bool shouldRepaint(covariant _OntologyBackdropPainter oldDelegate) {
    return oldDelegate.projectId != projectId ||
        oldDelegate.keyword != keyword ||
        oldDelegate.accent != accent ||
        oldDelegate.t != t ||
        oldDelegate.opacity != opacity ||
        oldDelegate.complexity != complexity;
  }
}
