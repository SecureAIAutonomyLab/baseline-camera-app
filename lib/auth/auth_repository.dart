

import 'package:flutter/cupertino.dart';

/// Contact repository and login
class AuthRepository {

  Future<String> attemptAutoLogin() async {
    await Future.delayed(Duration(seconds: 1));
    throw Exception('not signed in');
  }

  Future<String> login({
    @required String username,
    @required String password,
  }) async {
    // print("Attempting Login");
    await Future.delayed(Duration(seconds: 3));
    // print("logged in");
    // throw Exception("Failed login");

  }

  Future<String> signUp({
    @required String username,
    @required String password,
  }) async {
    await Future.delayed(Duration(seconds: 2));
  }

  Future<void> signOut() async {
    await Future.delayed(Duration(seconds: 2));
  }
}