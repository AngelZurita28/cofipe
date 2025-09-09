import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../data/models/category_model.dart';
import '../../../../data/models/movement_model.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../providers/income_sources_provider.dart';
import 'add_category_dialog.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsyncValue = ref.watch(categoriesStreamProvider);
    final incomeSources = ref.watch(incomeSourcesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0, // Oculta la barra de herramientas
        backgroundColor: Color(0xFFF5F6F8),
        scrolledUnderElevation: 0,
        title: const Text(''),
        titleTextStyle: TextStyle(
          fontSize: 0,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontFamily: GoogleFonts.inter().fontFamily,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- Sección de Fuentes de Ingresos ---
          _buildSectionHeader(
            context,
            title: 'Fuentes de ingresos',
            onSeeAll: () {},
          ),
          if (incomeSources.isEmpty)
            const Card(
              child: SizedBox(
                height: 80,
                child: Center(
                  child: Text('Registra un ingreso para ver tus fuentes aquí.'),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: incomeSources.length,
              itemBuilder: (context, index) {
                return _buildIncomeCard(context, incomeSources[index], index);
              },
            ),

          const SizedBox(height: 32),

          // --- Sección de Gastos y Ahorros ---
          _buildSectionHeader(
            context,
            title: 'Organiza tus gastos y ahorros',
            onSeeAll: () {},
          ),
          categoriesAsyncValue.when(
            loading: () => const Center(
              heightFactor: 5,
              child: CircularProgressIndicator(),
            ),
            error: (err, stack) => Center(child: Text('Error: $err')),
            data: (categories) {
              final expenseCategories = categories
                  .where((c) => c.type == MovementType.expense)
                  .toList();

              if (expenseCategories.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('Aún no tienes categorías de gastos.'),
                  ),
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                itemCount: expenseCategories.length,
                itemBuilder: (context, index) {
                  return _buildCategoryItem(context, expenseCategories[index]);
                },
              );
            },
          ),
          const SizedBox(height: 16),

          OutlinedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Añadir categoría'),
            onPressed: () {
              // showDialog(
              //   context: context,
              //   builder: (ctx) => const AddCategoryDialog(),
              // );
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required VoidCallback onSeeAll,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          TextButton(onPressed: onSeeAll, child: const Text('Ver todos')),
        ],
      ),
    );
  }

  Widget _buildIncomeCard(
    BuildContext context,
    IncomeSource source,
    int index,
  ) {
    final cardColors = [
      Colors.teal.shade300,
      Colors.orange.shade400,
      Colors.yellow.shade600,
    ];
    final color = cardColors[index % cardColors.length];

    return Card(
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          context.go(
            '/dashboard/category/${source.category.id}',
            extra: source.category,
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 80,
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '\$${source.totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 2,
                              color: Colors.black26,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        source.category.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: 90,
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.horizontal(
                    right: Radius.circular(16),
                  ),
                ),
                child: SvgPicture.asset(
                  'assets/icons/${source.category.iconAssetName}',
                  height: double.infinity,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, CategoryModel category) {
    final theme = Theme.of(context);
    final String assetPath = 'assets/icons/${category.iconAssetName}';

    return InkWell(
      onTap: () {
        context.go('/dashboard/category/${category.id}', extra: category);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              assetPath,
              height: 32,
              width: 32,
              colorFilter: ColorFilter.mode(
                theme.colorScheme.primary,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
