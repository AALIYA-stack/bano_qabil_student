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
  final String? courseId;
  final String? batchId;
  final DateTime? createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
    required this.city,
    required this.campus,
    this.photoUrl,
    this.courseId,
    this.batchId,
    this.createdAt,
  });

  factory UserModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data() ?? {};

    return UserModel(
      uid: doc.id,
      name: data['name']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      role: data['role']?.toString() ?? 'student',
      city: data['city']?.toString() ?? '',
      campus: data['campus']?.toString() ?? '',
      photoUrl: data['photoUrl']?.toString(),
      courseId: data['courseId']?.toString(),
      batchId: data['batchId']?.toString(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'role': role,
      'city': city,
      'campus': campus,
      'photoUrl': photoUrl,
      'courseId': courseId,
      'batchId': batchId,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}