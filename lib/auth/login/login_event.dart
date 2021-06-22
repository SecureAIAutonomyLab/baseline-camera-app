/*
  Created By: Nathan Millwater
  Description: Holds the possible events that may occur in
               the login view
 */

abstract class LoginEvent {}

class LoginUsernameChanged extends LoginEvent {
  final String username;

  LoginUsernameChanged({this.username});
}

class LoginPasswordChanged extends LoginEvent {
  final String password;

  LoginPasswordChanged({this.password});
}

class LoginSubmitted extends LoginEvent {}

class LoginFacebook extends LoginEvent {}

class LoginGoogle extends LoginEvent {}