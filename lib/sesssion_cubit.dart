
import 'package:camera_app/auth/auth_credentials.dart';
import 'package:camera_app/auth/auth_repository.dart';
import 'package:camera_app/session_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SessionCubit extends Cubit<SessionState> {
  final AuthRepository repo;

  SessionCubit({this.repo}): super(UnknownSesionState()) {
     attemptAutoLogin();
  }

  void attemptAutoLogin() async {
    try {
      final userId = await repo.attemptAutoLogin();

      final user = userId;
      emit(Authenticated(user: user));
    } catch (e) {
      emit(Unauthenticated());
    }
  }

  void showAuth() => emit(Unauthenticated());
  void showSession(AuthCredentials credentials) {
    // not complete access user from data repository
    final user = credentials.username;
    emit(Authenticated(user: user));
  }

  void signOut() {
    repo.signOut();
    emit(Unauthenticated());
  }
}