// lib/app/presentation/screens/main_layout/main_layout_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../add_movement/add_movement_sheet.dart';

class MainLayoutScreen extends StatelessWidget {
  const MainLayoutScreen({
    super.key,
    required this.navigationShell, // El gestor de estado de navegación de GoRouter
  });

  final StatefulNavigationShell navigationShell;

  // Las definiciones de nuestros ítems de navegación
  static const List<Map<String, String>> navItems = [
    {
      'path': '/',
      'label': 'Inicio',
      'outline': 'assets/icons/home-outline.svg',
      'solid': 'assets/icons/home-solid.svg',
    },
    {
      'path': '/dashboard',
      'label': 'Panel',
      'outline': 'assets/icons/chart-pie-outline.svg',
      'solid': 'assets/icons/chart-pie-solid.svg',
    },
    {
      'path': '/growth',
      'label': 'Crecimiento',
      'outline': 'assets/icons/arrow-trending-up-outline.svg',
      'solid': 'assets/icons/arrow-trending-up-solid.svg',
    },
    {
      'path': '/profile',
      'label': 'Perfil',
      'outline': 'assets/icons/user-outline.svg',
      'solid': 'assets/icons/user-solid.svg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // El cuerpo ahora es el navigationShell, que contiene la pantalla activa
      body: navigationShell,

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // --- LÓGICA PARA ABRIR EL MODAL ---
          showModalBottomSheet(
            context: context,
            builder: (ctx) => const AddMovementSheet(),
            isScrollControlled:
                true, // Permite que el modal se ajuste al teclado
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
          );
        },
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ...navItems
                .sublist(0, 2)
                .map((item) => _buildNavItem(context, item)),
            const SizedBox(width: 48),
            ...navItems
                .sublist(2, 4)
                .map((item) => _buildNavItem(context, item)),
          ],
        ),
      ),
    );
  }

  // El helper para construir cada ítem
  Widget _buildNavItem(BuildContext context, Map<String, String> item) {
    // El índice actual nos lo da directamente el navigationShell
    final bool isSelected =
        navigationShell.currentIndex ==
        navItems.indexWhere((i) => i['label'] == item['label']);
    final color = isSelected
        ? Theme.of(context).colorScheme.primary
        : Colors.grey;
    final asset = isSelected ? item['solid']! : item['outline']!;

    return InkWell(
      // La navegación ahora la gestiona el navigationShell
      onTap: () => navigationShell.goBranch(
        navItems.indexWhere((i) => i['label'] == item['label']!),
      ),
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              asset,
              height: 24,
              width: 24,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            const SizedBox(height: 4),
            Text(item['label']!, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
