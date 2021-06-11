import 'package:flutter/cupertino.dart';

class AuthCredentials {
  final String username;
  final String password;
  String userId;

  AuthCredentials({
    @required this.username,
    this.password,
    this.userId,
  });

}