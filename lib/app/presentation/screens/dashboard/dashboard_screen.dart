// lib/app/presentation/screens/dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cofipe/data/models/category_model.dart';
import 'package:cofipe/data/models/movement_model.dart';
import 'package:cofipe/data/repositories/category_repository.dart';
import 'package:go_router/go_router.dart';
// import 'add_category_dialog.dart'; // Lo usaremos después

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsyncValue = ref.watch(categoriesStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Panel de Control')),
      body: categoriesAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (categories) {
          // Filtramos para obtener solo las categorías de gastos
          final expenseCategories = categories
              .where((c) => c.type == MovementType.expense)
              .toList();

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Sección de Gastos y Ahorros
              Text(
                'Organiza tus gastos y ahorros',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // La Cuadrícula de Categorías
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, // 4 columnas
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: expenseCategories.length,
                itemBuilder: (context, index) {
                  return _buildCategoryItem(context, expenseCategories[index]);
                },
              ),
              const SizedBox(height: 24),
              // Aquí irá el botón de "+" para añadir más categorías
            ],
          );
        },
      ),
    );
  }

  // Helper para construir cada ítem de la cuadrícula
  Widget _buildCategoryItem(BuildContext context, CategoryModel category) {
    return GestureDetector(
      // <-- 1. Envuelve en GestureDetector
      onTap: () {
        // <-- 2. Añade el evento onTap
        // Navega a la pantalla de detalle, pasando el ID y el nombre
        context.go('/dashboard/category/${category.id}', extra: category.name);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              // Construimos el ícono usando su codepoint guardado
              IconData(category.iconCodePoint, fontFamily: 'MaterialIcons'),
              color: Theme.of(context).colorScheme.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            category.name,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
