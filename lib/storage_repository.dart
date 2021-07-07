/*
  Created By: Nathan Millwater
  Description: Hold the logic for interacting with the cloud storage repository
 */

import 'dart:io';

import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:camera/camera.dart';
import 'package:camera_app/camera_view_build.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sortedmap/sortedmap.dart';



/// Holds values related to an action entry
class ActionEntry {

  String action;
  LocationData location;
  String time;

  ActionEntry({this.action, this.location, this.time});
}

class StorageRepository {

  String storedDate;
  File actionFile;
  SortedMap<Duration, ActionEntry> actionTable;
  Stopwatch timeElapsed;

  // initialize variables in the constructor
  StorageRepository() {
    timeElapsed = Stopwatch();
    actionTable = SortedMap<Duration, ActionEntry>(Ordering.byKey());
  }

  /// Takes in a username, userId, File and extension and stores this information
  /// Parameters: The user's username, the File object being uploaded and the file extension
  /// Returns: A future string with the upload file result
  Future<String> uploadFile(String username, File file, String extension,
      String userId, LocationData loc, ChunkVideoData chunk, CameraController c) async {
    if (username == null) {
      username = "null";
    }
    // name of uploaded file
    String fileName;
    username = username.trim();
    // create folders to separate videos and photos
    String type;
    if (extension == ".jpg")
      type = "photos";
    else
      type = "videos";

    if (chunk.videoCount == 1)
      storedDate = DateTime.now().toIso8601String();
    if (chunk.videoCount == 0 && actionTable.isEmpty) {
      // single video no actions listed
      fileName = '$userId/$type/${userId}_' + DateTime.now().toIso8601String().substring(0, 19);
      fileName = fileName.replaceAll('T', '_');
    } else if (chunk.videoCount == 0 && actionTable.isNotEmpty) {
      // single video with actions
      fileName = '$userId/$type/' + DateTime.now().toIso8601String().substring(0, 19);
      fileName += ("/${userId}_" + DateTime.now().toIso8601String().substring(0, 19));
      fileName = fileName.replaceAll("T", "_");
      storedDate = DateTime.now().toIso8601String();
    } else {
      // chunked video with actions
      fileName = '$userId/$type/' + storedDate.substring(0, 19);
      // trim time off of fileName
      fileName += ("/${userId}_" + DateTime.now().toIso8601String().substring(0, 19) + "--"
          + chunk.videoCount.toString());
      fileName = fileName.replaceAll('T', '_');
    }

    // Stores file metadata in the file upload options
    final options = fileMetadata(username, extension, userId, loc);
    // Amplify upload video file function
    final result = await Amplify.Storage.uploadFile(
      local: file,
      key: fileName + extension, // The file name
      options: options, // File upload options
    );
    // upload the action file if a video was uploaded
    if (extension == ".mp4") {
      await writeActionFile(userId);
      await uploadActionFile(userId, c);
    }

    return result.key;
  }

  /// Upload the action file with actions and the time they occurred
  /// to AWS
  /// Parameters: The devices Id string
  /// Returns: A future object indicating this function is asynchronous
  Future<void> uploadActionFile(String userId, CameraController c) async {
    if (actionTable.isEmpty || c.value.isRecordingVideo) {
      print("No actions submitted");
      return;
    }
    print("Now uploading text file");
    String fileName = '$userId/videos/' + storedDate.substring(0, 19);
    fileName += ("/${userId}_" + DateTime.now().toIso8601String().substring(0, 19));
    fileName = fileName.replaceAll("T", "_");
    await Amplify.Storage.uploadFile(
        local: actionFile, key: fileName + ".csv");
  }

  Future<void> writeActionFile(String id) async {
    // save data to string buffer because strings are immutable
    var buffer = new StringBuffer();
    buffer.write("Recorded on device: " + id);
    // header for csv file
    buffer.write("\ntime_elapsed,datetime,longitude,latitude,name");
    actionTable.forEach((key, value) {
      String millisecond = (key.inMilliseconds % 1000).toString();
      buffer.write("\n" + key.inSeconds.toString() + "." + millisecond);
      buffer.write("," + DateTime.now().toIso8601String().substring(0, 10));
      buffer.write(" " + value.time);
      buffer.write("," + value.location.longitude.toString());
      buffer.write("," + value.location.latitude.toString());
      buffer.write("," + value.action);
    });
    // to save time open file only once and write everything
    actionFile.writeAsString(buffer.toString());
  }

  /// Create the metadata map to upload with the file
  /// Parameters: The user's username, userID, file extension, and location data
  /// Returns: metadata for the file to store on AWS
  S3UploadFileOptions fileMetadata(String username, String extension,
      String userId, LocationData loc) {

    Map<String, String> metadata = Map<String, String>();
    //metadata["username"] = username;
    // metadata["user_id"] = userId;
    metadata["device_id"] = userId;
    metadata["date_created"] = DateTime.now().toIso8601String();
    metadata["type"] = extension;
    metadata["latitude"] = loc.latitude.toString();
    metadata["longitude"] = loc.longitude.toString();
    final options = S3UploadFileOptions(
      metadata: metadata,
      accessLevel: StorageAccessLevel.guest, // the access level of the data
    );
    return options;
  }

  Future<File> createActionTextFile() async {
    // reset the action table
    actionTable = SortedMap<Duration, ActionEntry>(Ordering.byKey());
    // get the app's storage directory
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/camera_app/text_action_files';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/' + DateTime.now().toString();
    // The file name
    File file = File(filePath);
    file.writeAsString("Action File created by");
    actionFile = file;
    return file;
  }

  void addAction(String action) async {
    // save entry in a table
    final time = DateTime.now().toIso8601String().substring(11, 19);
    final duration = timeElapsed.elapsed;
    actionTable[duration] =
        ActionEntry(action: action, time: time);
    print("Action Time Submitted");

    // Record location data
    Location location = new Location();
    LocationData myLocation = await location.getLocation();
    // set location after time because location is not synchronous
    actionTable[duration].location = myLocation;
  }

}