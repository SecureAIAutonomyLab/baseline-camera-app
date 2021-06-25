/*
  Created By: Nathan Millwater
  Description: Holds the current state of the login form. Includes
               the current username and password with the form
               submission status
 */


import '../form_submission_status.dart';

/// Holds the current state of the login form
class LoginState {
  final String username;
  // getter
  bool get isValidUsername => username.length > 3;

  final String password;
  // getter
  bool get isValidPassword => password.length > 8;

  FormSubmissionStatus formStatus;

  LoginState({
    this.username = '',
    this.password = '',
    this.formStatus = const InitialFormStatus(),
  });

  /// Create a new LoginState object and copy over the
  /// old values and any new values that changed
  /// Parameters: The username and password from login form field and
  /// the current status of the form
  /// Returns: A new login state with the updated information
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
