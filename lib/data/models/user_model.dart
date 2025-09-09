// lib/data/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id; // ID del documento en Firestore
  final String firebaseUid; // UID de Firebase Auth
  final String email;
  final String name;
  final String photoUrl;
  final DateTime createdAt;
  final String authProvider;
  final int streakCount;
  final DateTime? lastStreakUpdate;

  UserModel({
    required this.id,
    required this.firebaseUid,
    required this.email,
    required this.name,
    required this.photoUrl,
    required this.createdAt,
    this.streakCount = 0, // Default to 0 for new users
    this.lastStreakUpdate,
    required this.authProvider,
  });

  /// Convierte un objeto UserModel a un Map para Firestore.
  Map<String, dynamic> toMap() {
    return {
      'firebaseUid': firebaseUid,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'createdAt':
          FieldValue.serverTimestamp(), // Usa el timestamp del servidor al crear
      'authProvider': authProvider,
    };
  }

  /// Crea un objeto UserModel desde un DocumentSnapshot de Firestore.
  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserModel(
      id: doc.id,
      firebaseUid: data['firebaseUid'] ?? '',
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      createdAt: (data['createdAt'] as Timestamp? ?? Timestamp.now()).toDate(),
      streakCount: data['streakCount'] ?? 0,
      lastStreakUpdate: (data['lastStreakUpdate'] as Timestamp?)?.toDate(),
      authProvider: data['authProvider'] ?? 'unknown',
    );
  }

  /// Método para crear una copia del objeto con valores actualizados (inmutabilidad).
  UserModel copyWith({String? id, String? name, String? photoUrl}) {
    return UserModel(
      id: id ?? this.id,
      firebaseUid: firebaseUid,
      email: email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt,
      streakCount: streakCount,
      lastStreakUpdate: lastStreakUpdate,
      authProvider: authProvider,
    );
  }
}
