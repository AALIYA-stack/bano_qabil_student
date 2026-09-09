import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
AuthService._();

static final AuthService instance = AuthService._();

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore =
FirebaseFirestore.instance;

// ============================================================
// REGISTER STUDENT
// ============================================================

Future<UserCredential> registerStudent({
required String name,
required String phone,
required String email,
required String password,
required String city,
}) async {
final UserCredential userCredential =
await _auth.createUserWithEmailAndPassword(
email: email.trim(),
password: password,
);

final User? user = userCredential.user;

if (user == null) {
throw FirebaseAuthException(
code: 'user-creation-failed',
message: 'Unable to create user account.',
);
}

final String uid = user.uid;

await _firestore.collection('users').doc(uid).set({
'uid': uid,
'name': name.trim(),
'email': email.trim(),
'phone': phone.trim(),
'city': city.trim(),
'role': 'student',
'isActive': true,
'createdAt': FieldValue.serverTimestamp(),
'updatedAt': FieldValue.serverTimestamp(),
});

return userCredential;
}

// ============================================================
// LOGIN STUDENT
// ============================================================

Future<UserCredential> login({
required String email,
required String password,
}) async {
return await _auth.signInWithEmailAndPassword(
email: email.trim(),
password: password,
);
}

// ============================================================
// PASSWORD RESET
// ============================================================

Future<void> sendPasswordResetEmail(String email) async {
await _auth.sendPasswordResetEmail(
email: email.trim(),
);
}

// ============================================================
// CURRENT USER
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

Future<DocumentSnapshot<Map<String, dynamic>>?>
getCurrentUserProfile() async {
final User? user = _auth.currentUser;

if (user == null) {
return null;
}

return await _firestore
    .collection('users')
    .doc(user.uid)
    .get();
}

// ============================================================
// LOGOUT
// ============================================================

Future<void> logout() async {
await _auth.signOut();
}
}


