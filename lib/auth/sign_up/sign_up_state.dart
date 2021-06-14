
import 'package:camera_app/auth/form_submission_status.dart';

class SignUpState {
  final String username;
  // getter for username validation
  bool get isValidUsername => username.length > 3;

  final String password;
  // getter for password
  bool get isValidPassword => password.length > 6;

  FormSubmissionStatus formStatus;

  /// constructor
  SignUpState({
    this.username = '',
    this.password = '',
    this.formStatus = const InitialFormStatus(),
  });

  /// copy constructor for LoginState
  SignUpState copyWith({
    String username,
    String password,
    FormSubmissionStatus formStatus,
  }) {
    return SignUpState(
      username: username ?? this.username,
      password: password ?? this.password,
      formStatus: formStatus ?? this.formStatus,
    );
  }
}