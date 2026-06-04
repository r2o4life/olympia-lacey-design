import 'package:flutter/material.dart';

/// Render artifacts used by the cinematic tile system to shape backgrounds.
///
/// Kept UI-light and dependency-free so it can be produced by non-UI engines
/// (e.g., UPP v4) and consumed by UI widgets.
class CinematicTileArt {
  const CinematicTileArt({
    required this.seed,
    required this.gradientColors,
    required this.gradientStops,
    required this.motifDensity,
    required this.motifMinAlpha,
    required this.motifMaxAlpha,
    required this.sheenBase,
    required this.vignetteStrength,
    this.overlayKind = CinematicTileOverlayKind.none,
    this.overlayAlpha = 0.10,
  });

  final int seed;
  final List<Color> gradientColors;
  final List<double> gradientStops;

  /// Multiplier for how many motifs are rendered at a given viewport area.
  final double motifDensity;
  final double motifMinAlpha;
  final double motifMaxAlpha;

  /// Base alpha used by the sheen overlay (hover increases it).
  final double sheenBase;

  /// Strength of the edge vignette overlay. Higher = darker edges.
  final double vignetteStrength;

  /// Optional overlay layer that can be enabled per case study.
  ///
  /// Kept as a small enum so non-UI engines (UPP v4) can request a visual motif
  /// without importing widget/painter code.
  final CinematicTileOverlayKind overlayKind;

  /// Base opacity for the overlay layer (hover may amplify).
  final double overlayAlpha;
}

enum CinematicTileOverlayKind {
  none,
  bridgeboundNetwork,
}
