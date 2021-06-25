/*
  Created By: Nathan Millwater
  Description: Holds the possible events that may occur in
               the sign up view
 */

abstract class SignUpEvent {}

/// Event when user changes the text in the username field
class SignUpUsernameChanged extends SignUpEvent {
  final String username;

  SignUpUsernameChanged({this.username});
}

/// Event when user changes the text in the email field
class SignUpEmailChanged extends SignUpEvent {
  final String email;

  SignUpEmailChanged({this.email});
}

/// Event when user changes the text in the password field
class SignUpPasswordChanged extends SignUpEvent {
  final String password;

  SignUpPasswordChanged({this.password});
}

/// Event when the sign up button is pressed
class SignUpSubmitted extends SignUpEvent {}
