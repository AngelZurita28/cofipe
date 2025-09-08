// lib/data/repositories/movement_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cofipe/data/repositories/user_repository.dart';

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
