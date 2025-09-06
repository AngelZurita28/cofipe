// lib/data/models/category_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String name;
  final String? userId; // Será 'system' para las predeterminadas

  CategoryModel({required this.id, required this.name, this.userId});

  factory CategoryModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return CategoryModel(
      id: doc.id,
      name: data['name'] ?? 'Sin nombre',
      userId: data['userId'],
    );
  }

  // Aún no necesitamos un toMap() porque no las crearemos desde la app.
}
