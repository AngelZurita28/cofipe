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
    // This query efficiently gets all documents where the userId is either
    // the user's own ID or the special 'system' ID for default categories.
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

  // Future methods for adding, updating, or deleting categories will go here.
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
