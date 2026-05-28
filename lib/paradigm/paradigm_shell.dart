import 'package:flutter/material.dart';

import 'package:parallel_paradigm_org/paradigm/paradigm_simulation.dart';

/// Shared shell that renders the background spatial engine and overlays route content.
class ParadigmShell extends StatefulWidget {
  const ParadigmShell({super.key, required this.stage, required this.accessState, required this.child});

  final ParadigmStage stage;
  final ParadigmAccessState accessState;
  final Widget child;

  @override
  State<ParadigmShell> createState() => _ParadigmShellState();
}

class _ParadigmShellState extends State<ParadigmShell> with SingleTickerProviderStateMixin {
  late final ParadigmParticleSimulation _simulation;

  @override
  void initState() {
    super.initState();
    _simulation = ParadigmParticleSimulation(vsync: this);
    _syncModes();
  }

  @override
  void didUpdateWidget(covariant ParadigmShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncModes();
  }

  void _syncModes() {
    _simulation.setStage(widget.stage);
    _simulation.setAccessState(widget.accessState);
  }

  @override
  void dispose() {
    _simulation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Capture pointer updates across web/desktop (hover) AND mobile (drag/touch).
    return Listener(
      onPointerDown: (event) => _simulation.setTargetPointer(event.localPosition),
      onPointerMove: (event) => _simulation.setTargetPointer(event.localPosition),
      child: MouseRegion(
        onHover: (event) => _simulation.setTargetPointer(event.localPosition),
        child: Stack(
          children: [
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(painter: ParadigmSpatialEnginePainter(simulation: _simulation)),
              ),
            ),
            Positioned.fill(child: widget.child),
          ],
        ),
      ),
    );
  }
}
