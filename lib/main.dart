/*
  Created By: Nathan Chan
  Description: Provides the setup for the app. It is the initial
               run configuration file
 */

import 'dart:async';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:camera/camera.dart';
import 'package:camera_app/loading_view.dart';
import 'package:camera_app/session_cubit.dart';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'amplifyconfiguration.dart';
import 'app_navigator.dart';
import 'auth/auth_repository.dart';
import 'camera_example_home.dart';
import 'data_repository.dart';
import 'models/ModelProvider.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';

class CameraExampleHome extends StatefulWidget {

  final String username;
  final String userID;
  // constructor
  CameraExampleHome({Key key, this.username, this.userID}) : super(key: key);

  // This is a stateful widget so it must create a state for itself
  @override
  CameraExampleHomeState createState() {
    return CameraExampleHomeState(this.username, this.userID);
  }
}

/// Returns a suitable camera icon for [direction].
IconData getCameraLensIcon(CameraLensDirection direction) {
  switch (direction) {
    case CameraLensDirection.back:
      return Icons.camera_rear;
    case CameraLensDirection.front:
      return Icons.camera_front;
    case CameraLensDirection.external:
      return Icons.camera;
  }
  throw ArgumentError('Unknown lens direction');
}

/// Print an error to the console
void logError(String code, String message) =>
    print('Error: $code\nError Message: $message');

class _CameraAppState extends State<CameraApp> {
  bool _isAmplifyConfigured = false;

  /// Called upon initialization of the CameraState object
  @override
  void initState() {
    super.initState();
    _configureAmplify();
  }

  /// The initial build method of the app. Builds the widget tree
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Make sure amplify is configured before showing the app
      home: _isAmplifyConfigured ? _setupApp(context) : LoadingView(),
    );
  }

  /// Setup providers and navigators for use later on in the widget tree.
  /// These are required to use any of the cubit or bloc logic in the widget tree
  Widget _setupApp(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => AuthRepository()),
        RepositoryProvider(create: (context) => DataRepository()),
      ],
      child: BlocProvider(
        create: (context) => SessionCubit(
            authRepo: context.read<AuthRepository>(),
            dataRepo: context.read<DataRepository>(),
        ),
        child: AppNavigator(),
      ),
    );
  }

  /// Adds the necessary plugins to configure amplify
  /// Amplify requires this function
  Future<void> _configureAmplify() async {
    try {
      await Amplify.addPlugins([
        AmplifyAuthCognito(), // For user authentication
        AmplifyDataStore(modelProvider: ModelProvider.instance), // Not used
        AmplifyAPI(), // Amplify base API
        AmplifyStorageS3(), // For S3 storage
      ]);

      // waits for amplify to finish configuring
      await Amplify.configure(amplifyconfig);
      // Set state method causes the widget to be rebuilt upon the change of
      // Certain variables
      setState(() {
        _isAmplifyConfigured = true;
      });
    } catch (e) {
      print(e);
    }
  }
}

class CameraApp extends StatefulWidget {
  // set orientation
  CameraApp() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
  }
  
  @override 
  State<StatefulWidget> createState() => _CameraAppState();
}

// List of available cameras to user
List<CameraDescription> cameras = [];

/// The start of the run configuration
Future<void> main() async {
  // Fetch the available cameras before initializing the app.
  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
  } on CameraException catch (e) {
    logError(e.code, e.description);
  }
  runApp(CameraApp());
}

