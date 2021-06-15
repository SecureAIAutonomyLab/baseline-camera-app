import 'package:flutter/material.dart';

import 'models/User.dart';

abstract class SessionState {}

class UnknownSesionState extends SessionState {}

class Unauthenticated extends SessionState {}

class Authenticated extends SessionState {
  final User user;

  Authenticated({@required this.user});
}