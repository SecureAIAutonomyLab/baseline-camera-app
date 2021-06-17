import 'dart:io';

import 'package:amplify_flutter/amplify.dart';

class StorageRepository {
  Future<String> uploadFile(String username, File file, String extension) async {
    try {
      // name of uploaded file
      String fileName;
      username = username.trim();
      if (extension == ".jpg") {
        fileName = '$username/photos/${username}_' + DateTime.now().toIso8601String();
        fileName = fileName.replaceAll('T', '_');
      } else {
        fileName = '$username/videos/${username}_' + DateTime.now().toIso8601String();
        fileName = fileName.replaceAll('T', '_');
      }
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