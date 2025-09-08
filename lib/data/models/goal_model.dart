// lib/data/models/goal_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class GoalModel {
  final String id;
  final String userId;
  final String categoryId;
  final String name;
  final double targetAmount;
  final double savedAmount;

  GoalModel({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.name,
    required this.targetAmount,
    this.savedAmount = 0.0,
  });

  /// Converts a GoalModel object to a Map for Firestore.
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'categoryId': categoryId,
      'name': name,
      'targetAmount': targetAmount,
      'savedAmount': savedAmount,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  /// Creates a GoalModel object from a Firestore DocumentSnapshot.
  factory GoalModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return GoalModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      categoryId: data['categoryId'] ?? '',
      name: data['name'] ?? 'Sin nombre',
      targetAmount: (data['targetAmount'] ?? 0.0).toDouble(),
      savedAmount: (data['savedAmount'] ?? 0.0).toDouble(),
    );
  }

  /// Creates a copy of the object with updated values.
  GoalModel copyWith({double? savedAmount}) {
    return GoalModel(
      id: this.id,
      userId: this.userId,
      categoryId: this.categoryId,
      name: this.name,
      targetAmount: this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
    );
  }
}
