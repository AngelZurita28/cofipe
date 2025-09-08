// lib/app/presentation/widgets/financial_summary_chart.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/financial_summary_provider.dart';

class FinancialSummaryChart extends ConsumerWidget {
  const FinancialSummaryChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(financialSummaryProvider);
    final theme = Theme.of(context);

    // Colores basados en estados, no hardcodeados
    const incomeColor = Colors.green;
    const expenseColor = Colors.red;
    final balanceColor = theme.colorScheme.primary;

    // --- Caso 1: No hay datos de ingresos ---
    if (summary.totalIncome <= 0) {
      return Card(
        child: Container(
          height: 250,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Registra un ingreso para ver tu resumen financiero',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // --- Caso 2: Hay datos ---
    final total = summary.totalIncome;
    final expensePercentage = (summary.totalExpenses / total) * 100;
    final balancePercentage = (summary.balance / total) * 100;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            SizedBox(
              height: 200, // Altura para la dona
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Balance Actual', style: theme.textTheme.titleSmall),
                      const SizedBox(height: 8),
                      Text(
                        '\$${summary.balance.toStringAsFixed(2)}',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: summary.balance >= 0
                              ? incomeColor
                              : expenseColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${balancePercentage.toStringAsFixed(1)}% del ingreso',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  PieChart(
                    PieChartData(
                      startDegreeOffset: -90,
                      sectionsSpace: 2,
                      centerSpaceRadius: 80,
                      sections: _buildPieChartSections(
                        expensePercentage,
                        balancePercentage,
                        expenseColor,
                        balanceColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildLegend(
              context,
              summary,
              incomeColor,
              expenseColor,
              balanceColor,
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
    double expensePercentage,
    double balancePercentage,
    Color expenseColor,
    Color balanceColor,
  ) {
    // Si el balance es negativo, la gráfica entera es de gastos
    if (balancePercentage <= 0) {
      return [
        PieChartSectionData(
          value: 100,
          color: expenseColor.withOpacity(0.7),
          radius: 25,
          showTitle: false,
        ),
      ];
    }

    return [
      PieChartSectionData(
        value: expensePercentage,
        color: expenseColor,
        radius: 25,
        showTitle: false,
      ),
      PieChartSectionData(
        value: balancePercentage,
        color: balanceColor,
        radius: 25,
        showTitle: false,
      ),
    ];
  }

  Widget _buildLegend(
    BuildContext context,
    FinancialSummary summary,
    Color incomeColor,
    Color expenseColor,
    Color balanceColor,
  ) {
    final expensePercentage = summary.totalIncome > 0
        ? (summary.totalExpenses / summary.totalIncome) * 100
        : 0;
    final balancePercentage = summary.totalIncome > 0
        ? (summary.balance / summary.totalIncome) * 100
        : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLegendItem(
            context,
            incomeColor,
            'Ingresos',
            '\$${summary.totalIncome.toStringAsFixed(2)}',
            '100%',
          ),
          Container(height: 40, width: 1, color: Colors.grey.shade300),
          _buildLegendItem(
            context,
            expenseColor,
            'Gastos',
            '\$${summary.totalExpenses.toStringAsFixed(2)}',
            '${expensePercentage.toStringAsFixed(1)}%',
          ),
          Container(height: 40, width: 1, color: Colors.grey.shade300),
          _buildLegendItem(
            context,
            summary.balance >= 0 ? balanceColor : expenseColor,
            summary.balance >= 0 ? 'Ahorro' : 'Déficit',
            '\$${summary.balance.abs().toStringAsFixed(2)}',
            '${balancePercentage.abs().toStringAsFixed(1)}%',
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    Color color,
    String label,
    String amount,
    String percentage,
  ) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          percentage,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
