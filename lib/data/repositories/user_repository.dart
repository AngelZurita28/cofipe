// lib/data/repositories/user_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart'; // <-- LA IMPORTACIÓN CLAVE QUE FALTABA

class UserRepository {
  final auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  UserRepository({
    auth.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? auth.FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn(),
       _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  auth.User? get currentUser => _firebaseAuth.currentUser;

  Stream<auth.User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final auth.OAuthCredential credential =
          auth.GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
      final auth.UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);
      final auth.User? firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw Exception("Inicio de sesión con Firebase falló.");
      }

      return await _createOrUpdateUserInFirestore(firebaseUser);
    } catch (e) {
      print("Error en signInWithGoogle: $e");
      await _googleSignIn.signOut();
      throw Exception("Ocurrió un error durante el inicio de sesión.");
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  Future<UserModel> _createOrUpdateUserInFirestore(
    auth.User firebaseUser,
  ) async {
    final querySnapshot = await _usersCollection
        .where('firebaseUid', isEqualTo: firebaseUser.uid)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final userDoc = querySnapshot.docs.first;
      await userDoc.reference.update({
        'name': firebaseUser.displayName ?? '',
        'photoUrl': firebaseUser.photoURL ?? '',
      });
      return UserModel.fromFirestore(userDoc);
    } else {
      final newUser = UserModel(
        id: '',
        firebaseUid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: firebaseUser.displayName ?? 'Usuario',
        photoUrl: firebaseUser.photoURL ?? '',
        createdAt: DateTime.now(),
        authProvider: firebaseUser.providerData.first.providerId,
      );
      final docRef = await _usersCollection.add(newUser.toMap());
      return newUser.copyWith(id: docRef.id);
    }
  }

  Future<UserModel?> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // 1. Crea el usuario en Firebase Authentication.
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw Exception("No se pudo crear el usuario en Firebase.");
      }

      // 2. Actualiza el perfil de Firebase para incluir el nombre.
      // Esto es importante para que la información esté consistente.
      await firebaseUser.updateDisplayName(name);

      // 3. Crea nuestro documento de usuario en Firestore.
      // Reutilizamos el mismo método que con Google para mantener la consistencia.
      return await _createOrUpdateUserInFirestore(firebaseUser);
    } on auth.FirebaseAuthException catch (e) {
      // Maneja errores específicos de Firebase (ej. contraseña débil, email en uso)
      print("Error de FirebaseAuth al registrar: ${e.code}");
      throw Exception(e.message); // Lanza el mensaje de error de Firebase
    } catch (e) {
      print("Error inesperado al registrar: $e");
      throw Exception("Ocurrió un error inesperado durante el registro.");
    }
  }

  // --- MÉTODO NUEVO PARA INICIAR SESIÓN ---
  /// Inicia sesión de un usuario existente con correo y contraseña.
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Simplemente iniciamos sesión. No necesitamos crear un documento en Firestore
      // porque ya debería existir. El `authStateChanges` se encargará del resto.
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on auth.FirebaseAuthException catch (e) {
      // Maneja errores específicos (ej. usuario no encontrado, contraseña incorrecta)
      print("Error de FirebaseAuth al iniciar sesión: ${e.code}");
      throw Exception(e.message); // Lanza el mensaje de error de Firebase
    } catch (e) {
      print("Error inesperado al iniciar sesión: $e");
      throw Exception("Ocurrió un error inesperado al iniciar sesión.");
    }
  }

  Future<void> updateUserStreak() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    // Get the user's document from Firestore
    final userDoc = await _usersCollection
        .where('firebaseUid', isEqualTo: user.uid)
        .limit(1)
        .get();
    if (userDoc.docs.isEmpty) return;

    final userModel = UserModel.fromFirestore(userDoc.docs.first);
    final docRef = userDoc.docs.first.reference;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (userModel.lastStreakUpdate == null) {
      // First-ever streak update
      await docRef.update({
        'streakCount': 1,
        'lastStreakUpdate': Timestamp.now(),
      });
    } else {
      final lastUpdate = userModel.lastStreakUpdate!;
      final lastUpdateDate = DateTime(
        lastUpdate.year,
        lastUpdate.month,
        lastUpdate.day,
      );

      if (today.isAtSameMomentAs(lastUpdateDate)) {
        // Already updated today, do nothing.
        return;
      } else if (today.difference(lastUpdateDate).inDays == 1) {
        // It's a new consecutive day, increment the streak.
        await docRef.update({
          'streakCount': FieldValue.increment(1),
          'lastStreakUpdate': Timestamp.now(),
        });
      } else {
        // Missed a day, reset the streak.
        await docRef.update({
          'streakCount': 1,
          'lastStreakUpdate': Timestamp.now(),
        });
      }
    }
  }
}

final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});
final userModelStreamProvider = StreamProvider<UserModel?>((ref) {
  final userRepo = ref.watch(userRepositoryProvider);
  if (userRepo.currentUser == null) return Stream.value(null);

  return userRepo._usersCollection
      .where('firebaseUid', isEqualTo: userRepo.currentUser!.uid)
      .limit(1)
      .snapshots()
      .map((snapshot) {
        if (snapshot.docs.isEmpty) return null;
        return UserModel.fromFirestore(snapshot.docs.first);
      });
});
