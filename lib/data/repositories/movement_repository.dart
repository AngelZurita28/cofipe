// lib/data/repositories/movement_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_repository.dart';
import '../models/movement_model.dart';

class MovementRepository {
  final FirebaseFirestore _firestore;

  MovementRepository(this._firestore);

  // Referencia a la colección de movimientos
  CollectionReference<Map<String, dynamic>> get _movements =>
      _firestore.collection('movements');

  /// Añade un nuevo documento de movimiento a Firestore.
  Future<void> addMovement(MovementModel movement) async {
    try {
      // Usamos el método toMap() de nuestro modelo para convertir el objeto a un formato
      // que Firestore pueda entender y lo añadimos a la colección.
      await _movements.add(movement.toMap());
    } catch (e) {
      // Es una buena práctica manejar errores específicos y relanzarlos
      // como una excepción más clara si es necesario.
      print("Error al añadir movimiento: $e");
      throw Exception('No se pudo guardar el movimiento.');
    }
  }

  // Aquí irían otros métodos en el futuro, como:
  // - getMovements(String userId)
  // - updateMovement(MovementModel movement)
  // - deleteMovement(String movementId)
}

// --- Providers de Riverpod ---

// Provider para la instancia de Firestore

// Provider para nuestro MovementRepository
// Este leerá el firestoreProvider para obtener su dependencia.
final movementRepositoryProvider = Provider<MovementRepository>((ref) {
  return MovementRepository(ref.watch(firestoreProvider));
});
