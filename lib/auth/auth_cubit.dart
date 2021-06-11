
import 'package:amplify_flutter/amplify.dart';
import 'package:camera_app/auth/auth_credentials.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum AuthState {
  login,
  signUp,
}

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthState.login);

  AuthCredentials credentials;

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
}