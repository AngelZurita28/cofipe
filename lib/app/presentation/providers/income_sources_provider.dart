import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/movement_model.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/repositories/movement_repository.dart';

// A simple class to hold the calculated data for each income source
class IncomeSource {
  final CategoryModel category;
  final double totalAmount;

  IncomeSource({required this.category, required this.totalAmount});
}

// The provider that calculates the totals for each income category
final incomeSourcesProvider = Provider<List<IncomeSource>>((ref) {
  final movementsAsync = ref.watch(movementsStreamProvider);
  final categoriesAsync = ref.watch(categoriesStreamProvider);

  // We need both movements and categories to be loaded
  if (movementsAsync is! AsyncData || categoriesAsync is! AsyncData) {
    return []; // Return empty list while loading or on error
  }

  final List<MovementModel> allMovements = movementsAsync.value!;
  final List<CategoryModel> allCategories = categoriesAsync.value!;

  // Filter to get only income categories
  final incomeCategories = allCategories
      .where((c) => c.type == MovementType.income && !c.isGoal)
      .toList();
  final List<IncomeSource> incomeSources = [];

  for (final category in incomeCategories) {
    // For each income category, sum up all its movements
    final total = allMovements
        .where(
          (m) => m.categoryId == category.id && m.type == MovementType.income,
        )
        .fold<double>(0.0, (sum, movement) => sum + movement.amount);

    // Only add the source if it has any movements
    if (total > 0) {
      incomeSources.add(IncomeSource(category: category, totalAmount: total));
    }
  }

  return incomeSources;
});
