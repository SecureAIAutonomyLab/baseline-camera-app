// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_datastore/amplify_datastore.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:camera/camera.dart';
import 'package:camera_app/loading_view.dart';
import 'package:camera_app/sesssion_cubit.dart';
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
  CameraExampleHome({Key key, this.username}) : super(key: key);

  @override
  CameraExampleHomeState createState() {
    return CameraExampleHomeState(this.username);
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

void logError(String code, String message) =>
    print('Error: $code\nError Message: $message');

void _setOrientation () {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.portraitUp,
  ]);
}

class _CameraAppState extends State<CameraApp> {
  bool _isAmplifyConfigured = false;

  @override
  void initState() {
    super.initState();
    _configureAmplify();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: _isAmplifyConfigured ? _setupApp(context) : LoadingView(),
    );
  }

  /// Setup providers and navigators
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
        child: AppNavigator(context),
      ),
    );
  }

  Future<void> _configureAmplify() async {
    try {
      await Amplify.addPlugins([
        AmplifyAuthCognito(),
        AmplifyDataStore(modelProvider: ModelProvider.instance),
        AmplifyAPI(),
        AmplifyStorageS3(),
      ]);

      await Amplify.configure(amplifyconfig);
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

List<CameraDescription> cameras = [];

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

