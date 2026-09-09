import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/constants/collection_names.dart';
import '../models/user_model.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(CollectionNames.users);

  // ============================================================
  // CURRENT FIREBASE USER
  // ============================================================

  User? get currentUser => _auth.currentUser;

  // ============================================================
  // AUTH STATE
  // ============================================================

  Stream<User?> get authStateChanges =>
      _auth.authStateChanges();

  // ============================================================
  // GET CURRENT USER PROFILE
  // ============================================================

  Future<UserModel?> getCurrentUserProfile() async {
    final user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    final doc = await _users.doc(user.uid).get();

    if (!doc.exists) {
      return null;
    }

    return UserModel.fromFirestore(doc);
  }

  // ============================================================
  // REGISTER STUDENT
  // ============================================================

  Future<UserModel> registerStudent({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String city,
    String campus = '',
  }) async {
    final credential =
    await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final firebaseUser = credential.user;

    if (firebaseUser == null) {
      throw FirebaseAuthException(
        code: 'registration-failed',
        message: 'Unable to create user account.',
      );
    }

    await firebaseUser.updateDisplayName(
      name.trim(),
    );

    final userModel = UserModel(
      uid: firebaseUser.uid,
      name: name.trim(),
      phone: phone.trim(),
      email: email.trim(),
      role: 'student',
      city: city.trim(),
      campus: campus.trim(),
      createdAt: DateTime.now(),
    );

    await _users.doc(firebaseUser.uid).set(
      userModel.toFirestore(),
    );

    return userModel;
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final profile = await getCurrentUserProfile();

    if (profile == null) {
      throw Exception(
        'User profile was not found in Firestore.',
      );
    }

    return profile;
  }

  // ============================================================
  // SEND PASSWORD RESET EMAIL
  // ============================================================

  Future<void> sendPasswordResetEmail(
      String email,
      ) async {
    final trimmedEmail = email.trim();

    if (trimmedEmail.isEmpty) {
      throw FirebaseAuthException(
        code: 'invalid-email',
        message: 'Please enter your email address.',
      );
    }

    await _auth.sendPasswordResetEmail(
      email: trimmedEmail,
    );
  }

  // ============================================================
  // UPDATE PROFILE
  // ============================================================

  Future<void> updateProfile({
    required String name,
    required String city,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'User is not logged in.',
      );
    }

    final trimmedName = name.trim();
    final trimmedCity = city.trim();

    if (trimmedName.isEmpty) {
      throw Exception(
        'Name cannot be empty.',
      );
    }

    if (trimmedCity.isEmpty) {
      throw Exception(
        'City cannot be empty.',
      );
    }

    await user.updateDisplayName(
      trimmedName,
    );

    await _users.doc(user.uid).update({
      'name': trimmedName,
      'city': trimmedCity,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // UPDATE PROFILE PHOTO
  // ============================================================

  Future<void> updateProfilePhoto(
      String photoUrl,
      ) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'User is not logged in.',
      );
    }

    await _users.doc(user.uid).update({
      'photoUrl': photoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    await _auth.signOut();
  }
}