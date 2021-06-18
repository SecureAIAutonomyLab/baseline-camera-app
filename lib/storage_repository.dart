import 'dart:io';

import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:camera_app/camera_example_home.dart';

class StorageRepository {
  Future<String> uploadFile(String username, File file, String extension, String userId, BooleanWrap finished) async {
    try {
      if (username == null) {
        username = "null";
      }
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

      final options = _fileMetadata(username, extension, userId);
      final result = await Amplify.Storage.uploadFile(
        local: file,
        key: fileName + extension,
        options: options,
      );
      return result.key;
    } catch (e) {
        throw Exception("failed file upload");
    }
  }

  S3UploadFileOptions _fileMetadata(String username, String extension, String userId) {
    Map<String, String> metadata = Map<String, String>();
    metadata["username"] = username;
    metadata["user_id"] = userId;
    metadata["date_created"] = DateTime.now().toIso8601String();
    metadata["type"] = extension;
    final options = S3UploadFileOptions(
      metadata: metadata,
      accessLevel: StorageAccessLevel.guest,
    );
    return options;
  }
}