import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  StorageService._();

  static final StorageService instance =
  StorageService._();

  final FirebaseStorage _storage =
      FirebaseStorage.instance;

  Future<String> uploadProfilePhoto({
    required String uid,
    required Uint8List imageBytes,
  }) async {
    final reference = _storage
        .ref()
        .child('profiles')
        .child('$uid.jpg');

    await reference.putData(
      imageBytes,
      SettableMetadata(
        contentType: 'image/jpeg',
      ),
    );

    return reference.getDownloadURL();
  }

  Future<void> deleteProfilePhoto(
      String uid,
      ) async {
    final reference = _storage
        .ref()
        .child('profiles')
        .child('$uid.jpg');

    try {
      await reference.delete();
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        return;
      }

      rethrow;
    }
  }
}