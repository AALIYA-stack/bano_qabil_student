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
    try {
      print('==========================================');
      print('STORAGE UPLOAD START');
      print('UID: $uid');
      print('BYTES: ${imageBytes.length}');
      print('==========================================');

      final reference = _storage
          .ref()
          .child('profiles')
          .child('$uid.jpg');

      print('STORAGE PATH: ${reference.fullPath}');
      print('STORAGE BUCKET: ${reference.bucket}');
      print('STARTING putData...');

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
      );

      final uploadTask = reference.putData(
        imageBytes,
        metadata,
      );

      final snapshot = await uploadTask;

      print('==========================================');
      print('STORAGE UPLOAD COMPLETE');
      print('STATE: ${snapshot.state}');
      print('SIZE: ${snapshot.totalBytes}');
      print('PATH: ${snapshot.ref.fullPath}');
      print('==========================================');

      print('GETTING DOWNLOAD URL...');

      final downloadUrl =
      await reference.getDownloadURL();

      print('==========================================');
      print('DOWNLOAD URL RECEIVED');
      print(downloadUrl);
      print('==========================================');

      return downloadUrl;
    } on FirebaseException catch (e) {
      print('==========================================');
      print('FIREBASE STORAGE ERROR');
      print('CODE: ${e.code}');
      print('MESSAGE: ${e.message}');
      print('PLUGIN: ${e.plugin}');
      print('==========================================');

      rethrow;
    } catch (e) {
      print('==========================================');
      print('STORAGE UNKNOWN ERROR');
      print(e);
      print('==========================================');

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