/*
  Created By: Nathan Millwater
  Description: Holds the camera home widget tree. Once the user
               has logged in, the session starts and this widget
               tree is displayed.
 */

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:camera_app/camera_example_home.dart';
import 'package:camera_app/session_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'main.dart';

class CameraViewBuild {

  BuildContext context;
  CameraExampleHomeState state;
  CameraController controller;
  BooleanWrap isFileFinishedUploading;
  bool enableAudio;
  String uploadMessage;

  // named parameter constructor
  CameraViewBuild({this.context, this.state, this.controller, this.isFileFinishedUploading,
                  this.enableAudio, this.uploadMessage});

  /// Messages for the snack bar
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// This called by the main build function in the home class
  Widget build () {
    return Scaffold(
      key: _scaffoldKey,
      appBar: chooseAppBar(),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              child: Padding(
                // box around camera preview
                padding: const EdgeInsets.all(1.0),
                child: Center(
                  child: cameraPreviewWidget(),
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(
                  color: controller != null && controller.value.isRecordingVideo
                      ? Colors.redAccent
                      : Colors.grey,
                  width: 3.0,
                ),
              ),
            ),
          ),
          // Camera control buttons
          captureControlRowWidget(),
          // Capture audio or not
          toggleAudioWidget(),
        ],
      ),
    );
  }

  /// Chooses the appbar based on the device platform
  /// Returns: Appbar Widget
  Widget chooseAppBar() {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return CupertinoNavigationBar(
        leading: TextButton(
          child: Text("Sign Out", style: TextStyle(fontSize: 16),),
          onPressed: () => BlocProvider.of<SessionCubit>(context).signOut(),
        ),
        middle: Text("Camera App"),
        trailing: IconButton(
          icon: Icon(Icons.flip_camera_ios),
          onPressed: () {
            // Switch to a different camera
            state.cameraToggleButtonPressed();
          },
        ),
      );
    }
    else {
      // android platform
      return AppBar(
        title: Text("Camera Example"),
        actions: [
          IconButton(
            icon: Icon(Icons.flip_camera_android),
            onPressed: () {
              // Switch to a different camera
              state.cameraToggleButtonPressed();
            },
          )
        ],
      );
    }
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  /// Returns: the camera preview widget
  Widget cameraPreviewWidget() {
    // Check if file has started uploading
    if (isFileFinishedUploading.started) {
      // Check if file has finished uploading
      if (isFileFinishedUploading.finished) {
        return Text(
          "Upload Complete",
          style: TextStyle(color: Colors.white, fontSize: 30),
        );
      } else {
        // Display uploading indicator
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "File Uploading",
              style: TextStyle(color: Colors.white, fontSize: 30),
            ),
            SizedBox(height: 40),
            CircularProgressIndicator(),
          ],
        );
      }
    }
    // Display the camera preview
    if (!state.controllerInitialized) {
      if (cameras.isEmpty) {
        return const Text(
          'No cameras detected',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.0,
            fontWeight: FontWeight.w900,
          ),
        );
      }
    } else {
      // If user changes device orientation
      return RotatedBox(
        quarterTurns: MediaQuery.of(context).orientation == Orientation.landscape ? 3 : 0,
        child: AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: CameraPreview(controller),
        ),
      );
    }
  }

  /// Returns: toggle recording audio widget
  Widget toggleAudioWidget() {
    return Padding(
      padding: const EdgeInsets.only(left: 25, top: 10, bottom: 25),
      child: Row(
        children: <Widget>[
          const Text(
            'Enable Audio:',
            style: TextStyle(fontSize: 15),
          ),
          SizedBox(width: 5,),
          // Android switch or IOS switch
          enableAudioSwitchType(),
        ],
      ),
    );
  }

  /// Choose the type of enable audio switch depending on the device platform
  /// Returns: a switch widget
  Widget enableAudioSwitchType() {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      // Use a cupertino switch if platform is IOS
      return CupertinoSwitch(
        value: enableAudio,
        onChanged: (bool value) {
          enableAudio = value;
          if (controller != null) {
            state.onNewCameraSelected(controller.description);
          }
        },
      );
    }
    else {
      // Use a material switch if platform is Android
      return Switch(
        value: enableAudio,
        onChanged: (bool value) {
          enableAudio = value;
          if (controller != null) {
            state.onNewCameraSelected(controller.description);
          }
        },
      );
    }
  }

  /// Display the control bar with buttons to take pictures and record videos.
  /// Returns: a Row widget with 4 buttons
  Widget captureControlRowWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.camera_alt),
          color: Colors.blue,
          // If all boolean values are true, activate button otherwise do nothing
          onPressed: controller != null &&
              controller.value.isInitialized &&
              !controller.value.isRecordingVideo &&
              !isFileFinishedUploading.started // only if finished uploading
              ? state.onTakePictureButtonPressed
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.videocam),
          color: Colors.blue,
          // If all boolean values are true, activate button otherwise do nothing
          onPressed: controller != null &&
              controller.value.isInitialized &&
              !controller.value.isRecordingVideo &&
              !isFileFinishedUploading.started // only if finished uploading
              ? state.onVideoRecordButtonPressed
              : null,
        ),
        IconButton(
          icon: controller != null && controller.value.isRecordingPaused
              ? Icon(Icons.play_arrow)
              : Icon(Icons.pause),
          color: Colors.blue,
          // If all boolean values are true, activate button otherwise do nothing
          onPressed: controller != null &&
              controller.value.isInitialized &&
              controller.value.isRecordingVideo
              ? (controller != null && controller.value.isRecordingPaused
              ? state.onResumeButtonPressed
              : state.onPauseButtonPressed)
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.stop),
          color: Colors.red,
          // If all boolean values are true, activate button otherwise do nothing
          onPressed: controller != null &&
              controller.value.isInitialized &&
              controller.value.isRecordingVideo
              ? state.onStopButtonPressed
              : null,
        )
      ],
    );
  }

  /// Displays a dialog box that prompts the user if they want to upload their file
  /// Returns: A future object, indicates function is not synchronous
  Future<void> showUploadDialogBox() {
    return showCupertinoDialog<void>(
      // User cannot dismiss the dialog
        barrierDismissible: false,
        context: context, builder: (BuildContext context) {
      return CupertinoAlertDialog(
        title: Text(uploadMessage),
        content: Text("Do you want to upload this file to AWS?"),
        actions: [
          // No button
          CupertinoDialogAction(
              onPressed: () {
                isFileFinishedUploading.upload = false;
                Navigator.of(context).pop();
              },
              child: Text("No")
          ),
          // Yes button
          CupertinoDialogAction(
              onPressed: () async {
                final connected = await isInternetConnected();
                Navigator.of(context).pop();
                if (connected) {
                  isFileFinishedUploading.upload = true;
                } else {
                  state.showInSnackBar("You are not connected to the internet");
                }
              },
              child: Text("Yes")
          )
        ],
      );
    }
    );
  }

  Future<bool> isInternetConnected () async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        return true;
      }
    } on SocketException catch (_) {
      print('not connected');
      return false;
    }
  }

  // /// Display the thumbnail of the captured image or video.
  // /// Is not currently being used
  // Widget thumbnailWidget() {
  //   return Expanded(
  //     child: Align(
  //       alignment: Alignment.centerRight,
  //       child: Row(
  //         mainAxisSize: MainAxisSize.min,
  //         children: <Widget>[
  //           videoController == null && imagePath == null
  //               ? Container()
  //               : SizedBox(
  //             child: (videoController == null)
  //                 ? Image.file(File(imagePath))
  //                 : Container(
  //               child: Center(
  //                 child: AspectRatio(
  //                     aspectRatio:
  //                     videoController.value.size != null
  //                         ? videoController.value.aspectRatio
  //                         : 1.0,
  //                     child: VideoPlayer(videoController)),
  //               ),
  //               decoration: BoxDecoration(
  //                   border: Border.all(color: Colors.pink)),
  //             ),
  //             width: 64.0,
  //             height: 64.0,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

}