import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  StorageService._();

  static final StorageService instance = StorageService._();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ============================================================
  // UPLOAD PROFILE PHOTO
  // ============================================================

  Future<String> uploadProfilePhoto({
    required String uid,
    required Uint8List imageBytes,
  }) async {
    if (uid.trim().isEmpty) {
      throw Exception('User ID is missing.');
    }

    if (imageBytes.isEmpty) {
      throw Exception('Image file is empty.');
    }

    try {
      final String path = 'profiles/${uid.trim()}.jpg';

      final Reference reference = _storage.ref().child(path);

      final SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
        cacheControl: 'no-cache',
      );

      print('==========================================');
      print('PROFILE PHOTO UPLOAD');
      print('UID: ${uid.trim()}');
      print('PATH: $path');
      print('SIZE: ${imageBytes.length}');
      print('==========================================');

      await reference.putData(
        imageBytes,
        metadata,
      );

      final String downloadUrl =
      await reference.getDownloadURL();

      print('==========================================');
      print('PROFILE PHOTO UPLOAD SUCCESS');
      print('URL: $downloadUrl');
      print('==========================================');

      return downloadUrl;
    } on FirebaseException catch (e) {
      print('==========================================');
      print('PROFILE PHOTO STORAGE ERROR');
      print('CODE: ${e.code}');
      print('MESSAGE: ${e.message}');
      print('==========================================');

      throw Exception(
        'Profile photo upload failed: ${e.message ?? e.code}',
      );
    } catch (e) {
      print('PROFILE PHOTO ERROR: $e');

      throw Exception(
        'Profile photo upload failed.',
      );
    }
  }

  // ============================================================
  // DELETE PROFILE PHOTO
  // ============================================================

  Future<void> deleteProfilePhoto(String uid) async {
    if (uid.trim().isEmpty) {
      return;
    }

    final Reference reference = _storage
        .ref()
        .child('profiles/${uid.trim()}.jpg');

    try {
      await reference.delete();

      print(
        'Profile photo deleted: ${reference.fullPath}',
      );
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        return;
      }

      rethrow;
    }
  }
}