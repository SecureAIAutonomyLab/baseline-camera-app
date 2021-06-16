

import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:flutter/cupertino.dart';

/// Contact repository and login
class AuthRepository {

  Future<String> _getUserIdFromAttributes() async {
    try {
      final attributes = await Amplify.Auth.fetchUserAttributes();
      final userId = attributes
      .firstWhere((element) => element.userAttributeKey == 'sub')
      .value;
      return userId;
    } catch (e) {
      throw e;
    }
  }

  Future<String> attemptAutoLogin() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();

      return session.isSignedIn ? (await _getUserIdFromAttributes()) : null;
    } catch (e) {
      throw e;
    }
  }

  Future<String> login({
    @required String username,
    @required String password,
  }) async {

    try {
      // TODO revert back to auth sign in
      // final result = await Amplify.Auth.signIn(
      //     username: username.trim(),
      //     password: password.trim(),
      // );
      //
      // return result.isSignedIn ? (await _getUserIdFromAttributes()) : null;
      return 'randomUserID';
    } catch (e) {
      throw e;
    }

  }

  Future<bool> signUp({
    @required String username,
    @required String password,
  }) async {

    try {
      Map<String, String> attributes = {

      };
      final result = await Amplify.Auth.signUp(
          username: username.trim(),
          password: password.trim(),
          options: CognitoSignUpOptions(userAttributes: attributes),
      );

      return result.isSignUpComplete;
    } catch (e) {
      throw Exception("Auth Repo signup failed");
    }

  }

  Future<void> signOut() async {
    await Amplify.Auth.signOut();
  }
}