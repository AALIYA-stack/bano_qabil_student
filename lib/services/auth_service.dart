import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/constants/collection_names.dart';
import '../models/user_model.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection(CollectionNames.users);

  // ADDED: one document per campus; existence of the doc means
  // that campus's coordinator slot is taken.
  CollectionReference<Map<String, dynamic>> get _coordinatorSlots =>
      _firestore.collection('coordinatorSlots');

  // ============================================================
  // CURRENT FIREBASE USER
  // ============================================================

  User? get currentUser => _auth.currentUser;

  // ============================================================
  // AUTH STATE
  // ============================================================

  Stream<User?> get authStateChanges => _auth.authStateChanges();

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
  // CHECK IF A COORDINATOR ALREADY EXISTS FOR A CAMPUS
  // ============================================================
  // NOTE: requires the caller to be signed in (Firestore rules
  // require isSignedIn() to read coordinatorSlots). Useful for
  // showing this info elsewhere (e.g. an admin screen) -- the
  // signup flow itself no longer calls this before creating the
  // account; it claims the slot atomically inside registerUser
  // instead, since a pre-check while signed out is not possible
  // and is not safe against race conditions anyway.

  Future<bool> coordinatorExistsForCampus(String campus) async {
    final trimmedCampus = campus.trim();

    if (trimmedCampus.isEmpty) {
      return false;
    }

    final doc = await _coordinatorSlots.doc(trimmedCampus).get();

    return doc.exists;
  }

  // ============================================================
  // REGISTER USER
  // ============================================================

  Future<UserModel> registerUser({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String city,
    required String role,
    String campus = '',
  }) async {
    UserCredential? credential;

    // ADDED: tracks whether the Firestore /users doc was written,
    // so we know to roll it back if a later step fails.
    bool firestoreUserCreated = false;

    try {
      credential = await _auth.createUserWithEmailAndPassword(
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

      await firebaseUser.updateDisplayName(name.trim());

      final normalizedRole = role.trim().toLowerCase();
      final trimmedCampus = campus.trim();

      final userModel = UserModel(
        uid: firebaseUser.uid,
        name: name.trim(),
        phone: phone.trim(),
        email: email.trim(),
        role: normalizedRole,
        city: city.trim(),
        campus: trimmedCampus,
        createdAt: DateTime.now(),
      );

      await _users.doc(firebaseUser.uid).set(userModel.toFirestore());

      firestoreUserCreated = true;

      // ==========================================================
      // ADDED: COORDINATOR UNIQUENESS (atomic claim)
      // Only after the user is signed in can we touch
      // coordinatorSlots (Firestore rules require isSignedIn()).
      // The `create` rule for coordinatorSlots only succeeds if
      // nobody already holds this campus's slot, so this is
      // race-safe even if two people submit signup at once.
      // ==========================================================

      if (normalizedRole == 'coordinator') {
        if (trimmedCampus.isEmpty) {
          throw Exception('Campus is required for a coordinator account.');
        }

        try {
          await _coordinatorSlots.doc(trimmedCampus).set({
            'uid': firebaseUser.uid,
            'campus': trimmedCampus,
            'assignedAt': FieldValue.serverTimestamp(),
          });
        } catch (_) {
          // Slot was already taken (or another error) -- surface a
          // clear, specific message. The outer catch below will
          // roll back the user doc + auth account.
          throw Exception('A coordinator already exists for this campus.');
        }
      }

      return userModel;
    } catch (e) {
      // ADDED: roll back the Firestore user doc if it was created.
      if (firestoreUserCreated && credential?.user != null) {
        try {
          await _users.doc(credential!.user!.uid).delete();
        } catch (_) {
          // Best-effort cleanup; ignore secondary failures here.
        }
      }

      if (credential?.user != null) {
        await credential!.user!.delete();
      }

      rethrow;
    }
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
      throw Exception('User profile was not found in Firestore.');
    }

    return profile;
  }

  // ============================================================
  // SEND PASSWORD RESET EMAIL
  // ============================================================

  Future<void> sendPasswordResetEmail(String email) async {
    final trimmedEmail = email.trim();

    if (trimmedEmail.isEmpty) {
      throw FirebaseAuthException(
        code: 'invalid-email',
        message: 'Please enter your email address.',
      );
    }

    await _auth.sendPasswordResetEmail(email: trimmedEmail);
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
      throw Exception('User is not logged in.');
    }

    final trimmedName = name.trim();
    final trimmedCity = city.trim();

    if (trimmedName.isEmpty) {
      throw Exception('Name cannot be empty.');
    }

    if (trimmedCity.isEmpty) {
      throw Exception('City cannot be empty.');
    }

    await user.updateDisplayName(trimmedName);

    await _users.doc(user.uid).update({
      'name': trimmedName,
      'city': trimmedCity,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // UPDATE PROFILE PHOTO
  // ============================================================

  Future<void> updateProfilePhoto(String photoUrl) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
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
