import 'package:cloud_firestore/cloud_firestore.dart';
import 'movement_model.dart';

class CategoryModel {
  final String id;
  final String name;
  final String? userId;
  final MovementType type;
  final String iconAssetName;

  // --- CAMPOS NUEVOS PARA METAS ---
  final bool isGoal;
  final String? parentCategoryId;
  final String status; // 'active', 'completed'

  CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.iconAssetName,
    this.userId,
    this.isGoal = false, // Por defecto, una categoría no es una meta
    this.parentCategoryId,
    this.status = 'active',
  });

  factory CategoryModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return CategoryModel(
      id: doc.id,
      name: data['name'] ?? 'Sin nombre',
      userId: data['userId'],
      type: MovementType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => MovementType.expense,
      ),
      iconAssetName: data['iconAssetName'] ?? 'default-icon.svg',
      isGoal: data['isGoal'] ?? false,
      parentCategoryId: data['parentCategoryId'],
      status: data['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'userId': userId,
      'type': type.name,
      'iconAssetName': iconAssetName,
      'isGoal': isGoal,
      'parentCategoryId': parentCategoryId,
      'status': status,
    };
  }
}
