import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'package:parallel_paradigm_org/theme.dart';

enum ParadigmStage { vanguard, grid, deepDive, inquiry }
enum ParadigmAccessState { locked, processing, granted }

/// High-performance particle simulation modeled after the original Float32Array heap.
///
/// This is intentionally imperative + heap-based to keep the "premium kinetic" feel
/// while minimizing allocations per frame.
class ParadigmParticleSimulation {
  ParadigmParticleSimulation({required TickerProvider vsync, int particleCount = 1500, int stride = 6})
      : _particleCount = particleCount,
        _stride = stride,
        heap = Float32List(particleCount * stride),
        _random = math.Random() {
    _initHeap();
    _ticker = vsync.createTicker(_onTick)..start();
  }

  final int _particleCount;
  final int _stride;
  final math.Random _random;
  late final Ticker _ticker;

  /// (x, y, vx, vy, radius, phase) repeating.
  final Float32List heap;

  final ValueNotifier<int> repaint = ValueNotifier<int>(0);

  ParadigmStage stage = ParadigmStage.vanguard;
  ParadigmAccessState accessState = ParadigmAccessState.locked;

  Offset pointer = const Offset(0, 0);
  Offset targetPointer = const Offset(0, 0);

  Size viewport = const Size(1920, 1080);

  void setTargetPointer(Offset p) => targetPointer = p;

  void setViewport(Size size) {
    if (size.isEmpty) return;
    viewport = size;
  }

  void setStage(ParadigmStage s) => stage = s;
  void setAccessState(ParadigmAccessState s) => accessState = s;

  void dispose() {
    _ticker.dispose();
    repaint.dispose();
  }

  void _initHeap() {
    for (int i = 0; i < _particleCount; i++) {
      final idx = i * _stride;
      heap[idx] = _random.nextDouble() * viewport.width;
      heap[idx + 1] = _random.nextDouble() * viewport.height;
      heap[idx + 2] = 0; // vx
      heap[idx + 3] = 0; // vy
      heap[idx + 4] = _random.nextDouble() * 1.5 + 0.5; // radius
      heap[idx + 5] = _random.nextDouble() * math.pi * 2; // phase
    }
  }

  void _onTick(Duration elapsed) {
    // Smooth pointer.
    pointer = Offset(
      pointer.dx + (targetPointer.dx - pointer.dx) * 0.1,
      pointer.dy + (targetPointer.dy - pointer.dy) * 0.1,
    );

    // Background is dominant; keep sim deterministic and allocation-free.
    final width = viewport.width;
    final height = viewport.height;
    if (width <= 1 || height <= 1) return;

    for (int i = 0; i < _particleCount; i++) {
      final idx = i * _stride;

      var x = heap[idx];
      var y = heap[idx + 1];
      var vx = heap[idx + 2];
      var vy = heap[idx + 3];
      final phase = heap[idx + 5];

      var targetX = x;
      var targetY = y;

      switch (stage) {
        case ParadigmStage.vanguard:
          final dx = x - pointer.dx;
          final dy = y - pointer.dy;
          final dist = math.sqrt(dx * dx + dy * dy);
          if (dist > 200) {
            targetX = pointer.dx + math.cos(phase) * 200;
            targetY = pointer.dy + math.sin(phase) * 200;
          } else {
            targetX += (_random.nextDouble() - 0.5) * 2;
            targetY += (_random.nextDouble() - 0.5) * 2;
          }
          break;
        case ParadigmStage.grid:
          targetX = (i % 50) * (width / 50.0);
          targetY = y + math.sin(phase + pointer.dy * 0.01) * 2;
          break;
        case ParadigmStage.deepDive:
          if (accessState == ParadigmAccessState.locked) {
            targetX = x + (_random.nextDouble() - 0.5) * 10;
            targetY = y + (_random.nextDouble() - 0.5) * 10;
          } else {
            targetX = x + math.cos(phase) * 0.5;
            targetY = y + math.sin(phase) * 0.5;
          }
          break;
        case ParadigmStage.inquiry:
          // Calm, slightly organized drift ("signal acquisition" mood).
          targetX = x + math.cos(phase + pointer.dx * 0.01) * 0.8;
          targetY = y + math.sin(phase + pointer.dy * 0.01) * 0.8;
          break;
      }

      vx += (targetX - x) * 0.02;
      vy += (targetY - y) * 0.02;
      vx *= 0.9;
      vy *= 0.9;
      x += vx;
      y += vy;

      // Keep within bounds (wrap, like the web version's modulo).
      if (x < 0) x += width;
      if (x > width) x -= width;
      if (y < 0) y += height;
      if (y > height) y -= height;

      heap[idx] = x;
      heap[idx + 1] = y;
      heap[idx + 2] = vx;
      heap[idx + 3] = vy;
      heap[idx + 5] = phase + 0.01;
    }

    // Trigger repaint only (not rebuild).
    repaint.value++;
  }
}

class ParadigmSpatialEnginePainter extends CustomPainter {
  ParadigmSpatialEnginePainter({required this.simulation}) : super(repaint: simulation.repaint);

  final ParadigmParticleSimulation simulation;

  @override
  void paint(Canvas canvas, Size size) {
    simulation.setViewport(size);

    final stage = simulation.stage;
    canvas.drawRect(Offset.zero & size, Paint()..color = ParadigmColors.bg);

    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = (stage == ParadigmStage.deepDive ? Colors.white.withValues(alpha: 0.10) : Colors.white.withValues(alpha: 0.40));

    final heap = simulation.heap;
    const stride = 6;
    final count = heap.length ~/ stride;

    for (int i = 0; i < count; i++) {
      final idx = i * stride;
      final x = heap[idx];
      final y = heap[idx + 1];
      final r = heap[idx + 4];
      canvas.drawCircle(Offset(x, y), r, fill);
    }
  }

  @override
  bool shouldRepaint(covariant ParadigmSpatialEnginePainter oldDelegate) => oldDelegate.simulation != simulation;
}
