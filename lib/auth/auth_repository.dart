import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify.dart';
import 'package:camera_app/auth/auth_credentials.dart';
import 'package:flutter/foundation.dart';

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

  Future<String> _getUsername() async {
    try {
      final attributes = await Amplify.Auth.getCurrentUser();
      print(attributes.username);
      return attributes.username;
    } catch (e) {
      throw e;
    }
  }

  Future<AuthCredentials> attemptAutoLogin() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      final username = await _getUsername();
      final userId = await _getUserIdFromAttributes();

      return session.isSignedIn ? (AuthCredentials(username: username, userId: userId)) : null;
    } catch (e) {
      throw e;
    }
  }

  Future<String> login({
    @required String username,
    @required String password,
  }) async {
    try {
      final result = await Amplify.Auth.signIn(
        username: username.trim(),
        password: password.trim(),
      );

      return result.isSignedIn ? (await _getUserIdFromAttributes()) : null;
    } catch (e) {
      throw (e);
    }
  }

  Future<bool> signUp({
    @required String username,
    @required String email,
    @required String password,
  }) async {
    final options =
    CognitoSignUpOptions(userAttributes: {'email': email.trim()});
    try {
      print("username: " + username);
      print('password: ' + password);
      print("email: " + email);
      final result = await Amplify.Auth.signUp(
        username: username.trim(),
        password: password.trim(),
        options: options,
      );
      return result.isSignUpComplete;
    } catch (e) {
      throw e;
    }
  }

  Future<bool> confirmSignUp({
    @required String username,
    @required String confirmationCode,
  }) async {
    try {
      final result = await Amplify.Auth.confirmSignUp(
        username: username.trim(),
        confirmationCode: confirmationCode.trim(),
      );
      return result.isSignUpComplete;
    } catch (e) {
      throw e;
    }
  }

  Future<void> signOut() async {
    await Amplify.Auth.signOut();
  }
}
