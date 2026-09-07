import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class AuthService {
AuthService._();

static final AuthService instance = AuthService._();

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// ============================================================
// CURRENT USER
// ============================================================

User? get currentUser => _auth.currentUser;

String? get currentUid => _auth.currentUser?.uid;

bool get isLoggedIn => _auth.currentUser != null;

// ============================================================
// AUTH STATE
// ============================================================

Stream<User?> get authStateChanges {
return _auth.authStateChanges();
}

// ============================================================
// GET USER PROFILE
// ============================================================

Future<UserModel?> getUserProfile(String uid) async {
if (uid.trim().isEmpty) {
return null;
}

final document = await _firestore
    .collection('users')
    .doc(uid)
    .get();

if (!document.exists || document.data() == null) {
return null;
}

return UserModel.fromFirestore(
document.data()!,
document.id,
);
}

// ============================================================
// CURRENT USER PROFILE
// ============================================================

Future<UserModel?> getCurrentUserProfile() async {
final uid = currentUid;

if (uid == null) {
return null;
}

return getUserProfile(uid);
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
}) async {
final credential = await _auth.createUserWithEmailAndPassword(
email: email.trim(),
password: password,
);

final user = credential.user;

if (user == null) {
throw FirebaseAuthException(
code: 'user-not-created',
message: 'Unable to create user account.',
);
}

final userModel = UserModel(
uid: user.uid,
name: name.trim(),
phone: phone.trim(),
email: email.trim(),
role: 'student',
city: city.trim(),
campus: '',
photoUrl: null,
createdAt: DateTime.now(),
courseId: null,
batchId: null,
);

try {
await _firestore
    .collection('users')
    .doc(user.uid)
    .set(
userModel.toFirestore(),
);

return userModel;
} catch (e) {
// If Firestore profile creation fails,
// remove the newly created Firebase Auth account.
await user.delete();
rethrow;
}
}

// ============================================================
// LOGIN
// ============================================================

Future<UserCredential> login({
required String email,
required String password,
}) async {
return _auth.signInWithEmailAndPassword(
email: email.trim(),
password: password,
);
}

// ============================================================
// LOGOUT
// ============================================================

Future<void> logout() async {
await _auth.signOut();
}

// ============================================================
// PASSWORD RESET
// ============================================================

Future<void> sendPasswordResetEmail(
String email,
) async {
await _auth.sendPasswordResetEmail(
email: email.trim(),
);
}

// ============================================================
// UPDATE PROFILE
// ============================================================

Future<void> updateProfile({
String? name,
String? city,
}) async {
final uid = currentUid;

if (uid == null) {
throw Exception('User is not logged in.');
}

final Map<String, dynamic> data = {};

if (name != null) {
data['name'] = name.trim();
}

if (city != null) {
data['city'] = city.trim();
}

if (data.isEmpty) {
return;
}

await _firestore
    .collection('users')
    .doc(uid)
    .update(data);
}

// ============================================================
// UPDATE PROFILE PHOTO
// ============================================================

Future<void> updateProfilePhoto(
String photoUrl,
) async {
final uid = currentUid;

if (uid == null) {
throw Exception('User is not logged in.');
}

await _firestore
    .collection('users')
    .doc(uid)
    .update({
'photoUrl': photoUrl,
});
}

// ============================================================
// UPDATE ACADEMIC INFORMATION
// ============================================================

Future<void> updateAcademicInfo({
String? campus,
String? courseId,
String? batchId,
}) async {
final uid = currentUid;

if (uid == null) {
throw Exception('User is not logged in.');
}

final Map<String, dynamic> data = {};

if (campus != null) {
data['campus'] = campus;
}

if (courseId != null) {
data['courseId'] = courseId;
}

if (batchId != null) {
data['batchId'] = batchId;
}

if (data.isEmpty) {
return;
}

await _firestore
    .collection('users')
    .doc(uid)
    .update(data);
}

// ============================================================
// DELETE ACCOUNT
// ============================================================

Future<void> deleteCurrentAccount() async {
final user = currentUser;

if (user == null) {
return;
}

await _firestore
    .collection('users')
    .doc(user.uid)
    .delete();

await user.delete();
}
}
