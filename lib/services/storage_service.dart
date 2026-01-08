import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class StorageService {
  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<String> uploadBillImage(String uid, File file) async {
    // Basic config check
    final bucket = storage.app.options.storageBucket;
    if (bucket == null || bucket.isEmpty) {
        debugPrint('❌ STORAGE ERROR: No storage bucket configured in Firebase options.');
        throw Exception('Firebase Storage bucket is not configured. Please check firebase_options.dart');
    }
    
    debugPrint('ℹ️ Attempting upload to bucket: $bucket');

    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

    final ref = storage.ref('users/$uid/receipts/$fileName');

    try {
      debugPrint('📤 PUT FILE START: ${file.path}');
      if (!file.existsSync()) {
        throw Exception('File does not exist: ${file.path}');
      }

      final uploadTask = ref.putFile(file);
      
      // Monitor progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        debugPrint('Progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100} %');
      }, onError: (e) {
        debugPrint('🔥 UPLOAD TASK ERROR: $e');
      });

      final snapshot = await uploadTask;
      debugPrint('📤 PUT FILE DONE. Status: ${snapshot.state}');

      final url = await ref.getDownloadURL();
      debugPrint('📥 URL RECEIVED: $url');

      return url;
    } on FirebaseException catch (e) {
      debugPrint('🔥 STORAGE ERROR: ${e.code}');
      debugPrint(e.message ?? '');
      throw Exception('Firebase Storage error (${e.code}): ${e.message}');
    } catch (e) {
      debugPrint('🔥 GENERAL ERROR: $e');
      throw Exception('Failed to upload image: $e');
    }
  }
}
