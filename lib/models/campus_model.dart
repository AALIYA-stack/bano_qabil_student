import 'package:cloud_firestore/cloud_firestore.dart';

class CampusModel {
  final String id;
  final String name;
  final String city;
  final String province;
  final String address;
  final String phone;
  final bool isActive;

  const CampusModel({
    required this.id,
    required this.name,
    required this.city,
    required this.province,
    required this.address,
    required this.phone,
    required this.isActive,
  });

  factory CampusModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data() ?? {};

    return CampusModel(
      id: doc.id,
      name: data['name']?.toString() ?? '',
      city: data['city']?.toString() ?? '',
      province: data['province']?.toString() ?? '',
      address: data['address']?.toString() ?? '',
      phone: data['phone']?.toString() ?? '',
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'city': city,
      'province': province,
      'address': address,
      'phone': phone,
      'isActive': isActive,
    };
  }
}