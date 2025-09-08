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
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/all_movements/all_movements_screen.dart';
import '../../presentation/screens/category_detail/category_detail_screen.dart';

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

      // --- RUTA MOVILIDA A NIVEL SUPERIOR ---
      // Ahora es una pantalla completa e independiente
      GoRoute(
        path: '/movements',
        builder: (context, state) => const AllMovementsScreen(),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainLayoutScreen(navigationShell: navigationShell);
        },
        branches: [
          // Rama para "Inicio" (ahora solo contiene la ruta raíz)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          // Rama para "Panel"
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
                routes: [
                  GoRoute(
                    path: 'category/:id',
                    builder: (context, state) {
                      final categoryId = state.pathParameters['id']!;
                      final categoryName =
                          state.extra as String? ?? 'Categoría';
                      return CategoryDetailScreen(
                        categoryId: categoryId,
                        categoryName: categoryName,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          // Rama para "Crecimiento"
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/growth',
                builder: (context, state) => const GrowthScreen(),
              ),
            ],
          ),

          // Rama para "Perfil"
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
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
