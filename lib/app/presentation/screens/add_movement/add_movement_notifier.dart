// lib/app/presentation/screens/add_movement/add_movement_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../data/models/movement_model.dart';
import '../../../../data/repositories/movement_repository.dart';
import '../../../../data/repositories/user_repository.dart';

// 1. Definir el estado que nuestro Notifier manejará
class AddMovementState {
  final bool isLoading;
  final String? errorMessage;

  AddMovementState({this.isLoading = false, this.errorMessage});
}

// 2. Crear el Notifier
class AddMovementNotifier extends StateNotifier<AddMovementState> {
  final MovementRepository _movementRepository;
  final User? _currentUser;

  AddMovementNotifier(this._movementRepository, this._currentUser)
    : super(AddMovementState());

  // Método para guardar el movimiento
  Future<bool> saveMovement({
    required String description,
    required double amount,
    required MovementType type,
    required String category,
    required DateTime date,
  }) async {
    // Validaciones básicas
    if (_currentUser == null) {
      state = AddMovementState(errorMessage: 'Usuario no autenticado.');
      return false;
    }
    if (description.isEmpty || amount <= 0) {
      state = AddMovementState(
        errorMessage: 'Descripción y monto son requeridos.',
      );
      return false;
    }

    // Iniciar el estado de carga
    state = AddMovementState(isLoading: true);

    // Crear el objeto del modelo
    final newMovement = MovementModel(
      id: '', // Firestore lo generará
      userId: _currentUser.uid,
      description: description,
      amount: amount,
      type: type,
      category: category,
      date: date,
      createdAt: DateTime.now(), // Se sobrescribe por el timestamp del servidor
    );

    try {
      await _movementRepository.addMovement(newMovement);
      state = AddMovementState(isLoading: false);
      return true; // Éxito
    } catch (e) {
      state = AddMovementState(isLoading: false, errorMessage: e.toString());
      return false; // Error
    }
  }
}

// 3. Crear el Provider para nuestro Notifier
final addMovementNotifierProvider =
    StateNotifierProvider<AddMovementNotifier, AddMovementState>((ref) {
      final movementRepository = ref.watch(movementRepositoryProvider);
      // Obtenemos el usuario actual para pasarlo al notifier
      final currentUser = ref.watch(userRepositoryProvider).currentUser;
      return AddMovementNotifier(movementRepository, currentUser);
    });
