import 'package:flutter/foundation.dart';
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
    try {
      debugPrint('==========================================');
      debugPrint('STORAGE UPLOAD START');
      debugPrint('UID: $uid');
      debugPrint('BYTES: ${imageBytes.length}');
      debugPrint('==========================================');

      final reference = _storage
          .ref()
          .child('profiles')
          .child('$uid.jpg');

      debugPrint('STORAGE PATH: ${reference.fullPath}');
      debugPrint('STORAGE BUCKET: ${reference.bucket}');
      debugPrint('STARTING putData...');

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
      );

      final uploadTask = reference.putData(
        imageBytes,
        metadata,
      );

      final snapshot = await uploadTask;

      debugPrint('==========================================');
      debugPrint('STORAGE UPLOAD COMPLETE');
      debugPrint('STATE: ${snapshot.state}');
      debugPrint('SIZE: ${snapshot.totalBytes}');
      debugPrint('PATH: ${snapshot.ref.fullPath}');
      debugPrint('==========================================');

      debugPrint('GETTING DOWNLOAD URL...');

      final downloadUrl =
      await reference.getDownloadURL();

      debugPrint('==========================================');
      debugPrint('DOWNLOAD URL RECEIVED');
      debugPrint(downloadUrl);
      debugPrint('==========================================');

      return downloadUrl;
    } on FirebaseException catch (e) {
      debugPrint('==========================================');
      debugPrint('FIREBASE STORAGE ERROR');
      debugPrint('CODE: ${e.code}');
      debugPrint('MESSAGE: ${e.message}');
      debugPrint('PLUGIN: ${e.plugin}');
      debugPrint('==========================================');

      rethrow;
    } catch (e) {
      debugPrint('==========================================');
      debugPrint('STORAGE UNKNOWN ERROR');
      debugPrint(e.toString());
      debugPrint('==========================================');

      rethrow;
    }
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