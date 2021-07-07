/*
  Created By: Nathan Millwater
  Description: Holds the camera home widget tree. Once the user
               has logged in, the session starts and this widget
               tree is displayed.
 */

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:camera_app/camera_example_home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'camera_cubit.dart';
import 'main.dart';
import 'models/cart_model.dart';
import 'models/catalog_model.dart';

/// A wrapper class that wraps the upload file boolean variables
class BooleanWrap {
  BooleanWrap(bool a, bool b, bool c) {
    this.finished = a;
    this.started = b;
    this.upload = c;
  }
  bool finished;
  bool started;
  bool upload;
}

/// Wrapper class that stores the isVideoChunked boolean variable
/// and the number of chunked videos created
class ChunkVideoData {
  bool chunkVideo;
  int videoCount;

  ChunkVideoData({this.chunkVideo, this.videoCount});
}

class CameraViewBuild {
  BuildContext context;
  CameraExampleHomeState state;
  CameraController controller;
  BooleanWrap isFileFinishedUploading;
  bool enableAudio;
  String uploadMessage;

  // named parameter constructor
  CameraViewBuild(
      {this.context,
      this.state,
      this.controller,
      this.isFileFinishedUploading,
      this.enableAudio,
      this.uploadMessage});

  /// Messages for the snack bar
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// This called by the main build function in the home class
  Widget build() {
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
          Text("Action Buttons"),
          captureActionRowWidget(),
          // Button to show camera options widget
          TextButton(
              onPressed: controller != null
                  ? state.onCameraOptionsButtonPressed
                  : null,
              child: Text(
                "Camera Options",
                style: TextStyle(fontSize: 15),
              )),
          // Display the camera options
          cameraOptionsWidget(),
        ],
      ),
      // Navigation bar to switch pages
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_customize), label: "Action Catalog"),
          BottomNavigationBarItem(
              icon: Icon(Icons.pending_actions), label: "Current Actions"),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home")
        ],
        currentIndex: 2,
        onTap: controller != null &&
                controller.value.isInitialized &&
                !controller.value.isRecordingVideo &&
                !isFileFinishedUploading.started
            ? (index) {
                changePage(index, context);
              }
            : null,
      ),
    );
  }

  void changePage(int index, BuildContext context) {
    if (index == 0)
      context.read<CameraCubit>().showActionCatalog();
    else if (index == 1) context.read<CameraCubit>().showActionList();
  }

  /// Chooses the appbar based on the device platform
  /// Returns: Appbar Widget
  Widget chooseAppBar() {
    // if (Theme.of(context).platform == TargetPlatform.iOS) {
    //   return CupertinoNavigationBar(
    //     // leading: TextButton(
    //     //   child: Text("Sign Out", style: TextStyle(fontSize: 16),),
    //     //   onPressed: () => BlocProvider.of<SessionCubit>(context).signOut(),
    //     // ),
    //     middle: Text("Camera Home"),
    //     trailing: IconButton(
    //       icon: Icon(Icons.flip_camera_ios),
    //       onPressed: () {
    //         // Switch to a different camera
    //         state.cameraToggleButtonPressed();
    //       },
    //     ),
    //   );
    // }
    // else {
    // android platform
    Icon icon;
    if (Theme.of(context).platform == TargetPlatform.iOS)
      icon = Icon(Icons.flip_camera_ios);
    else
      icon = Icon(Icons.flip_camera_android);
    return AppBar(
      title: Text("Camera Home"),
      actions: [
        IconButton(
          icon: icon,
          onPressed: () {
            // Switch to a different camera
            state.cameraToggleButtonPressed();
          },
        )
      ],
    );
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
      // Show camera preview
      return AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: CameraPreview(controller),
      );
    }
  }

  /// Returns: toggle recording audio widget
  Widget toggleAudioWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text(
          'Enable Audio:',
          style: TextStyle(fontSize: 15),
        ),
        SizedBox(
          width: 5,
        ),
        // Android switch or IOS switch
        enableAudioSwitchType(),
      ],
    );
  }

  /// Choose the type of enable audio switch depending on the device platform
  /// Returns: a switch widget
  Widget enableAudioSwitchType() {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      // Use a cupertino switch if platform is IOS
      return CupertinoSwitch(
        value: state.enableAudio,
        onChanged: !controller.value.isRecordingVideo
            ? (bool value) {
                state.enableAudioSwitchChanged(value);
              }
            : null,
      );
    } else {
      // Use a material switch if platform is Android
      return Switch(
        value: state.enableAudio,
        onChanged: (bool value) {
          enableAudio = value;
          if (controller != null && state.audioSwitchState) {
            state.enableAudioSwitchChanged(value);
          }
        },
      );
    }
  }

  /// Displays the animation for brining up the camera options
  /// Returns: A dynamic sized widget according to the animation
  /// controller
  Widget cameraOptionsWidget() {
    return SizeTransition(
      sizeFactor: state.rowAnimation,
      child: ClipRect(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            changeResolutionWidget(),
            toggleAudioWidget(),
            // Display device Id
            TextButton(
                onPressed: () {
                  state.displayId = state.displayId ? false : true;
                  state.updateUI();
                },
                child: state.displayId
                    ? Text(
                        state.deviceId,
                        style: TextStyle(fontSize: 13, color: Colors.black),
                      )
                    : Text(
                        "Display Device ID",
                        style: TextStyle(fontSize: 13, color: Colors.black),
                      )),
          ],
        ),
      ),
    );
  }

  /// Display the change resolution widget on the page
  /// Returns: A row that holds the text and buttons for changing the
  /// camera resolution
  Widget changeResolutionWidget() {
    String currentResolution = state.resolution.toString().substring(17);
    currentResolution = currentResolution.substring(0, 1).toUpperCase() +
        currentResolution.substring(1);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          children: [
            Text(
              "Resolution: ",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(
              width: 5,
            ),
            Text(
              currentResolution,
              style: TextStyle(fontSize: 15),
            ),
          ],
        ),
        cupertinoActionSheet(),
      ],
    );
  }

  /// Displays an action menu for the user to change the camera resolution
  /// Returns: A button that brings up an action sheet of choices
  Widget cupertinoActionSheet() {
    return CupertinoButton(
      onPressed: !controller.value.isRecordingVideo
          ? () async {
              final currentResolution = state.resolution.toString();
              var returned = await showCupertinoModalPopup<String>(
                context: context,
                builder: (BuildContext context) => CupertinoActionSheet(
                  title: Text('Choose a resolution',
                      style: TextStyle(fontSize: 18)),
                  message: Text("The resolution is currently set at " +
                      currentResolution.substring(17)),
                  actions: <CupertinoActionSheetAction>[
                    CupertinoActionSheetAction(
                        child: const Text('High'),
                        onPressed: () {
                          Navigator.of(context).pop("high");
                        }),
                    CupertinoActionSheetAction(
                        child: const Text('Medium'),
                        onPressed: () {
                          Navigator.of(context).pop("medium");
                        }),
                    CupertinoActionSheetAction(
                        child: const Text('Low'),
                        onPressed: () {
                          Navigator.of(context).pop("low");
                        })
                  ],
                  cancelButton: CupertinoActionSheetAction(
                      child: const Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop("cancel");
                      }),
                ),
              );
              // call for resolution change
              state.changeResolution(returned);
            }
          : null,
      child: const Text('Change Resolution'),
    );
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
            onPressed: () async {
              if (controller != null &&
                      controller.value.isInitialized &&
                      !controller.value.isRecordingVideo &&
                      !isFileFinishedUploading
                          .started // only if finished uploading
                  ) if (await isInternetConnected())
                state.onTakePictureButtonPressed();
              else
                state.showInSnackBar("You are not connected to the internet");
            }),
        IconButton(
            icon: const Icon(Icons.videocam),
            color: Colors.blue,
            // If all boolean values are true, activate button otherwise do nothing
            onPressed: () async {
              if (controller != null &&
                      controller.value.isInitialized &&
                      !controller.value.isRecordingVideo &&
                      !isFileFinishedUploading
                          .started // only if finished uploading
                  ) if (await isInternetConnected())
                state.onVideoRecordButtonPressed();
              else
                state.showInSnackBar("You are not connected to the internet");
            }),
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

  Widget captureActionRowWidget() {
    // We must create a list of widgets to add
    var cart = context.watch<CartModel>();
    List<Widget> buttons = [];
    // cycle through the items list and create a button widget
    for (Item item in cart.items) {
      Widget button = TextButton(
          onPressed: controller != null &&
                  controller.value.isInitialized &&
                  controller.value.isRecordingVideo
              ? () {
                  state.onActionButtonPressed(item.name);
                }
              : null,
          child: Column(
            children: [
              SizedBox(
                  width: 30,
                  height: 10,
                  child: DecoratedBox(
                      decoration: BoxDecoration(color: item.color))),
              Text(item.name),
            ],
          ));
      buttons.add(button);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        children: buttons,
      ),
    );
  }

  /// Displays a dialog box that prompts the user if they want to upload their file
  /// Returns: A future object, indicates function is not synchronous
  Future<void> showUploadDialogBox() {
    if (Theme.of(context).platform == TargetPlatform.android)
      return materialDialog();
    else
      return cupertinoDialog();
  }

  Future<Widget> cupertinoDialog() {
    return showCupertinoDialog<Widget>(
        // User cannot dismiss the dialog
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
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
                  child: Text("No")),
              // Yes button
              CupertinoDialogAction(
                  onPressed: () async {
                    final connected = await isInternetConnected();
                    Navigator.of(context).pop();
                    if (connected) {
                      isFileFinishedUploading.upload = true;
                    } else {
                      state.showInSnackBar(
                          "You are not connected to the internet");
                    }
                  },
                  child: Text("Yes"))
            ],
          );
        });
  }

  Future<Widget> materialDialog() {
    return showDialog<Widget>(
        // User cannot dismiss the dialog
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(uploadMessage),
            content: Text("Do you want to upload this file to AWS?"),
            actions: [
              // No button
              TextButton(
                  onPressed: () {
                    isFileFinishedUploading.upload = false;
                    Navigator.of(context).pop();
                  },
                  child: Text("No")),
              // Yes button
              TextButton(
                  onPressed: () async {
                    final connected = await isInternetConnected();
                    Navigator.of(context).pop();
                    if (connected) {
                      isFileFinishedUploading.upload = true;
                    } else {
                      state.showInSnackBar(
                          "You are not connected to the internet");
                    }
                  },
                  child: Text("Yes"))
            ],
          );
        });
  }

  Future<bool> isInternetConnected() async {
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
    return null;
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
