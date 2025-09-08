// lib/app/presentation/screens/all_movements/all_movements_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../data/models/category_model.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../data/repositories/movement_repository.dart';
import '../../widgets/movement_list_item.dart';
import 'package:google_fonts/google_fonts.dart';

class AllMovementsScreen extends ConsumerWidget {
  const AllMovementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final movementsAsyncValue = ref.watch(movementsStreamProvider);
    final categoriesAsyncValue = ref.watch(categoriesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        scrolledUnderElevation: 0,
        backgroundColor: Color(0xFFF5F6F8),
        title: const Text('Todos los Movimientos'),
        titleTextStyle: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontFamily: GoogleFonts.inter().fontFamily,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      // --- CAMBIOS AQUÍ ---
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 16),
        child: Card(
          child: movementsAsyncValue.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
            data: (movements) {
              if (movements.isEmpty) {
                return const Center(
                  child: Text('No hay movimientos para mostrar.'),
                );
              }

              return categoriesAsyncValue.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
                data: (categories) {
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                    ), // Padding interno para la lista
                    itemCount: movements.length,
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
        ),
      ),
    );
  }
}
