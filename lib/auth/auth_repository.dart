

import 'package:flutter/cupertino.dart';

/// Contact repository and login
class AuthRepository {
  Future<void> login({
    @required String username,
    @required String password,
  }) async {
    // print("Attempting Login");
    // await Future.delayed(Duration(seconds: 3));
    // print("logged in");
    // throw Exception("Failed login");

  }

  Future<void> signUp({
    @required String username,
    @required String password,
  }) async {
    await Future.delayed(Duration(seconds: 2));
  }

  Future<void> signOut() async {
    await Future.delayed(Duration(seconds: 2));
  }
}