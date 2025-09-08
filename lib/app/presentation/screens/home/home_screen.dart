// lib/app/presentation/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/recent_movements_list.dart';
import '../../widgets/financial_summary_chart.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50, // Oculta la barra de herramientas
        backgroundColor: Color(0xFFF5F6F8),
        scrolledUnderElevation: 0,
        title: const Text('Resumen Financiero'),
        titleTextStyle: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontFamily: GoogleFonts.inter().fontFamily,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 5, bottom: 16, left: 16, right: 16),
        children: [
          // 2. --- Reemplaza el Container con el nuevo widget ---
          const FinancialSummaryChart(),
          const SizedBox(height: 24),
          Text(
            'Movimientos Recientes',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          const RecentMovementsList(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
