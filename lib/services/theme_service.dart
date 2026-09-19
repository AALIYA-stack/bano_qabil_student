import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ThemeService {
  ThemeService._();

  static final ThemeService instance = ThemeService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> getDarkMode() async {
    final user = _auth.currentUser;

    if (user == null) {
      return false;
    }

    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        return false;
      }

      final data = doc.data();

      return data?['darkMode'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<void> setDarkMode(bool enabled) async {
    final user = _auth.currentUser;

    if (user == null) {
      return;
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(
      {
        'darkMode': enabled,
      },
      SetOptions(merge: true),
    );
  }
}