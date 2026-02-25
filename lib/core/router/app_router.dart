import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:focusguard/features/dashboard/views/main_dashboard.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const MainDashboard()),
    ],
  );
});
