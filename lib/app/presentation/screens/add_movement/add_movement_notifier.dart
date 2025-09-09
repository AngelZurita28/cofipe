import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../data/models/movement_model.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../data/repositories/movement_repository.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../data/repositories/goal_repository.dart';

class AddMovementState {
  final bool isLoading;
  final String? errorMessage;
  AddMovementState({this.isLoading = false, this.errorMessage});
}

class AddMovementNotifier extends StateNotifier<AddMovementState> {
  final MovementRepository _movementRepository;
  final GoalRepository _goalRepository;
  final UserRepository _userRepository;
  final Ref _ref; // Campo para guardar la referencia a Riverpod
  final User? _currentUser;

  AddMovementNotifier(
    this._movementRepository,
    this._goalRepository,
    this._currentUser,
    this._userRepository,
    this._ref, // Recibe la referencia en el constructor
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
      userId: _currentUser.uid,
      description: description,
      amount: amount,
      type: type,
      categoryId: categoryId,
      date: date,
      createdAt: DateTime.now(),
    );

    try {
      await _movementRepository.addMovement(newMovement);

      if (type == MovementType.income) {
        // Obtenemos las categorías usando el `_ref` que guardamos
        final allCategories = await _ref.read(categoriesStreamProvider.future);
        final selectedCategory = allCategories.firstWhere(
          (c) => c.id == categoryId,
        );

        // Si la categoría es una meta, actualizamos el progreso
        if (selectedCategory.isGoal) {
          final goal = await _goalRepository.getGoalForCategoryFuture(
            _currentUser.uid,
            categoryId,
          );
          if (goal != null) {
            await _goalRepository.updateGoalProgress(goal.id, amount);
          }
        }
      }
      await _userRepository.updateUserStreak();
      state = AddMovementState(isLoading: false);
      return true;
    } catch (e) {
      state = AddMovementState(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }
}

final addMovementNotifierProvider =
    StateNotifierProvider<AddMovementNotifier, AddMovementState>((ref) {
      final movementRepo = ref.watch(movementRepositoryProvider);
      final goalRepo = ref.watch(goalRepositoryProvider);
      final currentUser = ref.watch(userRepositoryProvider).currentUser;
      final userRepo = ref.watch(userRepositoryProvider);
      // Pasamos el 'ref' al constructor del notifier
      return AddMovementNotifier(
        movementRepo,
        goalRepo,
        currentUser,
        userRepo,
        ref,
      );
    });
