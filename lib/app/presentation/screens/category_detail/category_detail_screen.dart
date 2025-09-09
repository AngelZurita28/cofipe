import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../data/models/category_model.dart';
import '../../../../data/models/movement_model.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../data/repositories/goal_repository.dart';
import '../../../../data/repositories/movement_repository.dart';
import '../../widgets/recent_movements_list.dart'; // Asegúrate que este widget exista
import 'add_goal_dialog.dart';

class CategoryDetailScreen extends ConsumerWidget {
  const CategoryDetailScreen({super.key, required this.category});
  final CategoryModel category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50, // Oculta la barra de herramientas
        backgroundColor: Color(0xFFF5F6F8),
        scrolledUnderElevation: 0,
        title: Text(category.name),
        titleTextStyle: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontFamily: GoogleFonts.inter().fontFamily,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (category.type == MovementType.expense)
            _buildLinkedGoalsSection(context, ref, category.id),

          const SizedBox(height: 24),
          if (category.type == MovementType.income && !category.isGoal)
            ElevatedButton.icon(
              icon: const Icon(Icons.sync),
              label: const Text('Configurar Ingreso Recurrente'),
              onPressed: () {
                context.go(
                  '/dashboard/category/${category.id}/recurring',
                  extra: category,
                );
              },
            ),
          const SizedBox(height: 24),
          Text(
            'Movimientos en esta Categoría',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          RecentMovementsList(
            movementsProvider: movementsByCategoryProvider(category.id),
          ),
        ],
      ),
      // --- 2. SE AÑADE EL BOTÓN AQUÍ COMO UN FAB ---
      floatingActionButton: category.type == MovementType.expense
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.add_task),
              label: const Text('Añadir Meta'),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AddGoalDialog(parentCategory: category),
                );
              },
            )
          : null, // No muestra ningún botón si no es una categoría de gasto
    );
  }

  // Widget para construir la sección de metas de ahorro vinculadas
  Widget _buildLinkedGoalsSection(
    BuildContext context,
    WidgetRef ref,
    String parentCategoryId,
  ) {
    final goalCategoriesAsync = ref.watch(
      goalCategoriesProvider(parentCategoryId),
    );

    return goalCategoriesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (goalCategories) {
        if (goalCategories.isEmpty) {
          return const Text(
            'Aún no tienes metas de ahorro para esta categoría.',
          );
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
            ...goalCategories
                .map(
                  (goalCategory) => _buildGoalItem(context, ref, goalCategory),
                )
                .toList(),
          ],
        );
      },
    );
  }

  // Widget para construir cada ítem de meta con su progreso
  Widget _buildGoalItem(
    BuildContext context,
    WidgetRef ref,
    CategoryModel goalCategory,
  ) {
    final goalProgressAsync = ref.watch(
      goalsByCategoryProvider(goalCategory.id),
    );

    return goalProgressAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (e, s) => const Text('No se pudo cargar el progreso'),
      data: (goals) {
        final goal = goals.isNotEmpty ? goals.first : null;
        if (goal == null) return const SizedBox.shrink();

        final progress = goal.targetAmount > 0
            ? goal.savedAmount / goal.targetAmount
            : 0.0;

        return Card(
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
                      goalCategory.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${(progress * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
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
        );
      },
    );
  }
}
