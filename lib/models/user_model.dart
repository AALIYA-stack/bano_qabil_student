import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
final String uid;
final String name;
final String phone;
final String email;
final String role;
final String city;
final String campus;
final bool isActive;
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
this.isActive = true,
this.photoUrl,
this.courseId,
this.batchId,
this.createdAt,
});

factory UserModel.fromFirestore(
DocumentSnapshot<Map<String, dynamic>> doc,
) {
final data = doc.data() ?? <String, dynamic>{};

DateTime? parsedCreatedAt;

final createdAtValue = data['createdAt'];

if (createdAtValue is Timestamp) {
parsedCreatedAt = createdAtValue.toDate();
} else if (createdAtValue is DateTime) {
parsedCreatedAt = createdAtValue;
} else if (createdAtValue is String) {
parsedCreatedAt = DateTime.tryParse(createdAtValue);
}

return UserModel(
uid: doc.id,
name: data['name']?.toString() ?? '',
phone: data['phone']?.toString() ?? '',
email: data['email']?.toString() ?? '',
role: data['role']?.toString() ?? 'student',
city: data['city']?.toString() ?? '',
campus: data['campus']?.toString() ?? '',
isActive: data['isActive'] is bool
? data['isActive'] as bool
    : true,
photoUrl: data['photoUrl']?.toString(),
courseId: data['courseId']?.toString(),
batchId: data['batchId']?.toString(),
createdAt: parsedCreatedAt,
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
'isActive': isActive,
'photoUrl': photoUrl,
'courseId': courseId,
'batchId': batchId,
'createdAt': createdAt != null
? Timestamp.fromDate(createdAt!)
    : FieldValue.serverTimestamp(),
};
}

UserModel copyWith({
String? uid,
String? name,
String? phone,
String? email,
String? role,
String? city,
String? campus,
bool? isActive,
String? photoUrl,
String? courseId,
String? batchId,
DateTime? createdAt,
}) {
return UserModel(
uid: uid ?? this.uid,
name: name ?? this.name,
phone: phone ?? this.phone,
email: email ?? this.email,
role: role ?? this.role,
city: city ?? this.city,
campus: campus ?? this.campus,
isActive: isActive ?? this.isActive,
photoUrl: photoUrl ?? this.photoUrl,
courseId: courseId ?? this.courseId,
batchId: batchId ?? this.batchId,
createdAt: createdAt ?? this.createdAt,
);
}
}
