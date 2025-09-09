import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/movement_model.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/repositories/movement_repository.dart';

/// This provider generates a detailed string of all financial transactions
/// from the last 30 days for the chatbot's context.
final financialContextProvider = Provider<String>((ref) {
  // Watch the providers for the last month's movements and all categories
  final movementsAsync = ref.watch(lastMonthMovementsProvider);
  final categoriesAsync = ref.watch(categoriesStreamProvider);

  // When both streams have data, build the detailed context string
  return movementsAsync.when(
    data: (movements) {
      return categoriesAsync.when(
        data: (categories) {
          if (movements.isEmpty) {
            return "El usuario no tiene movimientos registrados en los últimos 30 días.";
          }

          // Create a lookup map for categories for efficient access
          final categoryMap = {for (var cat in categories) cat.id: cat.name};

          // Build the detailed list of transactions
          final movementsListString = movements
              .map((m) {
                final type = m.type == MovementType.income
                    ? "Ingreso"
                    : "Gasto";
                final categoryName =
                    categoryMap[m.categoryId] ?? "Sin categoría";
                final formattedDate = DateFormat('yyyy-MM-dd').format(m.date);
                final formattedAmount = NumberFormat.simpleCurrency(
                  decimalDigits: 2,
                ).format(m.amount);

                return "- Fecha: $formattedDate, Tipo: $type, Descripción: ${m.description}, Monto: $formattedAmount, Categoría: $categoryName";
              })
              .join('\n');

          return """
          Aquí está la lista detallada de todos los movimientos del usuario en los últimos 30 días. Analízala para responder su pregunta.

          --- INICIO DE DATOS ---
          $movementsListString
          --- FIN DE DATOS ---
          """;
        },
        loading: () => "Cargando datos de categorías...",
        error: (e, s) => "Error al cargar las categorías.",
      );
    },
    loading: () => "Cargando datos de movimientos...",
    error: (e, s) => "Error al cargar los movimientos.",
  );
});
