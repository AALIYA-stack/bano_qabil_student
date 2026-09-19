import 'package:cloud_firestore/cloud_firestore.dart';

class BatchModel {
  final String id;
  final String courseId;
  final String campusId;
  final String instructorId;
  final String classDay;
  final String classTime;
  final String room;
  final DateTime? startDate;
  final int seats;
  final int enrolledStudents;
  final bool isOpen;

  final List<Map<String, dynamic>> instructorAssignments;

  const BatchModel({
    required this.id,
    required this.courseId,
    required this.campusId,
    required this.instructorId,
    required this.classDay,
    required this.classTime,
    required this.room,
    required this.startDate,
    required this.seats,
    required this.enrolledStudents,
    required this.isOpen,
    this.instructorAssignments = const [],
  });

  // =========================================================
  // SEATS LEFT
  // =========================================================

  int get seatsLeft {
    final remaining = seats - enrolledStudents;

    if (remaining < 0) {
      return 0;
    }

    return remaining;
  }

  // =========================================================
  // FROM FIRESTORE
  // =========================================================

  factory BatchModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final data = doc.data();

    if (data == null) {
      throw Exception(
        'Batch document ${doc.id} contains no data.',
      );
    }

    // -------------------------------------------------------
    // COURSE ID
    // -------------------------------------------------------

    final rawCourseId = data['courseId'];

    final String courseId = rawCourseId == null
        ? ''
        : rawCourseId.toString().trim();

    // -------------------------------------------------------
    // CAMPUS ID
    // -------------------------------------------------------

    final rawCampusId = data['campusId'];

    final String campusId = rawCampusId == null
        ? ''
        : rawCampusId.toString().trim();

    // -------------------------------------------------------
    // INSTRUCTOR ID
    // -------------------------------------------------------

    final rawInstructorId = data['instructorId'];

    final String instructorId = rawInstructorId == null
        ? ''
        : rawInstructorId.toString().trim();

    // -------------------------------------------------------
    // CLASS DAY
    // -------------------------------------------------------

    final rawClassDay = data['classDay'];

    final String classDay = rawClassDay == null
        ? ''
        : rawClassDay.toString().trim();

    // -------------------------------------------------------
    // CLASS TIME
    // -------------------------------------------------------

    final rawClassTime = data['classTime'];

    final String classTime = rawClassTime == null
        ? ''
        : rawClassTime.toString().trim();

    // -------------------------------------------------------
    // ROOM
    // -------------------------------------------------------

    final rawRoom = data['room'];

    final String room = rawRoom == null
        ? ''
        : rawRoom.toString().trim();

    // -------------------------------------------------------
    // START DATE
    // -------------------------------------------------------

    DateTime? parsedStartDate;

    final dynamic startDateValue = data['startDate'];

    if (startDateValue is Timestamp) {
      parsedStartDate = startDateValue.toDate();
    } else if (startDateValue is DateTime) {
      parsedStartDate = startDateValue;
    } else if (startDateValue is String) {
      parsedStartDate = DateTime.tryParse(
        startDateValue.trim(),
      );
    }

    // -------------------------------------------------------
    // SEATS
    // -------------------------------------------------------

    int seats = 0;

    final dynamic seatsValue = data['seats'];

    if (seatsValue is num) {
      seats = seatsValue.toInt();
    } else if (seatsValue is String) {
      seats = int.tryParse(seatsValue.trim()) ?? 0;
    }

    // -------------------------------------------------------
    // ENROLLED STUDENTS
    // -------------------------------------------------------

    int enrolledStudents = 0;

    final dynamic enrolledValue =
    data['enrolledStudents'];

    if (enrolledValue is num) {
      enrolledStudents = enrolledValue.toInt();
    } else if (enrolledValue is String) {
      enrolledStudents =
          int.tryParse(enrolledValue.trim()) ?? 0;
    }

    // -------------------------------------------------------
    // IS OPEN
    // -------------------------------------------------------

    bool isOpen = true;

    final dynamic isOpenValue = data['isOpen'];

    if (isOpenValue is bool) {
      isOpen = isOpenValue;
    } else if (isOpenValue is String) {
      isOpen =
          isOpenValue.trim().toLowerCase() == 'true';
    }

    // -------------------------------------------------------
    // INSTRUCTOR ASSIGNMENTS
    // -------------------------------------------------------

    final List<Map<String, dynamic>>
    parsedAssignments = [];

    final dynamic assignmentsValue =
    data['instructorAssignments'];

    if (assignmentsValue is List) {
      for (final item in assignmentsValue) {
        if (item is Map) {
          parsedAssignments.add(
            Map<String, dynamic>.from(item),
          );
        }
      }
    }

    // -------------------------------------------------------
    // DEBUG
    // -------------------------------------------------------

    print('----------------------------------------');
    print('READING BATCH FROM FIRESTORE');
    print('DOCUMENT ID: ${doc.id}');
    print('RAW courseId: $rawCourseId');
    print('PARSED courseId: "$courseId"');
    print('campusId: "$campusId"');
    print('instructorId: "$instructorId"');
    print('classDay: "$classDay"');
    print('classTime: "$classTime"');
    print('room: "$room"');
    print('seats: $seats');
    print('enrolledStudents: $enrolledStudents');
    print('seatsLeft: ${seats - enrolledStudents}');
    print('isOpen: $isOpen');
    print('startDate: $parsedStartDate');
    print('----------------------------------------');

    // -------------------------------------------------------
    // RETURN
    // -------------------------------------------------------

    return BatchModel(
      id: doc.id,
      courseId: courseId,
      campusId: campusId,
      instructorId: instructorId,
      classDay: classDay,
      classTime: classTime,
      room: room,
      startDate: parsedStartDate,
      seats: seats,
      enrolledStudents: enrolledStudents,
      isOpen: isOpen,
      instructorAssignments: parsedAssignments,
    );
  }

  // =========================================================
  // TO FIRESTORE
  // =========================================================

  Map<String, dynamic> toFirestore() {
    return {
      'courseId': courseId.trim(),
      'campusId': campusId.trim(),
      'instructorId': instructorId.trim(),
      'classDay': classDay.trim(),
      'classTime': classTime.trim(),
      'room': room.trim(),
      'startDate': startDate == null
          ? null
          : Timestamp.fromDate(startDate!),
      'seats': seats,
      'enrolledStudents': enrolledStudents,
      'isOpen': isOpen,
      'instructorAssignments':
      instructorAssignments,
    };
  }

  // =========================================================
  // COPY WITH
  // =========================================================

  BatchModel copyWith({
    String? id,
    String? courseId,
    String? campusId,
    String? instructorId,
    String? classDay,
    String? classTime,
    String? room,
    DateTime? startDate,
    int? seats,
    int? enrolledStudents,
    bool? isOpen,
    List<Map<String, dynamic>>?
    instructorAssignments,
  }) {
    return BatchModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      campusId: campusId ?? this.campusId,
      instructorId:
      instructorId ?? this.instructorId,
      classDay: classDay ?? this.classDay,
      classTime: classTime ?? this.classTime,
      room: room ?? this.room,
      startDate: startDate ?? this.startDate,
      seats: seats ?? this.seats,
      enrolledStudents:
      enrolledStudents ?? this.enrolledStudents,
      isOpen: isOpen ?? this.isOpen,
      instructorAssignments:
      instructorAssignments ??
          this.instructorAssignments,
    );
  }
}