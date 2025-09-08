// lib/data/repositories/goal_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/goal_model.dart';
import 'user_repository.dart'; // For firestoreProvider and userRepositoryProvider

class GoalRepository {
  final FirebaseFirestore _firestore;

  GoalRepository(this._firestore);

  CollectionReference<Map<String, dynamic>> get _goals =>
      _firestore.collection('goals');

  /// Adds a new goal to Firestore.
  Future<void> addGoal(GoalModel goal) async {
    try {
      await _goals.add(goal.toMap());
    } catch (e) {
      throw Exception('No se pudo guardar la meta.');
    }
  }

  /// Fetches a real-time stream of goals for a specific category.
  Stream<List<GoalModel>> getGoalsByCategoryStream(
    String userId,
    String categoryId,
  ) {
    return _goals
        .where('userId', isEqualTo: userId)
        .where('categoryId', isEqualTo: categoryId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => GoalModel.fromFirestore(doc)).toList(),
        );
  }

  /// Updates the saved amount for a specific goal.
  Future<void> updateGoalProgress(
    String goalId,
    double additionalAmount,
  ) async {
    try {
      // Use FieldValue.increment() for safe, atomic updates.
      await _goals.doc(goalId).update({
        'savedAmount': FieldValue.increment(additionalAmount),
      });
    } catch (e) {
      throw Exception('No se pudo actualizar el progreso de la meta.');
    }
  }

  Future<List<GoalModel>> getGoalsByCategoryFuture(
    String userId,
    String categoryId,
  ) async {
    final snapshot = await _goals
        .where('userId', isEqualTo: userId)
        .where('categoryId', isEqualTo: categoryId)
        .get();
    return snapshot.docs.map((doc) => GoalModel.fromFirestore(doc)).toList();
  }
}

// --- Providers for Riverpod ---

/// Provider for the GoalRepository instance.
final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  return GoalRepository(ref.watch(firestoreProvider));
});

/// A StreamProvider Family to get goals for a specific category.
/// This is what the UI will use.
final goalsByCategoryProvider = StreamProvider.family<List<GoalModel>, String>((
  ref,
  categoryId,
) {
  final user = ref.watch(userRepositoryProvider).currentUser;
  if (user == null) {
    return Stream.value([]);
  }

  return ref
      .watch(goalRepositoryProvider)
      .getGoalsByCategoryStream(user.uid, categoryId);
});
