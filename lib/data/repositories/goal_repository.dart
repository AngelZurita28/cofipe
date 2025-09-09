import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category_model.dart';
import '../models/goal_model.dart';
import 'user_repository.dart';

class GoalRepository {
  final FirebaseFirestore _firestore;
  GoalRepository(this._firestore);

  CollectionReference<Map<String, dynamic>> get _goals =>
      _firestore.collection('goals');
  CollectionReference<Map<String, dynamic>> get _categories =>
      _firestore.collection('categories');

  /// Crea una nueva meta, lo que implica crear una categoría de tipo "meta"
  /// y un documento de "goal" para llevar el progreso.
  Future<void> createGoalCategory({
    required CategoryModel goalCategory,
    required double targetAmount,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    // Acción 1: Crear el documento de la categoría-meta
    final categoryDoc = await _categories.add(goalCategory.toMap());

    // Acción 2: Crear el documento del progreso de la meta
    final newGoal = GoalModel(
      id: '', // Firestore lo genera
      userId: user.uid,
      categoryId:
          categoryDoc.id, // Vinculamos con el ID de la categoría recién creada
      targetAmount: targetAmount,
    );
    await _goals.add(newGoal.toMap());
  }

  /// Obtiene el documento de progreso de una meta específica.
  Future<GoalModel?> getGoalForCategoryFuture(
    String userId,
    String categoryId,
  ) async {
    final snapshot = await _goals
        .where('userId', isEqualTo: userId)
        .where('categoryId', isEqualTo: categoryId)
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    return GoalModel.fromFirestore(snapshot.docs.first);
  }

  /// Obtiene un stream con el progreso de las metas para una categoría específica.
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

  /// Actualiza el progreso de ahorro de una meta.
  Future<void> updateGoalProgress(
    String goalId,
    double additionalAmount,
  ) async {
    await _goals.doc(goalId).update({
      'savedAmount': FieldValue.increment(additionalAmount),
    });
  }
}

// --- Providers ---
final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  return GoalRepository(ref.watch(firestoreProvider));
});

final goalsByCategoryProvider = StreamProvider.family<List<GoalModel>, String>((
  ref,
  categoryId,
) {
  final user = ref.watch(userRepositoryProvider).currentUser;
  if (user == null) return Stream.value([]);
  return ref
      .watch(goalRepositoryProvider)
      .getGoalsByCategoryStream(user.uid, categoryId);
});
