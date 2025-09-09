import 'package:cloud_firestore/cloud_firestore.dart';

enum Frequency { weekly, biweekly, monthly, yearly }

class RecurringMovementModel {
  final String id;
  final String userId;
  final String categoryId;
  final double amount;
  final Frequency frequency;
  final DateTime nextDueDate;
  final bool isActive;

  RecurringMovementModel({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.amount,
    required this.frequency,
    required this.nextDueDate,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'categoryId': categoryId,
      'amount': amount,
      'frequency': frequency.name,
      'nextDueDate': Timestamp.fromDate(nextDueDate),
      'isActive': isActive,
    };
  }

  factory RecurringMovementModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return RecurringMovementModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      categoryId: data['categoryId'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      frequency: Frequency.values.firstWhere(
        (e) => e.name == data['frequency'],
        orElse: () => Frequency.monthly,
      ),
      nextDueDate: (data['nextDueDate'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
    );
  }
}
