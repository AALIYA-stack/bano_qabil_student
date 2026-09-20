
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/constants/collection_names.dart';
import '../models/notice_model.dart';

class NoticeService {
  NoticeService._();

  static final NoticeService instance = NoticeService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ============================================================
  // GET MY NOTICES
  // ============================================================

  Future<List<NoticeModel>> getMyNotices({
    String? courseId,
    String? batchId,
    String? campusId,
  }) async {
    final snapshot = await _firestore
        .collection(CollectionNames.notices)
        .where(
      'isActive',
      isEqualTo: true,
    )
        .get();

    final String normalizedCourseId =
        courseId?.trim().toLowerCase() ?? '';

    final String normalizedBatchId =
        batchId?.trim().toLowerCase() ?? '';

    final String normalizedCampusId =
        campusId?.trim().toLowerCase() ?? '';

    final notices = snapshot.docs
        .map(
          (doc) => NoticeModel.fromFirestore(doc),
    )
        .where((notice) {
      final String noticeCourseId =
          notice.courseId?.trim().toLowerCase() ?? '';

      final String noticeBatchId =
          notice.batchId?.trim().toLowerCase() ?? '';

      final String noticeCampusId =
          notice.campusId?.trim().toLowerCase() ?? '';

      // General notice = visible to everyone
      final bool courseMatch =
          noticeCourseId.isEmpty ||
              noticeCourseId == normalizedCourseId;

      final bool batchMatch =
          noticeBatchId.isEmpty ||
              noticeBatchId == normalizedBatchId;

      final bool campusMatch =
          noticeCampusId.isEmpty ||
              noticeCampusId == normalizedCampusId;

      return courseMatch &&
          batchMatch &&
          campusMatch;
    }).toList();

    // Latest notices first
    notices.sort((a, b) {
      final aDate = a.createdAt;
      final bDate = b.createdAt;

      if (aDate == null && bDate == null) {
        return 0;
      }

      if (aDate == null) {
        return 1;
      }

      if (bDate == null) {
        return -1;
      }

      return bDate.compareTo(aDate);
    });

    return notices;
  }

  // ============================================================
  // GET NOTICE BY ID
  // ============================================================

  Future<NoticeModel?> getNoticeById(
      String noticeId,
      ) async {
    final String trimmedId = noticeId.trim();

    if (trimmedId.isEmpty) {
      return null;
    }

    final doc = await _firestore
        .collection(CollectionNames.notices)
        .doc(trimmedId)
        .get();

    if (!doc.exists) {
      return null;
    }

    final notice =
    NoticeModel.fromFirestore(doc);

    // Inactive notice should not be displayed.
    if (!notice.isActive) {
      return null;
    }

    return notice;
  }

  // ============================================================
  // POST INSTRUCTOR NOTICE
  // ============================================================

  Future<void> postInstructorNotice({
    required String title,
    required String description,
    required String type,
    required String priority,
    required String courseId,
    required String batchId,
    required String campusId,
    required String instructorId,
  }) async {
    final trimmedTitle = title.trim();
    final trimmedDescription = description.trim();

    if (trimmedTitle.isEmpty) {
      throw Exception('Notice title is required.');
    }

    if (trimmedDescription.isEmpty) {
      throw Exception('Notice description is required.');
    }

    if (batchId.trim().isEmpty) {
      throw Exception('Please select a batch.');
    }

    if (instructorId.trim().isEmpty) {
      throw Exception('Instructor is not logged in.');
    }

    await _firestore
        .collection(CollectionNames.notices)
        .add({
      'title': trimmedTitle,
      'description': trimmedDescription,
      'type': type,
      'priority': priority,
      'courseId': courseId.trim(),
      'batchId': batchId.trim(),
      'campusId': campusId.trim(),
      'createdBy': instructorId.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'isActive': true,
    });
  }
}