// lib/app/presentation/screens/add_movement/add_movement_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../data/models/movement_model.dart';
import '../../../../data/repositories/movement_repository.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../data/repositories/goal_repository.dart'; // <-- 1. Import GoalRepository

// State class (no changes)
class AddMovementState {
  final bool isLoading;
  final String? errorMessage;
  AddMovementState({this.isLoading = false, this.errorMessage});
}

// The Notifier
class AddMovementNotifier extends StateNotifier<AddMovementState> {
  final MovementRepository _movementRepository;
  final GoalRepository _goalRepository; // <-- 2. Add GoalRepository dependency
  final User? _currentUser;

  AddMovementNotifier(
    this._movementRepository,
    this._goalRepository,
    this._currentUser,
  ) : super(AddMovementState());

  Future<bool> saveMovement({
    required String description,
    required double amount,
    required MovementType type,
    required String categoryId,
    required DateTime date,
  }) async {
    if (_currentUser == null) {
      state = AddMovementState(errorMessage: 'Error: Usuario no autenticado.');
      return false;
    }
    if (description.isEmpty || amount <= 0) {
      state = AddMovementState(
        errorMessage: 'La descripción y el monto son obligatorios.',
      );
      return false;
    }

    state = AddMovementState(isLoading: true);

    final newMovement = MovementModel(
      id: '',
      userId: _currentUser!.uid,
      description: description,
      amount: amount,
      type: type,
      categoryId: categoryId,
      date: date,
      createdAt: DateTime.now(),
    );

    try {
      // Step A: Save the new movement
      await _movementRepository.addMovement(newMovement);

      // --- 3. LOGIC TO UPDATE GOAL ---
      // Step B: If the movement was an income, check for goals in that category
      if (type == MovementType.income) {
        final goals = await _goalRepository.getGoalsByCategoryFuture(
          _currentUser!.uid,
          categoryId,
        );

        // Step C: If goals exist, update their progress
        for (final goal in goals) {
          await _goalRepository.updateGoalProgress(goal.id, amount);
        }
      }

      state = AddMovementState(isLoading: false);
      return true; // Success
    } catch (e) {
      state = AddMovementState(isLoading: false, errorMessage: e.toString());
      return false; // Error
    }
  }
}

// The Provider
final addMovementNotifierProvider =
    StateNotifierProvider<AddMovementNotifier, AddMovementState>((ref) {
      final movementRepository = ref.watch(movementRepositoryProvider);
      final goalRepository = ref.watch(
        goalRepositoryProvider,
      ); // <-- 4. Get GoalRepository
      final currentUser = ref.watch(userRepositoryProvider).currentUser;

      // <-- 5. Pass GoalRepository to the notifier
      return AddMovementNotifier(
        movementRepository,
        goalRepository,
        currentUser,
      );
    });
