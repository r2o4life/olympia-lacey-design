import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:parallel_paradigm_org/theme.dart';

/// A compact "pixel motif" used as a consistent visual language for key concepts.
///
/// It renders a deterministic micro-grid based on [keyword], making each keyword
/// feel like a "node" with its own signature.
class ParadigmPixelMotif extends StatelessWidget {
  const ParadigmPixelMotif({super.key, required this.keyword, this.color, this.size = 20});

  final String keyword;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = color ?? ParadigmKeywordPalette.colorFor(keyword);
    return CustomPaint(size: Size.square(size), painter: _PixelMotifPainter(keyword: keyword, color: c));
  }
}

class ParadigmKeywordChip extends StatefulWidget {
  const ParadigmKeywordChip({super.key, required this.keyword, this.onTap});

  final String keyword;
  final VoidCallback? onTap;

  @override
  State<ParadigmKeywordChip> createState() => _ParadigmKeywordChipState();
}

class _ParadigmKeywordChipState extends State<ParadigmKeywordChip> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final color = ParadigmKeywordPalette.colorFor(widget.keyword);
    final border = BorderSide(color: Colors.white.withValues(alpha: _hover ? 0.22 : 0.14));
    final fill = color.withValues(alpha: _hover ? 0.12 : 0.08);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.fromBorderSide(border),
          color: fill,
        ),
        child: InkWell(
          onTap: widget.onTap,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ParadigmPixelMotif(keyword: widget.keyword, size: 18, color: color),
                const SizedBox(width: 10),
                Text(
                  widget.keyword.toUpperCase(),
                  style: ParadigmTypography.mono(context).copyWith(
                    fontSize: 10,
                    letterSpacing: 2.2,
                    color: Colors.white.withValues(alpha: 0.92),
                    fontWeight: FontWeight.w600,
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

class ParadigmKeywordPalette {
  static Color colorFor(String keyword) {
    final k = keyword.toLowerCase();
    if (k.contains('growth')) return ParadigmColors.accentCyan;
    if (k.contains('monet')) return ParadigmColors.accentAmber;
    if (k.contains('govern')) return ParadigmColors.accentViolet;
    if (k.contains('secur')) return ParadigmColors.accentRose;
    if (k.contains('engage')) return ParadigmColors.accentLime;
    return ParadigmColors.accentCyan;
  }
}

class _PixelMotifPainter extends CustomPainter {
  _PixelMotifPainter({required this.keyword, required this.color});

  final String keyword;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final base = Paint()..color = Colors.white.withValues(alpha: 0.12);
    final on = Paint()..color = color.withValues(alpha: 0.92);
    final glow = Paint()..color = color.withValues(alpha: 0.18);

    const grid = 6;
    final cell = size.width / grid;

    final seed = _stableHash(keyword);
    final rng = math.Random(seed);

    // Background lattice.
    for (int y = 0; y < grid; y++) {
      for (int x = 0; x < grid; x++) {
        final rect = Rect.fromLTWH(x * cell + 0.5, y * cell + 0.5, cell - 1, cell - 1);
        canvas.drawRect(rect, base);
      }
    }

    // Deterministic "constellation".
    final hits = 10 + rng.nextInt(6);
    for (int i = 0; i < hits; i++) {
      final x = rng.nextInt(grid);
      final y = rng.nextInt(grid);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x * cell + 0.8, y * cell + 0.8, cell - 1.6, cell - 1.6),
        const Radius.circular(2),
      );
      canvas.drawRRect(rect, glow);
      canvas.drawRRect(rect, on);
    }
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
  bool shouldRepaint(covariant _PixelMotifPainter oldDelegate) => oldDelegate.keyword != keyword || oldDelegate.color != color;
}
