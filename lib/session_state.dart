/*
  Created By: Nathan Millwater
  Description: Classes to represent different states the session can have
 */

import 'package:camera_app/user.dart';
import 'package:flutter/material.dart';


abstract class SessionState {}

class UnknownSessionState extends SessionState {}

class Unauthenticated extends SessionState {}

class Authenticated extends SessionState {
  // Authenticated requires a user to be defined
  final User user;

  Authenticated({@required this.user});
}