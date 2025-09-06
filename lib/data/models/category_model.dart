// lib/data/models/category_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'movement_model.dart';

class CategoryModel {
  final String id;
  final String name;
  final String? userId;
  final MovementType type; // Será 'system' para las predeterminadas

  CategoryModel({
    required this.id,
    required this.type,
    required this.name,
    this.userId,
  });

  factory CategoryModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return CategoryModel(
      id: doc.id,
      name: data['name'] ?? 'Sin nombre',
      userId: data['userId'],
      // Leemos el tipo desde Firestore y lo convertimos de String a enum
      type: MovementType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => MovementType.expense, // Gasto por defecto
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'userId': userId,
      'type': type.name, // Guarda el enum como String ('income' o 'expense')
    };
  }
}
