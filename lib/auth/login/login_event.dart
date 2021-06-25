/*
  Created By: Nathan Millwater
  Description: Holds the possible events that may occur in
               the login view
 */

abstract class LoginEvent {}

/// Event when user changes the text in the username field
class LoginUsernameChanged extends LoginEvent {
  final String username;

  LoginUsernameChanged({this.username});
}

/// Event when user changes the text in the password field
class LoginPasswordChanged extends LoginEvent {
  final String password;

  LoginPasswordChanged({this.password});
}

/// Event when standard login button is pressed
class LoginSubmitted extends LoginEvent {}

/// Event when login with facebook button is pressed
class LoginFacebook extends LoginEvent {}

/// Event when login with google button is pressed
/// not currently used
class LoginGoogle extends LoginEvent {}