
import 'package:amplify_api/amplify_api.dart';
import 'package:camera_app/auth/auth_credentials.dart';
import 'package:camera_app/auth/auth_repository.dart';
import 'package:camera_app/data_repository.dart';
import 'package:camera_app/session_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'models/User.dart';

class SessionCubit extends Cubit<SessionState> {
  final AuthRepository authRepo;
  final DataRepository dataRepo;

  SessionCubit({
    @required this.authRepo,
    @required this.dataRepo,
  }): super(UnknownSesionState()) {
     attemptAutoLogin();
  }

  void attemptAutoLogin() async {
    try {
      final userId = await authRepo.attemptAutoLogin();
      if (userId == null) {
        throw Exception("User not logged in");
      }
      User user = await dataRepo.getUserById(userId);

      if (user == null) {
        user = await dataRepo.createUser(userId, "User-${UUID()}");
      }

      emit(Authenticated(user: user));
    } catch (e) {
      emit(Unauthenticated());
    }
  }

  void showAuth() => emit(Unauthenticated());
  void showSession(AuthCredentials credentials) async {
    try {
      User user = await dataRepo.getUserById(credentials.userId);
      if (user == null) {
        user = await dataRepo.createUser(credentials.userId, credentials.username);
      }

      emit(Authenticated(user: user));
    } catch (e) {
      throw e;
    }
  }

  void signOut() {
    authRepo.signOut();
    emit(Unauthenticated());
  }
}