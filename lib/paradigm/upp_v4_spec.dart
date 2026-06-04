import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:parallel_paradigm_org/paradigm/cinematic_tile_art.dart';

/// Universal Prompt Protocol v4 (UPP v4)
///
/// Repo-persisted spec + a small deterministic “artifact generator” used to
/// render higher-signal visuals (without network calls / image assets) for
/// large viewport tiles.
///
/// Why this exists:
/// - Make visual decisions reproducible (same input -> same output)
/// - Allow multi-viewport orchestration (compact vs wide)
/// - Produce “render artifacts” by composing existing primitives (gradients,
///   motifs, vignettes, sheen) rather than introducing new dependencies
///
/// Note: this file intentionally focuses on *render orchestration* rather than
/// full natural-language prompt plumbing.
class UppV4Engine {
  const UppV4Engine();

  /// Generates protocol-driven render artifacts for a home (Vanguard) tile.
  ///
  /// This is deliberately deterministic:
  /// - `tileId` is the stable seed input
  /// - `accent` is the brand accent for CTA + chip system
  /// - `viewportWidth` gates density, sheen, and gradient complexity
  CinematicTileArt homeTileArtifacts({required String tileId, required Color accent, required double viewportWidth}) {
    final seed = _stableSeed(tileId);
    final r = math.Random(seed);

    final wide = viewportWidth >= 980;
    final ultraWide = viewportWidth >= 1240;

    // Secondary highlight is derived from accent but shifted subtly so each tile
    // can carry a distinct “chromatic fill” even when accents are similar.
    final secondary = _shiftHue(accent, degrees: r.nextBool() ? 22 : -18).withValues(alpha: 1.0);

    // Protocol: multi-stop gradient mapping. We keep the final stop anchored to
    // near-black for text legibility.
    final gradient = <Color>[
      Colors.white.withValues(alpha: wide ? 0.06 : 0.04),
      Color.lerp(accent, secondary, 0.45)!.withValues(alpha: wide ? 0.18 : 0.12),
      secondary.withValues(alpha: wide ? 0.10 : 0.07),
      Colors.black.withValues(alpha: 0.66),
    ];

    final stops = <double>[0.0, wide ? 0.42 : 0.50, wide ? 0.70 : 0.68, 1.0];

    // Protocol: density orchestration.
    final density = ultraWide
        ? 1.40
        : wide
            ? 1.15
            : 0.95;

    // Protocol: sheen and vignette are slightly dialed up on wide viewports.
    final sheen = wide ? 0.12 : 0.10;
    final vignette = wide ? 0.18 : 0.14;

    return CinematicTileArt(
      seed: seed,
      gradientColors: gradient,
      gradientStops: stops,
      motifDensity: density,
      motifMinAlpha: wide ? 0.06 : 0.05,
      motifMaxAlpha: wide ? 0.16 : 0.13,
      sheenBase: sheen,
      vignetteStrength: vignette,
    );
  }

  /// BridgeBound-specific artifacts.
  ///
  /// Protocol intent:
  /// - “Bridge” semantics: connective tissue, signal routing, trust boundaries
  /// - Higher contrast readability (education + family context tends to carry
  ///   longer narrative copy)
  /// - A deterministic network overlay (nodes + connecting arcs) that reads as
  ///   coordination infrastructure rather than generic decoration.
  CinematicTileArt bridgeboundTileArtifacts({required String tileId, required Color accent, required double viewportWidth}) {
    final seed = _stableSeed('bridgebound.$tileId');
    final r = math.Random(seed);
    final wide = viewportWidth >= 980;

    // Bias the palette toward “institutional teal + midnight” even when the
    // accent is coming from the keyword palette.
    final tealBias = Color.lerp(accent, const Color(0xFF22D3EE), 0.55)!.withValues(alpha: 1.0);
    final deep = const Color(0xFF07101A);
    final secondary = _shiftHue(tealBias, degrees: r.nextBool() ? 14 : -12).withValues(alpha: 1.0);

    final gradient = <Color>[
      Colors.white.withValues(alpha: wide ? 0.07 : 0.05),
      tealBias.withValues(alpha: wide ? 0.20 : 0.14),
      secondary.withValues(alpha: wide ? 0.12 : 0.08),
      deep.withValues(alpha: 0.92),
    ];

    final stops = <double>[0.0, wide ? 0.38 : 0.46, wide ? 0.68 : 0.66, 1.0];

    return CinematicTileArt(
      seed: seed,
      gradientColors: gradient,
      gradientStops: stops,
      motifDensity: wide ? 1.10 : 0.95,
      motifMinAlpha: wide ? 0.05 : 0.04,
      motifMaxAlpha: wide ? 0.13 : 0.11,
      sheenBase: wide ? 0.11 : 0.10,
      vignetteStrength: wide ? 0.20 : 0.16,
      overlayKind: CinematicTileOverlayKind.bridgeboundNetwork,
      overlayAlpha: wide ? 0.12 : 0.10,
    );
  }

  int _stableSeed(String input) {
    // Simple stable hash (no crypto): adequate for deterministic visuals.
    var h = 0;
    for (final code in input.codeUnits) {
      h = 0x1fffffff & (h + code);
      h = 0x1fffffff & (h + ((0x0007ffff & h) << 10));
      h ^= (h >> 6);
    }
    h = 0x1fffffff & (h + ((0x03ffffff & h) << 3));
    h ^= (h >> 11);
    h = 0x1fffffff & (h + ((0x00003fff & h) << 15));
    return h;
  }

  Color _shiftHue(Color color, {required double degrees}) {
    final hsl = HSLColor.fromColor(color);
    final newHue = (hsl.hue + degrees) % 360.0;
    return hsl.withHue(newHue).toColor();
  }
}
