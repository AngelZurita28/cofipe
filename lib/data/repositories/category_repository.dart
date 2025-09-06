// lib/data/repositories/category_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_repository.dart';
import 'movement_repository.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final FirebaseFirestore _firestore;

  CategoryRepository(this._firestore);

  /// Obtiene un Stream con las categorías predeterminadas ('system') y
  /// las personalizadas del usuario actual.
  Stream<List<CategoryModel>> getCategoriesStream(String userId) {
    // Realizamos una consulta "OR" usando el operador 'whereIn'.
    // Firestore es muy eficiente para este tipo de consultas.
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
}

// Provider para nuestro CategoryRepository
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(ref.watch(firestoreProvider));
});

// StreamProvider que construye y expone la lista de categorías para la UI.
final categoriesStreamProvider = StreamProvider<List<CategoryModel>>((ref) {
  // Observa el estado del usuario. Si cambia, el stream se reconstruirá.
  final user = ref.watch(userRepositoryProvider).currentUser;

  // Si no hay usuario, devuelve un stream vacío.
  if (user == null) {
    return Stream.value([]);
  }

  // Si hay un usuario, obtiene su stream de categorías.
  return ref.watch(categoryRepositoryProvider).getCategoriesStream(user.uid);
});
