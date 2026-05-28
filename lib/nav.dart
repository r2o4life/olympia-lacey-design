import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:parallel_paradigm_org/paradigm/pages/deep_dive_page.dart';
import 'package:parallel_paradigm_org/paradigm/pages/grid_page.dart';
import 'package:parallel_paradigm_org/paradigm/pages/inquiry_page.dart';
import 'package:parallel_paradigm_org/paradigm/pages/vanguard_page.dart';

import 'package:parallel_paradigm_org/paradigm/paradigm_data.dart';

/// GoRouter configuration for app navigation
///
/// This uses go_router for declarative routing, which provides:
/// - Type-safe navigation
/// - Deep linking support (web URLs, app links)
/// - Easy route parameters
/// - Navigation guards and redirects
///
/// To add a new route:
/// 1. Add a route constant to AppRoutes below
/// 2. Add a GoRoute to the routes list
/// 3. Navigate using context.go() or context.push()
/// 4. Use context.pop() to go back.
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.vanguard,
    errorPageBuilder: (context, state) {
      return NoTransitionPage(
        child: _RouteErrorPage(
          location: state.uri.toString(),
          error: state.error,
        ),
      );
    },
    routes: [
      GoRoute(
        path: AppRoutes.vanguard,
        name: 'vanguard',
        pageBuilder: (context, state) => const NoTransitionPage(child: VanguardPage()),
      ),
      GoRoute(
        path: AppRoutes.grid,
        name: 'grid',
        pageBuilder: (context, state) => const NoTransitionPage(child: GridPage()),
      ),
      GoRoute(
        path: AppRoutes.inquiry,
        name: 'inquiry',
        pageBuilder: (context, state) => const NoTransitionPage(child: InquiryPage()),
      ),
      GoRoute(
        path: AppRoutes.projectPattern,
        name: 'project',
        redirect: (context, state) {
          final id = state.pathParameters['id'];
          if (id == null || id.isEmpty) return AppRoutes.grid;
          if (!ParadigmProjects.projects.containsKey(id)) return AppRoutes.grid;
          return null;
        },
        pageBuilder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return NoTransitionPage(child: DeepDivePage(projectId: id));
        },
      ),
    ],
  );
}

class _RouteErrorPage extends StatelessWidget {
  const _RouteErrorPage({required this.location, required this.error});

  final String location;
  final Object? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ROUTE ERROR',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              Text(
                location,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.7)),
              ),
              if (error != null) ...[
                const SizedBox(height: 12),
                Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.55)),
                ),
              ],
              const Spacer(),
              FilledButton(
                onPressed: () => context.go(AppRoutes.vanguard),
                style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                child: const Text('Return Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Route path constants
/// Use these instead of hard-coding route strings
class AppRoutes {
  static const String vanguard = '/';
  static const String grid = '/grid';
  static const String inquiry = '/inquiry';
  static const String projectPattern = '/project/:id';

  static String project(String id) => '/project/$id';
}
