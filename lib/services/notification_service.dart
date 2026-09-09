import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/constants/collection_names.dart';
import '../models/notification_model.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance =
  NotificationService._();

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

  CollectionReference<Map<String, dynamic>>
  get _notifications {
    return _firestore.collection(
      CollectionNames.notifications,
    );
  }

  Future<List<AppNotification>>
  getMyNotifications() async {
    final snapshot =
    await _notifications
        .where(
      'studentId',
      isEqualTo: _uid,
    )
        .get();

    final notifications =
    snapshot.docs
        .map(
          (doc) =>
          AppNotification
              .fromFirestore(doc),
    )
        .toList();

    notifications.sort((a, b) {
      final aDate = a.createdAt;
      final bDate = b.createdAt;

      if (aDate == null &&
          bDate == null) {
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

    return notifications;
  }

  Future<int> getUnreadCount() async {
    final snapshot =
    await _notifications
        .where(
      'studentId',
      isEqualTo: _uid,
    )
        .where(
      'isRead',
      isEqualTo: false,
    )
        .get();

    return snapshot.docs.length;
  }

  Future<void> markAsRead(
      String notificationId,
      ) async {
    final notification =
    await getNotificationById(
      notificationId,
    );

    if (notification == null) {
      throw Exception(
        'Notification not found.',
      );
    }

    await _notifications
        .doc(notificationId)
        .update({
      'isRead': true,
    });
  }

  Future<void> markAllAsRead() async {
    final snapshot =
    await _notifications
        .where(
      'studentId',
      isEqualTo: _uid,
    )
        .where(
      'isRead',
      isEqualTo: false,
    )
        .get();

    if (snapshot.docs.isEmpty) {
      return;
    }

    final batch =
    _firestore.batch();

    for (final doc
    in snapshot.docs) {
      batch.update(
        doc.reference,
        {
          'isRead': true,
        },
      );
    }

    await batch.commit();
  }

  Future<AppNotification?>
  getNotificationById(
      String notificationId,
      ) async {
    final doc =
    await _notifications
        .doc(notificationId)
        .get();

    if (!doc.exists) {
      return null;
    }

    final notification =
    AppNotification.fromFirestore(
      doc,
    );

    if (notification.studentId !=
        _uid) {
      throw Exception(
        'You are not allowed to view this notification.',
      );
    }

    return notification;
  }
}