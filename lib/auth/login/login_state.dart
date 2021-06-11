
import 'package:camera_app/auth/form_submission_status.dart';

class LoginState {
  final String username;
  // getter for username validation
  bool get isValidUsername => username.length > 3;

  final String password;
  // getter for password
  bool get isValidPassword => password.length > 6;

  final FormSubmissionStatus formStatus;

  /// constructor
  LoginState({
    this.username = '',
    this.password = '',
    this.formStatus = const InitialFormStatus(),
  });

  /// copy constructor for LoginState
  LoginState copyWith({
    String username,
    String password,
    FormSubmissionStatus formStatus,
  }) {
    return LoginState(
      username: username ?? this.username,
      password: password ?? this.password,
      formStatus: formStatus ?? this.formStatus,
    );
  }
}