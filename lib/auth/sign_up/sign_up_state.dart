/*
  Created By: Nathan Millwater
  Description: Holds the current state of the sign up form. Includes
               the current username, email, and password with the form
               submission status
 */

import '../form_submission_status.dart';

class SignUpState {
  final String username;
  // getter
  bool get isValidUsername => username.length > 3;

  final String email;
  // getter
  bool get isValidEmail => email.contains('@');

  final String password;
  // getter
  bool get isValidPassword => password.length > 8;

  FormSubmissionStatus formStatus;

  SignUpState({
    this.username = '',
    this.email = '',
    this.password = '',
    this.formStatus = const InitialFormStatus(),
  });

  /// Create a new SignUpState object and copy over the
  /// old values and any new values that changed
  SignUpState copyWith({
    String username,
    String email,
    String password,
    FormSubmissionStatus formStatus,
  }) {
    return SignUpState(
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      formStatus: formStatus ?? this.formStatus,
    );
  }
}
