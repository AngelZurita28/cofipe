// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/config/router/app_router.dart';
import 'app/config/theme/app_theme.dart'; // <-- 1. Importa el tema

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);

    return MaterialApp.router(
      routerConfig: goRouter,
      title: 'Finanzas Personales',
      theme: AppTheme.getTheme(), // <-- 2. Aplica el tema aquí
      debugShowCheckedModeBanner: false,
    );
  }
}
