/*
  Created By: Nathan Chan
  Description: Holds the camera home widget tree. Once the user
               has logged in, the session starts and this widget
               tree is displayed.
 */

import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:camera_app/session_cubit.dart';
import 'package:camera_app/storage_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'main.dart';
import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:device_info/device_info.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:location/location.dart';
import 'package:flutter/cupertino.dart';

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


/// Home Screen of the application
/// Displays the camera and a few buttons that performs the actions of the camera
class CameraExampleHomeState extends State<CameraExampleHome>
    with WidgetsBindingObserver {
  CameraController controller;
  String imagePath;
  String videoPath;
  VideoPlayerController videoController;
  VoidCallback videoPlayerListener;
  bool enableAudio = true;
  String deviceId;
  String latitudeAndLongitude; // latittude-longitude
  int cameraDescriptionIndex = 0;
  StorageRepository storageRepo;
  BooleanWrap isFileFinishedUploading;
  String username; //username from user
  String userID; // userId from user
  String uploadMessage; // Message when uploading
  static const VIDEO_TIME_LIMIT = 120;


  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};

  // Constructor
  CameraExampleHomeState(String username, String userID) {
    this.username = username;
    this.userID = userID;
  }

  // Called upon initialization of the object
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initPlatformState();
    // initialize camera controller
    controller = CameraController(
      cameras[cameraDescriptionIndex],
      ResolutionPreset.medium,
      enableAudio: enableAudio,
    );
    controller.initialize();
    // initialize storage repository
    storageRepo = StorageRepository();
    // initialize boolean wrap
    isFileFinishedUploading = BooleanWrap(false, false, false);
    // set upload default message;
    uploadMessage = "Upload";
    // set preferred orientations
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
  }

  // Called when widget is deleted
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Requests location permission and saves device data
  Future<void> initPlatformState() async {
    Map<String, dynamic> deviceData;

    // Checks the device type. (Android or ios)
    try {
      if (Platform.isAndroid) {
        deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
        deviceId = deviceData['id'];
      } else if (Platform.isIOS) {
        deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
        deviceId = deviceData['identifierForVendor'];
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }

    // Gets the initial location of user. It serves as a permission grantor.
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    // checks if location service has been enabled
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    // Checks if location permission has been granted
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    // saves device data
    if (!mounted) return;
    setState(() {
      _deviceData = deviceData;
    });
  }

  /// Maps the android information.
  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'androidId': build.androidId,
      'systemFeatures': build.systemFeatures,
    };
  }

  /// Maps ios information.
  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }

  /// App state changed before we got the chance to initialize.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
    } else if (state == AppLifecycleState.resumed) {
      if (controller != null) {
        // Initialized a new camera
        onNewCameraSelected(controller.description);
      }
    }
  }

  /// Messages for the snack bar
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


  /// Chooses the appbar based on platform
  Widget _chooseAppBar() {
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
            _cameraToggleButtonPressed();
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
              _cameraToggleButtonPressed();
            },
          )
        ],
      );
    }
  }

  /// Builds the application. Sets the layout and functionality of the application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _chooseAppBar(),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              child: Padding(
                // box around camera preview
                padding: const EdgeInsets.all(1.0),
                child: Center(
                  child: _cameraPreviewWidget(),
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
          _captureControlRowWidget(),
          // Capture audio or not
          _toggleAudioWidget(),
        ],
      ),
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
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
    if (controller == null || !controller.value.isInitialized) {
      if (cameras.isNotEmpty) {
        // Camera disposed error occurs here
        onNewCameraSelected(cameras[cameraDescriptionIndex]);
        onNewCameraSelected(cameras[cameraDescriptionIndex]);
      }
      else {
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


  /// Returns a toggle recording audio widget
  Widget _toggleAudioWidget() {
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
          _enableAudioSwitchType(),
        ],
      ),
    );
  }

  /// Choose the type of enable audio switch depending on platform
  Widget _enableAudioSwitchType() {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      // Use a cupertino switch if platform is IOS
      return CupertinoSwitch(
        value: enableAudio,
        onChanged: (bool value) {
          enableAudio = value;
          if (controller != null) {
            onNewCameraSelected(controller.description);
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
            onNewCameraSelected(controller.description);
          }
        },
      );
    }
  }

  /// Display the thumbnail of the captured image or video.
  /// Is not currently being used
  Widget _thumbnailWidget() {
    return Expanded(
      child: Align(
        alignment: Alignment.centerRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            videoController == null && imagePath == null
                ? Container()
                : SizedBox(
              child: (videoController == null)
                  ? Image.file(File(imagePath))
                  : Container(
                child: Center(
                  child: AspectRatio(
                      aspectRatio:
                      videoController.value.size != null
                          ? videoController.value.aspectRatio
                          : 1.0,
                      child: VideoPlayer(videoController)),
                ),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.pink)),
              ),
              width: 64.0,
              height: 64.0,
            ),
          ],
        ),
      ),
    );
  }

  /// Display the control bar with buttons to take pictures and record videos.
  Widget _captureControlRowWidget() {
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
              ? onTakePictureButtonPressed
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
              ? onVideoRecordButtonPressed
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
              ? onResumeButtonPressed
              : onPauseButtonPressed)
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.stop),
          color: Colors.red,
          // If all boolean values are true, activate button otherwise do nothing
          onPressed: controller != null &&
              controller.value.isInitialized &&
              controller.value.isRecordingVideo
              ? onStopButtonPressed
              : null,
        )
      ],
    );
  }

  /// Display a camera toggle button to switch to a new camera when pressed
  void _cameraToggleButtonPressed() {
    print("Username: " + username);
    print("userId : " + userID);
    // Do nothing if no cameras are detected
    if (cameras.isEmpty) {
      return;
    } else {
      if (controller != null && controller.value.isRecordingVideo) {
        return;
      }
      else {
        // Cycle through cameras
        cameraDescriptionIndex++;
        if (cameraDescriptionIndex == cameras.length) {
          cameraDescriptionIndex = 0;
        }
        // Initialize new camera
        onNewCameraSelected(cameras[cameraDescriptionIndex]);
      }
    }
  }

  /// Timestamp when a picture or video is taken.
  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  /// create the snack bar and display in Scaffold
  void showInSnackBar(String message) {
    SnackBar bar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(bar);
  }

  /// Dispose of CameraController and reinitialize new when a different camera is selected.
  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }

    controller = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      enableAudio: enableAudio,
    );

    // If the controller is updated then update the UI.
    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        showInSnackBar('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  /// Set variables accordingly for taking a picture, calls takePicture()
  void onTakePictureButtonPressed() {
    uploadMessage = "Upload";
    takePicture().then((String filePath) {
      if (mounted) {
        setState(() {
          imagePath = filePath;
          videoController?.dispose();
          videoController = null;
        });
        if (filePath != null) {
          //showInSnackBar('Picture saved to gallery.');
        }
      }
    });
  }

  /// Starts video recording and displays a snack bar,
  /// calls startVideoRecording()
  void onVideoRecordButtonPressed() {
    uploadMessage = "Upload";
    startVideoRecording().then((String filePath) async {
      if (mounted) setState(() {});
      if (filePath != null) showInSnackBar('Video recording started.');

      // video time limit
      String path = videoPath;
      print("Started waiting");
      await _wait(VIDEO_TIME_LIMIT);
      print("Finished waiting");
      // If the controller is still recording the same video before the wait
      if (controller.value.isRecordingVideo && path == videoPath) {
        uploadMessage = "Video Time Limit Reached (2 minutes)";
        // Stop the recording
        onStopButtonPressed();
      }
    });
  }

  /// Stops video recording, calls stopVideoRecording()
  void onStopButtonPressed() {
    stopVideoRecording().then((_) {
      if (mounted) setState(() {});
      //showInSnackBar('Video recorded to gallery.');
    });
  }

  /// Pauses the video recording and displays a snack bar,
  /// calls pauseVideoRecording()
  void onPauseButtonPressed() {
    pauseVideoRecording().then((_) {
      if (mounted) setState(() {});
      showInSnackBar('Video recording paused.');
    });
  }

  /// Resumes the video recording and displays a snack bar
  /// , calls resumeVideoRecording()
  void onResumeButtonPressed() {
    resumeVideoRecording().then((_) {
      if (mounted) setState(() {});
      showInSnackBar('Video recording resumed.');
    });
  }


  /// Sets the path and starts the recording process.
  Future<String> startVideoRecording() async {
    if (!controller.value.isInitialized) {
      // Controller is not initialized
      showInSnackBar('Error: select a camera first.');
      return null;
    }

    // Record location data
    Location location = new Location();
    LocationData myLocation = await location.getLocation();
    String latitudeAndLongitude = myLocation.latitude.toString() + myLocation.longitude.toString();

    // Creates the file path where the video is to be saved
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Movies/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/$deviceId$latitudeAndLongitude${timestamp()}.mp4';

    if (controller.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return null;
    }

    // Start recording video
    try {
      videoPath = filePath;
      await controller.startVideoRecording(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  /// Stop the recording and save the video. Once saving is finished,
  /// upload the video to AWS
  Future<void> stopVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    // Record location data
    Location location = new Location();
    LocationData myLocation = await location.getLocation();

    try {
      // Save the video to the camera roll
      await controller.stopVideoRecording();
      GallerySaver.saveVideo(videoPath);

      // ask the user if they want to upload to AWS
      await _showUploadDialogBox();
      if (isFileFinishedUploading.upload) {
        // Change state of camera preview to show the upload process
        isFileFinishedUploading.finished = false;
        setState(() {isFileFinishedUploading.started = true;});

        // Upload video to AWS S3
        try {
          final video = File(videoPath);
          // Upload function from storage repo
          final videoKey = await storageRepo.uploadFile(
              username, video, '.mp4', userID, myLocation);

          // Change the state of the camera preview to show upload complete
          setState(() {
            isFileFinishedUploading.finished = true;
          });
          await _wait(2); // wait 2 seconds
          // Change camera preview back to camera
          setState(() {
            isFileFinishedUploading.started = false;
          });
        } on StorageException catch (e) {
          print(e.message);
        }
      }
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }

    // for video playback, not used
    //await _startVideoPlayer();
  }

  Future<void> pauseVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller.pauseVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> resumeVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller.resumeVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  /// Start playing the video that was just saved, not used
  Future<void> _startVideoPlayer() async {
    final VideoPlayerController vcontroller =
    VideoPlayerController.file(File(videoPath));
    videoPlayerListener = () {
      if (videoController != null && videoController.value.size != null) {
        // Refreshing the state to update video player with the correct ratio.
        if (mounted) setState(() {});
        videoController.removeListener(videoPlayerListener);
      }
    };
    vcontroller.addListener(videoPlayerListener);
    await vcontroller.setLooping(true);
    await vcontroller.initialize();
    await videoController?.dispose();
    final VideoPlayerController oldController = videoController;
    if (mounted) {
      setState(() {
        imagePath = null;
        videoController = vcontroller;
      });
    }
    await vcontroller.play();
    await oldController?.dispose();
  }

  /// Save the image to the camera roll. Once saving is finished,
  /// upload the image to AWS
  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }

    // Get the location data for the image
    Location location = new Location();
    LocationData myLocation = await location.getLocation();
    String latitudeAndLongitude = myLocation.latitude.toString() + myLocation.longitude.toString();

    // Get and save the filepath of the image
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/$deviceId$latitudeAndLongitude${timestamp()}.jpg';

    if (controller.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      // Save the image to the camera roll
      await controller.takePicture(filePath);
      GallerySaver.saveImage(filePath);

      // ask the user if they want to upload to AWS
      await _showUploadDialogBox();
      if (isFileFinishedUploading.upload) {
        // change state of camera preview
        isFileFinishedUploading.finished = false;
        setState(() {isFileFinishedUploading.started = true;});

        // upload image to AWS S3
        try {
          File image = File(filePath);
          // Upload function from storage repo
          final imageKey = await storageRepo.uploadFile(
              username, image, '.jpg', userID, myLocation);

          // Change the state of the camera preview to show upload complete
          setState(() {
            isFileFinishedUploading.finished = true;
          });
          await _wait(2); // wait 2 seconds
          // Change camera preview back to camera
          setState(() {
            isFileFinishedUploading.started = false;
          });

        } on StorageException catch (e) {
          print(e.message);
        }
      }
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  /// Displays a dialog box that prompts the user if they want to upload their file
  Future<void> _showUploadDialogBox() {
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
                onPressed: () {
                  isFileFinishedUploading.upload = true;
                  Navigator.of(context).pop();
                },
                child: Text("Yes")
              )
            ],
          );
        }
    );
  }

  /// Print out the camera error message
  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  /// Simple wait function that delays by a certain amount of seconds
  /// Must be used with "await" keyword
  Future<void> _wait(int seconds) {
    return Future.delayed(Duration(seconds: seconds));
  }
}