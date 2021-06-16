import 'dart:io';

import 'package:amplify_flutter/amplify.dart';

class StorageRepository {
  Future<String> uploadFile(File file, String extension) async {
    try {
      final fileName = DateTime.now().toIso8601String();
      final result = await Amplify.Storage.uploadFile(
        local: file,
        key: fileName + extension,
      );
      return result.key;
    } catch (e) {
        throw Exception("failed file upload");
    }
  }
}