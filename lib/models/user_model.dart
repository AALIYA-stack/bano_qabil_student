import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
final String uid;
final String name;
final String phone;
final String email;
final String role;
final String city;
final String campus;
final String? photoUrl;
final DateTime? createdAt;
final String? courseId;
final String? batchId;

const UserModel({
required this.uid,
required this.name,
required this.phone,
required this.email,
required this.role,
required this.city,
required this.campus,
this.photoUrl,
this.createdAt,
this.courseId,
this.batchId,
});

// ============================================================
// FIRESTORE -> USER MODEL
// ============================================================

factory UserModel.fromFirestore(
Map<String, dynamic> data,
String documentId,
) {
DateTime? createdAt;

final createdAtData = data['createdAt'];

if (createdAtData is Timestamp) {
createdAt = createdAtData.toDate();
}

return UserModel(
uid: data['uid'] ?? documentId,
name: data['name'] ?? '',
phone: data['phone'] ?? '',
email: data['email'] ?? '',
role: data['role'] ?? 'student',
city: data['city'] ?? '',
campus: data['campus'] ?? '',
photoUrl: data['photoUrl'],
createdAt: createdAt,
courseId: data['courseId'],
batchId: data['batchId'],
);
}

// ============================================================
// USER MODEL -> FIRESTORE
// ============================================================

Map<String, dynamic> toFirestore() {
return {
'uid': uid,
'name': name,
'phone': phone,
'email': email,
'role': role,
'city': city,
'campus': campus,
'photoUrl': photoUrl,
'createdAt': createdAt == null
? FieldValue.serverTimestamp()
    : Timestamp.fromDate(createdAt!),
'courseId': courseId,
'batchId': batchId,
};
}
}

