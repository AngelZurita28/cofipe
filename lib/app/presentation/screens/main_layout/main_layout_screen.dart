// lib/app/presentation/screens/main_layout/main_layout_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../add_movement/add_movement_sheet.dart';

class MainLayoutScreen extends StatelessWidget {
  const MainLayoutScreen({super.key, required this.child});

  final Widget child;

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/dashboard')) return 1;
    if (location.startsWith('/growth')) return 2;
    // Agregamos el caso para el perfil
    if (location.startsWith('/profile')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/dashboard');
        break;
      case 2:
        context.go('/growth');
        break;
      // Agregamos el caso para el perfil
      case 3:
        // TODO: Crear la ruta y pantalla de perfil
        // context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: child,
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
            // 2. Pasamos las rutas de los SVG en lugar de los IconData
            _buildNavItem(
              context: context,
              index: 0,
              currentIndex: currentIndex,
              outlineAsset: 'assets/icons/home-outline.svg',
              solidAsset: 'assets/icons/home-solid.svg',
              label: 'Inicio',
            ),
            _buildNavItem(
              context: context,
              index: 1,
              currentIndex: currentIndex,
              outlineAsset: 'assets/icons/chart-pie-outline.svg',
              solidAsset: 'assets/icons/chart-pie-solid.svg',
              label: 'Panel',
            ),
            const SizedBox(width: 48), // Espacio para el FAB
            _buildNavItem(
              context: context,
              index: 2,
              currentIndex: currentIndex,
              outlineAsset: 'assets/icons/arrow-trending-up-outline.svg',
              solidAsset: 'assets/icons/arrow-trending-up-solid.svg',
              label: 'Crecimiento',
            ),
            _buildNavItem(
              context: context,
              index: 3,
              currentIndex: currentIndex,
              outlineAsset: 'assets/icons/user-outline.svg',
              solidAsset: 'assets/icons/user-solid.svg',
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }

  // 3. Modificamos el helper para que acepte las rutas de los SVG
  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required int currentIndex,
    required String outlineAsset,
    required String solidAsset,
    required String label,
  }) {
    final bool isSelected = index == currentIndex;
    final color = isSelected
        ? Theme.of(context).colorScheme.primary
        : Colors.grey;
    final asset = isSelected ? solidAsset : outlineAsset;

    return InkWell(
      onTap: () => _onItemTapped(index, context),
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Usamos SvgPicture.asset en lugar de Icon
            SvgPicture.asset(
              asset,
              height: 24,
              width: 24,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
