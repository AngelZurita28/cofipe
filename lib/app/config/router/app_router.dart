import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Importa todos los modelos y pantallas
import '../../../data/models/category_model.dart';
import '../../../data/repositories/user_repository.dart';
import '../../presentation/screens/login/login_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/dashboard/dashboard_screen.dart';
import '../../presentation/screens/growth/growth_screen.dart';
import '../../presentation/screens/main_layout/main_layout_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/all_movements/all_movements_screen.dart';
import '../../presentation/screens/category_detail/category_detail_screen.dart';
import '../../presentation/screens/recurring_movement/recurring_movement_screen.dart';

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

      GoRoute(
        path: '/movements',
        builder: (context, state) => const AllMovementsScreen(),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainLayoutScreen(navigationShell: navigationShell);
        },
        branches: [
          // Branch for "Home"
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          // Branch for "Dashboard"
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
                routes: [
                  GoRoute(
                    path: 'category/:id',
                    builder: (context, state) {
                      final category = state.extra as CategoryModel;
                      return CategoryDetailScreen(category: category);
                    },
                    // --- NESTED ROUTE FOR RECURRING INCOME ---
                    routes: [
                      GoRoute(
                        path: 'recurring',
                        builder: (context, state) {
                          final category = state.extra as CategoryModel;
                          return RecurringMovementScreen(category: category);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // Branch for "Growth"
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/growth',
                builder: (context, state) => const GrowthScreen(),
              ),
            ],
          ),

          // Branch for "Profile"
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

// Helper class for GoRouter to listen to a Stream
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    stream.asBroadcastStream().listen((_) => notifyListeners());
  }
}
