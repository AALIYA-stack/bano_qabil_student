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

  // =========================
  // CURRENT USER UID
  // =========================
  String get _uid {
    final User? user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    return user.uid;
  }

  // =========================
  // NOTIFICATIONS COLLECTION
  // =========================
  CollectionReference<Map<String, dynamic>>
  get _notifications {
    return _firestore.collection(
      CollectionNames.notifications,
    );
  }

  // =========================
  // GET MY NOTIFICATIONS
  // =========================
  Future<List<AppNotification>>
  getMyNotifications() async {
    try {
      final String uid = _uid;

      print('================================');
      print('LOADING NOTIFICATIONS');
      print('CURRENT USER UID: $uid');

      final QuerySnapshot<Map<String, dynamic>>
      snapshot = await _notifications
          .where(
        'studentId',
        isEqualTo: uid,
      )
          .get();

      print(
        'NOTIFICATIONS FOUND: ${snapshot.docs.length}',
      );

      final List<AppNotification>
      notifications = snapshot.docs
          .map(
            (doc) =>
            AppNotification.fromFirestore(
              doc,
            ),
      )
          .toList();

      notifications.sort((a, b) {
        final DateTime? aDate = a.createdAt;
        final DateTime? bDate = b.createdAt;

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

      print('================================');

      return notifications;
    } on FirebaseException catch (e) {
      print('================================');
      print('NOTIFICATION FIREBASE ERROR');
      print('CODE: ${e.code}');
      print('MESSAGE: ${e.message}');
      print('================================');

      throw Exception(
        'Unable to load notifications: '
            '${e.message ?? e.code}',
      );
    }
  }

  // =========================
  // GET UNREAD COUNT
  // =========================
  Future<int> getUnreadCount() async {
    try {
      final QuerySnapshot<Map<String, dynamic>>
      snapshot = await _notifications
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
    } on FirebaseException catch (e) {
      print('Unread count error: ${e.code}');

      throw Exception(
        'Unable to load unread notifications: '
            '${e.message ?? e.code}',
      );
    }
  }

  // =========================
  // GET SINGLE NOTIFICATION
  // =========================
  Future<AppNotification?>
  getNotificationById(
      String notificationId,
      ) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>>
      doc = await _notifications
          .doc(notificationId)
          .get();

      if (!doc.exists) {
        return null;
      }

      final AppNotification notification =
      AppNotification.fromFirestore(doc);

      if (notification.studentId != _uid) {
        throw Exception(
          'You are not allowed to view this notification.',
        );
      }

      return notification;
    } on FirebaseException catch (e) {
      throw Exception(
        'Unable to load notification: '
            '${e.message ?? e.code}',
      );
    }
  }

  // =========================
  // MARK AS READ
  // =========================
  Future<void> markAsRead(
      String notificationId,
      ) async {
    final AppNotification? notification =
    await getNotificationById(
      notificationId,
    );

    if (notification == null) {
      throw Exception(
        'Notification not found.',
      );
    }

    if (notification.isRead) {
      return;
    }

    await _notifications
        .doc(notificationId)
        .update({
      'isRead': true,
    });
  }

  // =========================
  // MARK ALL AS READ
  // =========================
  Future<void> markAllAsRead() async {
    final QuerySnapshot<Map<String, dynamic>>
    snapshot = await _notifications
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

    final WriteBatch batch =
    _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.update(
        doc.reference,
        {
          'isRead': true,
        },
      );
    }

    await batch.commit();
  }
}