
import 'package:amplify_flutter/amplify.dart';
import 'package:camera_app/auth/auth_credentials.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../sesssion_cubit.dart';

enum AuthState {
  login,
  signUp,
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({this.sessionCubit}) : super(AuthState.login);

  AuthCredentials credentials;
  final SessionCubit sessionCubit;

  void showLogin() => emit(AuthState.login);
  void showSignUp() => emit(AuthState.signUp);
  void showConfirmSignUp({
    String username,
    String password,
  }) {
    credentials = AuthCredentials(
      username: username,
      password: password,
    );
    emit(AuthState.login);
  }
  
  void launchSession(AuthCredentials credentials) => sessionCubit.showSession(credentials);
}