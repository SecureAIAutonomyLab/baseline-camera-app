/*
  Created By: Nathan Millwater
  Description: Holds the logic for changing session states. Emits
               states to change layout of widgets
 */

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth/auth_credentials.dart';
import 'auth/auth_repository.dart';
import 'data_repository.dart';
import 'models/User.dart';
import 'session_state.dart';

class SessionCubit extends Cubit<SessionState> {
  final AuthRepository authRepo;
  final DataRepository dataRepo;

  // Constructor
  SessionCubit({
    @required this.authRepo,
    @required this.dataRepo,
  }) : super(UnknownSessionState()) {
    attemptAutoLogin();
  }

  /// Try and fetch fetch the current session and login
  void attemptAutoLogin() async {
    try {
      final credentials = await authRepo.attemptAutoLogin();
      if (credentials == null) {
        throw Exception('User not logged in');
      }

      // Create user object to store credentials
      User user = User(id: credentials.userId, username: credentials.username);
      emit(Authenticated(user: user));
    } on Exception {
      // Emit unauthenticated state if login failed
      emit(Unauthenticated());
    }
  }

  /// Changes the navigator to show login screen
  void showAuth() => emit(Unauthenticated());

  /// Uses credentials to show the camera home screen by emitting authenticated state
  void showSession(AuthCredentials credentials) async {
    try {
      User user = User(id: credentials.userId, username: credentials.username);
      emit(Authenticated(user: user));
    } catch (e) {
      emit(Unauthenticated());
    }
  }

  /// Attempt to sign out of the current account. If sign out failed,
  /// don't change states
  void signOut() async {
    bool result = await authRepo.signOut();

    // if sign out failed emit unauthenticated
    if (result) {
      emit(Unauthenticated());
      print("Unauthenticated");
    }
  }

}