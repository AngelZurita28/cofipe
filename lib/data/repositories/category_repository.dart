import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category_model.dart';
import 'user_repository.dart'; // Import to access user and firestore providers

class CategoryRepository {
  final FirebaseFirestore _firestore;

  CategoryRepository(this._firestore);

  /// Obtiene un Stream con las categorías predeterminadas ('system') y
  /// las personalizadas del usuario actual.
  Stream<List<CategoryModel>> getCategoriesStream(String userId) {
    return _firestore
        .collection('categories')
        .where('userId', whereIn: ['system', userId])
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => CategoryModel.fromFirestore(doc))
              .toList();
        });
  }

  Stream<List<CategoryModel>> getGoalCategoriesStream(
    String userId,
    String parentCategoryId,
  ) {
    return _firestore
        .collection('categories')
        .where('userId', isEqualTo: userId)
        .where('isGoal', isEqualTo: true)
        .where('parentCategoryId', isEqualTo: parentCategoryId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => CategoryModel.fromFirestore(doc))
              .toList();
        });
  }

  Future<void> addCategory(CategoryModel category) async {
    try {
      // Usamos el método toMap() que ya habíamos creado en el modelo.
      await _firestore.collection('categories').add(category.toMap());
    } catch (e) {
      print("Error al añadir categoría: $e");
      throw Exception('No se pudo guardar la categoría.');
    }
  }
}

// --- Providers de Riverpod ---

/// Provider that creates an instance of our CategoryRepository.
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  // Depends on the firestoreProvider defined in user_repository.dart
  return CategoryRepository(ref.watch(firestoreProvider));
});

/// StreamProvider that builds and exposes the list of categories for the UI.
/// This is what our UI will listen to for real-time updates.
final categoriesStreamProvider = StreamProvider<List<CategoryModel>>((ref) {
  // Watches the user's authentication state.
  final user = ref.watch(userRepositoryProvider).currentUser;

  // If no user is logged in, return an empty stream.
  if (user == null) {
    return Stream.value([]);
  }

  // If a user is logged in, fetch their specific stream of categories.
  return ref.watch(categoryRepositoryProvider).getCategoriesStream(user.uid);
});

final goalCategoriesProvider =
    StreamProvider.family<List<CategoryModel>, String>((ref, parentCategoryId) {
      final user = ref.watch(userRepositoryProvider).currentUser;
      if (user == null) return Stream.value([]);
      return ref
          .watch(categoryRepositoryProvider)
          .getGoalCategoriesStream(user.uid, parentCategoryId);
    });
