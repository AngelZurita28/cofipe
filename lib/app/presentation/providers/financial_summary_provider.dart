// lib/app/presentation/providers/financial_summary_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/movement_model.dart';
import '../../../data/repositories/movement_repository.dart';

// 1. Una clase simple para contener nuestro resumen calculado
class FinancialSummary {
  final double totalIncome;
  final double totalExpenses;
  final double balance;

  FinancialSummary({
    this.totalIncome = 0.0,
    this.totalExpenses = 0.0,
    this.balance = 0.0,
  });
}

// 2. El Provider que calcula el resumen
final financialSummaryProvider = Provider<FinancialSummary>((ref) {
  // Observa el stream de movimientos para recalcularse automáticamente
  final movementsAsyncValue = ref.watch(movementsStreamProvider);

  // Usa .when para manejar el estado de los datos de forma segura
  return movementsAsyncValue.when(
    data: (movements) {
      double income = 0;
      double expenses = 0;

      // Itera sobre la lista de movimientos para sumar los totales
      for (final movement in movements) {
        if (movement.type == MovementType.income) {
          income += movement.amount;
        } else {
          expenses += movement.amount;
        }
      }

      return FinancialSummary(
        totalIncome: income,
        totalExpenses: expenses,
        balance: income - expenses,
      );
    },
    // Si aún está cargando o hay un error, devuelve un resumen vacío
    loading: () => FinancialSummary(),
    error: (e, s) => FinancialSummary(),
  );
});
