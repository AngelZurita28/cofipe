// lib/app/presentation/screens/category_detail/category_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../data/repositories/goal_repository.dart';
import '../../../../data/repositories/movement_repository.dart';
import '../../widgets/recent_movements_list.dart';
import 'add_goal_dialog.dart';

class CategoryDetailScreen extends ConsumerWidget {
  const CategoryDetailScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  final String categoryId;
  final String categoryName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        // --- 1. Botón para añadir una nueva meta ---
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task),
            tooltip: 'Añadir Meta',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AddGoalDialog(categoryId: categoryId),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- 2. Nueva sección para mostrar las metas ---
          _buildGoalsSection(context, ref),

          const SizedBox(height: 24),

          Text(
            'Movimientos en esta Categoría',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // El widget de la lista de movimientos ya filtrada
          RecentMovementsList(
            movementsProvider: movementsByCategoryProvider(categoryId),
          ),
        ],
      ),
    );
  }

  // --- 3. Widget auxiliar para construir la sección de metas ---
  Widget _buildGoalsSection(BuildContext context, WidgetRef ref) {
    final goalsAsyncValue = ref.watch(goalsByCategoryProvider(categoryId));

    return goalsAsyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (goals) {
        if (goals.isEmpty) {
          return const SizedBox.shrink(); // No muestra nada si no hay metas
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Metas de Ahorro',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...goals
                .map(
                  (goal) => Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                goal.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${(goal.savedAmount / goal.targetAmount * 100).toStringAsFixed(1)}%',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: goal.savedAmount / goal.targetAmount,
                            minHeight: 12,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${NumberFormat.simpleCurrency(locale: 'es_MX').format(goal.savedAmount)} de ${NumberFormat.simpleCurrency(locale: 'es_MX').format(goal.targetAmount)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ],
        );
      },
    );
  }
}
