import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'auth/auth_credentials.dart';
import 'auth/auth_repository.dart';
import 'data_repository.dart';
import 'models/User.dart';
import 'session_state.dart';
import 'dart:io';

class SessionCubit extends Cubit<SessionState> {
  final AuthRepository authRepo;
  final DataRepository dataRepo;

  SessionCubit({
    @required this.authRepo,
    @required this.dataRepo,
  }) : super(UnknownSessionState()) {
    attemptAutoLogin();
  }

  void attemptAutoLogin() async {
    try {
      final credentials = await authRepo.attemptAutoLogin();
      if (credentials == null) {
        throw Exception('User not logged in');
      }

      // User user = await dataRepo.getUserById(userId);
      // if (user == null) {
      //   user = await dataRepo.createUser(
      //     userId: userId,
      //     username: 'User-${UUID()}',
      //   );
      // }
      User user = User(id: credentials.userId, username: credentials.username);
      emit(Authenticated(user: user));
    } on Exception {
      emit(Unauthenticated());
    }
  }

  void showAuth() => emit(Unauthenticated());

  void showSession(AuthCredentials credentials) async {
    try {
      // User user = await dataRepo.getUserById(credentials.userId);
      //
      // if (user == null) {
      //   user = await dataRepo.createUser(
      //     userId: credentials.userId,
      //     username: credentials.username,
      //     email: credentials.email,
      //   );
      // }
      User user = User(id: credentials.userId, username: credentials.username);
      emit(Authenticated(user: user));
    } catch (e) {
      emit(Unauthenticated());
    }
  }

  void signOut() {
    authRepo.signOut();
    emit(Unauthenticated());
  }
}
