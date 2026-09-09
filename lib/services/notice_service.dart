import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/constants/collection_names.dart';
import '../models/notice_model.dart';

class NoticeService {
  NoticeService._();

  static final NoticeService instance =
  NoticeService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception(
        'User is not logged in.',
      );
    }

    return user.uid;
  }

  Future<List<NoticeModel>> getMyNotices({
    String? courseId,
    String? batchId,
    String? campusId,
  }) async {
    final snapshot = await _firestore
        .collection(
      CollectionNames.notices,
    )
        .where(
      'isActive',
      isEqualTo: true,
    )
        .get();

    final notices = snapshot.docs
        .map(
          (doc) =>
          NoticeModel.fromFirestore(doc),
    )
        .where((notice) {
      final courseMatch =
          notice.courseId == null ||
              notice.courseId!.isEmpty ||
              notice.courseId == courseId;

      final batchMatch =
          notice.batchId == null ||
              notice.batchId!.isEmpty ||
              notice.batchId == batchId;

      final campusMatch =
          notice.campusId == null ||
              notice.campusId!.isEmpty ||
              notice.campusId == campusId;

      return courseMatch &&
          batchMatch &&
          campusMatch;
    }).toList();

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

  Future<NoticeModel?> getNoticeById(
      String noticeId,
      ) async {
    final doc = await _firestore
        .collection(
      CollectionNames.notices,
    )
        .doc(noticeId)
        .get();

    if (!doc.exists) {
      return null;
    }

    return NoticeModel.fromFirestore(doc);
  }
}