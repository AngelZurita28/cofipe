// lib/app/presentation/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../widgets/recent_movements_list.dart';
import '../../widgets/financial_summary_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: const Color(0xFFF5F6F8),
        scrolledUnderElevation: 0,
        // The title is now a Consumer to watch for user data changes
        title: Consumer(
          builder: (context, ref, child) {
            final userModelAsync = ref.watch(userModelStreamProvider);

            // Use .when to handle loading, error, and data states
            return userModelAsync.when(
              data: (user) {
                // If there's no user data, show a default title
                if (user == null) {
                  return const Text('Resumen');
                }
                // If there is user data, show the greeting and streak
                return Row(
                  children: [
                    Text(
                      'Hola, ${user.name.split(' ').first}!',
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const Spacer(),
                    Lottie.asset(
                      'assets/animations/fire-streak.json',
                      height: 55, // Ajusta el tamaño como prefieras
                      width: 55,
                    ),
                    // const SizedBox(width: 4),
                    Text(
                      '${user.streakCount} días',
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                );
              },
              // Show placeholders while loading or if an error occurs
              loading: () =>
                  const Text('Cargando...', style: TextStyle(fontSize: 24.0)),
              error: (e, s) =>
                  const Text('Resumen', style: TextStyle(fontSize: 24.0)),
            );
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 5, bottom: 16, left: 16, right: 16),
        children: [
          // 2. --- Reemplaza el Container con el nuevo widget ---
          const FinancialSummaryChart(),
          const SizedBox(height: 24),
          Text(
            'Movimientos Recientes',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          const RecentMovementsList(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
