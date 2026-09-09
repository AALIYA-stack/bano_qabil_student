import 'package:cloud_firestore/cloud_firestore.dart';

class CourseModel {
  final String id;
  final String name;
  final String description;
  final String level;
  final String duration;
  final int totalSeats;
  final int seatsFilled;
  final bool isActive;

  const CourseModel({
    required this.id,
    required this.name,
    required this.description,
    required this.level,
    required this.duration,
    required this.totalSeats,
    required this.seatsFilled,
    required this.isActive,
  });

  int get seatsLeft {
    final value = totalSeats - seatsFilled;
    return value < 0 ? 0 : value;
  }

  factory CourseModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data() ?? {};

    return CourseModel(
      id: doc.id,
      name: data['name']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      level: data['level']?.toString() ?? 'Beginner',
      duration: data['duration']?.toString() ?? '',
      totalSeats: (data['totalSeats'] as num?)?.toInt() ?? 0,
      seatsFilled: (data['seatsFilled'] as num?)?.toInt() ?? 0,
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'level': level,
      'duration': duration,
      'totalSeats': totalSeats,
      'seatsFilled': seatsFilled,
      'isActive': isActive,
    };
  }
}