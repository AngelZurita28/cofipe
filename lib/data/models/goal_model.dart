import 'package:cloud_firestore/cloud_firestore.dart';

class GoalModel {
  final String id;
  final String userId;
  final String
  categoryId; // Vínculo con la CategoryModel que tiene isGoal: true
  final double targetAmount;
  final double savedAmount;

  GoalModel({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.targetAmount,
    this.savedAmount = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'categoryId': categoryId,
      'targetAmount': targetAmount,
      'savedAmount': savedAmount,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory GoalModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return GoalModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      categoryId: data['categoryId'] ?? '',
      targetAmount: (data['targetAmount'] ?? 0.0).toDouble(),
      savedAmount: (data['savedAmount'] ?? 0.0).toDouble(),
    );
  }
}
