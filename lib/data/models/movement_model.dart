// lib/data/models/movement_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

// Enum para la seguridad de tipos en nuestro código Dart.
enum MovementType { income, expense }

class MovementModel {
  final String id;
  final String userId;
  final String description;
  final double amount;
  final MovementType type;
  final String category;
  final DateTime date;
  final DateTime createdAt;

  MovementModel({
    required this.id,
    required this.userId,
    required this.description,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    required this.createdAt,
  });

  /// Convierte un objeto MovementModel a un Map para Firestore.
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'description': description,
      'amount': amount,
      'type': type.name, // Guarda el enum como un String (e.g., 'income')
      'category': category,
      'date': Timestamp.fromDate(date), // Convierte DateTime a Timestamp
      'createdAt':
          FieldValue.serverTimestamp(), // Firestore pone la fecha del servidor
    };
  }

  /// Crea un objeto MovementModel desde un DocumentSnapshot de Firestore.
  factory MovementModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return MovementModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      description: data['description'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      // Convierte el String de Firestore de vuelta a un enum
      type: MovementType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => MovementType.expense, // Valor por defecto
      ),
      category: data['category'] ?? 'General',
      // Convierte el Timestamp de Firestore de vuelta a DateTime
      date: (data['date'] as Timestamp? ?? Timestamp.now()).toDate(),
      createdAt: (data['createdAt'] as Timestamp? ?? Timestamp.now()).toDate(),
    );
  }

  /// Método para crear una copia del objeto con valores actualizados.
  MovementModel copyWith({
    String? id,
    String? description,
    double? amount,
    MovementType? type,
    String? category,
    DateTime? date,
  }) {
    return MovementModel(
      id: id ?? this.id,
      userId: this.userId,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      createdAt: this.createdAt,
    );
  }
}
