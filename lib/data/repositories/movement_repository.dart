// lib/data/repositories/movement_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cofipe/data/repositories/user_repository.dart';
import '../models/recurring_movement_model.dart';
import '../models/movement_model.dart';

class MovementRepository {
  final FirebaseFirestore _firestore;

  MovementRepository(this._firestore);

  CollectionReference<Map<String, dynamic>> get _movements =>
      _firestore.collection('movements');

  Future<void> addMovement(MovementModel movement) async {
    try {
      await _movements.add(movement.toMap());
    } catch (e) {
      print("Error al añadir movimiento: $e");
      throw Exception('No se pudo guardar el movimiento.');
    }
  }

  // --- MÉTODO NUEVO PARA LEER MOVIMIENTOS ---
  /// Obtiene un Stream con la lista de movimientos de un usuario,
  Stream<List<MovementModel>> getMovementsStream(String userId) {
    return _movements
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => MovementModel.fromFirestore(doc))
              .toList();
        });
  }

  Stream<List<MovementModel>> getMovementsByCategoryStream(
    String userId,
    String categoryId,
  ) {
    return _movements
        .where('userId', isEqualTo: userId)
        .where('categoryId', isEqualTo: categoryId) // <-- El filtro clave
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => MovementModel.fromFirestore(doc))
              .toList();
        });
  }

  CollectionReference<Map<String, dynamic>> get _recurringMovements =>
      _firestore.collection('recurring_movements');

  /// Guarda o actualiza un movimiento recurrente para una categoría.
  Future<void> setRecurringMovement(RecurringMovementModel model) async {
    // Usamos el categoryId como ID del documento para asegurar que solo haya uno por categoría.
    await _recurringMovements.doc(model.categoryId).set(model.toMap());
  }

  /// Obtiene el movimiento recurrente configurado para una categoría.
  Stream<RecurringMovementModel?> getRecurringMovementForCategoryStream(
    String userId,
    String categoryId,
  ) {
    return _recurringMovements.doc(categoryId).snapshots().map((snapshot) {
      if (snapshot.exists) {
        return RecurringMovementModel.fromFirestore(
          snapshot as DocumentSnapshot<Map<String, dynamic>>,
        );
      }
      return null;
    });
  }
}

// --- Providers de Riverpod ---

// Provider para MovementRepository
final movementRepositoryProvider = Provider<MovementRepository>((ref) {
  return MovementRepository(ref.watch(firestoreProvider));
});

// --- PROVIDER NUEVO PARA EL STREAM DE MOVIMIENTOS ---
final movementsStreamProvider = StreamProvider<List<MovementModel>>((ref) {
  final user = ref.watch(userRepositoryProvider).currentUser;
  if (user == null) {
    return Stream.value([]);
  }
  final movementRepo = ref.watch(movementRepositoryProvider);
  return movementRepo.getMovementsStream(user.uid);
});

// Provider para obtener movimientos por categoría
final movementsByCategoryProvider =
    StreamProvider.family<List<MovementModel>, String>((ref, categoryId) {
      final user = ref.watch(userRepositoryProvider).currentUser;
      if (user == null) return Stream.value([]);

      final movementRepo = ref.watch(movementRepositoryProvider);
      return movementRepo.getMovementsByCategoryStream(user.uid, categoryId);
    });

final lastMonthMovementsProvider = StreamProvider<List<MovementModel>>((ref) {
  final user = ref.watch(userRepositoryProvider).currentUser;
  if (user == null) {
    return Stream.value([]);
  }

  // Calcula la fecha de inicio (hace 30 días)
  final startDate = DateTime.now().subtract(const Duration(days: 30));

  // Llama al stream de todos los movimientos y filtra los resultados por fecha
  return ref.watch(movementRepositoryProvider).getMovementsStream(user.uid).map(
    (movements) {
      return movements.where((m) => m.date.isAfter(startDate)).toList();
    },
  );
});

final recurringMovementProvider =
    StreamProvider.family<RecurringMovementModel?, String>((ref, categoryId) {
      final user = ref.watch(userRepositoryProvider).currentUser;
      if (user == null) return Stream.value(null);
      return ref
          .watch(movementRepositoryProvider)
          .getRecurringMovementForCategoryStream(user.uid, categoryId);
    });
