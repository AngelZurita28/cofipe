// lib/app/config/router/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Importa todas tus pantallas
import '../../../data/repositories/user_repository.dart';
import '../../presentation/screens/login/login_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/dashboard/dashboard_screen.dart';
import '../../presentation/screens/growth/growth_screen.dart';
import '../../presentation/screens/main_layout/main_layout_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(userRepository.authStateChanges),

    redirect: (BuildContext context, GoRouterState state) {
      final bool isLoggedIn = userRepository.currentUser != null;
      final bool isLoggingIn = state.uri.toString() == '/login';

      if (!isLoggedIn && !isLoggingIn) return '/login';
      if (isLoggedIn && isLoggingIn) return '/';

      return null;
    },

    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),

      // --- SHELL ROUTE PARA LA NAVEGACIÓN PRINCIPAL ---
      ShellRoute(
        // El constructor de nuestra "carcasa"
        builder: (context, state, child) {
          return MainLayoutScreen(child: child);
        },
        // Las rutas que vivirán dentro de la carcasa
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/growth',
            builder: (context, state) => const GrowthScreen(),
          ),
        ],
      ),
    ],
  );
});

// Clase auxiliar para que GoRouter pueda escuchar un Stream
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    stream.asBroadcastStream().listen((_) => notifyListeners());
  }
}
