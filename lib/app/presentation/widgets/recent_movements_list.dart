import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/category_model.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/repositories/movement_repository.dart';
import 'movement_list_item.dart';

class RecentMovementsList extends ConsumerWidget {
  const RecentMovementsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movementsAsyncValue = ref.watch(movementsStreamProvider);
    final categoriesAsyncValue = ref.watch(categoriesStreamProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8, top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),

            // Contenido de la lista
            movementsAsyncValue.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (movements) {
                if (movements.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.0),
                      child: Text(
                        'Aún no tienes movimientos.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return categoriesAsyncValue.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                  data: (categories) {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: movements.length > 5
                          ? 5
                          : movements.length, // Muestra máximo 3
                      itemBuilder: (context, index) {
                        final movement = movements[index];
                        final category = categories.firstWhere(
                          (cat) => cat.id == movement.categoryId,
                          orElse: () => CategoryModel(
                            id: '',
                            name: 'Sin categoría',
                            type: movement.type,
                          ),
                        );

                        // Utiliza el widget reutilizable
                        return MovementListItem(
                          movement: movement,
                          category: category,
                        );
                      },
                    );
                  },
                );
              },
            ),

            // Pie de página del Card
            // const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  context.go('/movements');
                },
                child: const Text('ir a mis movimientos'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
