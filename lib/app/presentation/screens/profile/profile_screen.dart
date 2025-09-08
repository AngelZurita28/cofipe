// lib/app/presentation/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/repositories/user_repository.dart';

// 1. Convierte el widget a un ConsumerWidget para acceder a los providers
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtenemos el usuario actual para mostrar su información
    final user = ref.watch(userRepositoryProvider).currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Has iniciado sesión como:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              user?.email ?? 'No se pudo cargar el email',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar Sesión'),
              onPressed: () {
                // 2. Llama al método signOut de nuestro repositorio
                ref.read(userRepositoryProvider).signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
