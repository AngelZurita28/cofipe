import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../add_movement/add_movement_sheet.dart';
import '../chatbot/chatbot_sheet.dart';
import '../chatbot/chatbot_overlay.dart';

class MainLayoutScreen extends StatelessWidget {
  const MainLayoutScreen({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

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
    return Stack(
      children: [
        Scaffold(
          body: navigationShell,
          floatingActionButton: FloatingActionButton(
            heroTag: 'add_movement_fab',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (ctx) => const AddMovementSheet(),
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
              );
            },
            shape: const CircleBorder(),
            child: const Icon(Icons.add),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
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
        ),

        // --- SECCIÓN MODIFICADA PARA EL BOTÓN DEL CHATBOT ---
        Positioned(
          bottom: 140, // 50 píxeles desde el borde superior
          right: 16, // 16 píxeles desde el borde derecho
          child: FloatingActionButton(
            heroTag: 'chatbot_fab',
            onPressed: () {
              showGeneralDialog(
                context: context,
                barrierDismissible: true,
                barrierLabel: 'Chatbot',
                barrierColor: Colors.black.withOpacity(0.0),
                transitionDuration: const Duration(milliseconds: 300),
                pageBuilder: (context, anim1, anim2) {
                  return const ChatbotOverlay();
                },
                transitionBuilder: (context, anim1, anim2, child) {
                  return FadeTransition(opacity: anim1, child: child);
                },
              );
            },
            backgroundColor: Colors.white,
            elevation: 4.0,
            shape: CircleBorder(
              side: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset('assets/ai-logo.png'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(BuildContext context, Map<String, String> item) {
    final bool isSelected =
        navigationShell.currentIndex ==
        navItems.indexWhere((i) => i['label'] == item['label']);
    final color = isSelected
        ? Theme.of(context).colorScheme.primary
        : Colors.grey;
    final asset = isSelected ? item['solid']! : item['outline']!;

    return InkWell(
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
