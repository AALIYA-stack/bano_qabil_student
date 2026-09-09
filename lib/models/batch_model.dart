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
});

/// Number of seats still available.
int get seatsLeft {
final result = seats - enrolledStudents;
return result < 0 ? 0 : result;
}

/// Create BatchModel from Firestore document.
factory BatchModel.fromFirestore(
DocumentSnapshot<Map<String, dynamic>> doc,
) {
final data = doc.data() ?? <String, dynamic>{};

DateTime? parsedStartDate;

final dynamic startDateValue = data['startDate'];

if (startDateValue is Timestamp) {
parsedStartDate = startDateValue.toDate();
} else if (startDateValue is DateTime) {
parsedStartDate = startDateValue;
} else if (startDateValue is String) {
parsedStartDate = DateTime.tryParse(
startDateValue,
);
}

return BatchModel(
id: doc.id,
courseId: data['courseId']?.toString() ?? '',
campusId: data['campusId']?.toString() ?? '',
instructorId: data['instructorId']?.toString() ?? '',
classDay: data['classDay']?.toString() ?? '',
classTime: data['classTime']?.toString() ?? '',
room: data['room']?.toString() ?? '',
startDate: parsedStartDate,
seats: data['seats'] is num
? (data['seats'] as num).toInt()
    : 0,
enrolledStudents: data['enrolledStudents'] is num
? (data['enrolledStudents'] as num).toInt()
    : 0,
isOpen: data['isOpen'] is bool
? data['isOpen'] as bool
    : true,
);
}

/// Convert BatchModel to Firestore data.
Map<String, dynamic> toFirestore() {
return {
'courseId': courseId,
'campusId': campusId,
'instructorId': instructorId,
'classDay': classDay,
'classTime': classTime,
'room': room,
'startDate': startDate == null
? null
    : Timestamp.fromDate(startDate!),
'seats': seats,
'enrolledStudents': enrolledStudents,
'isOpen': isOpen,
};
}

/// Create a copy with updated values.
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
}) {
return BatchModel(
id: id ?? this.id,
courseId: courseId ?? this.courseId,
campusId: campusId ?? this.campusId,
instructorId: instructorId ?? this.instructorId,
classDay: classDay ?? this.classDay,
classTime: classTime ?? this.classTime,
room: room ?? this.room,
startDate: startDate ?? this.startDate,
seats: seats ?? this.seats,
enrolledStudents:
enrolledStudents ?? this.enrolledStudents,
isOpen: isOpen ?? this.isOpen,
);
}
}

