
import 'package:amplify_flutter/amplify.dart';

import 'models/User.dart';

class DataRepository {
  // TODO change back
  //Future<User> getUserById(String userId) async {
  Future<User> getUserById(String username) async {
    try {
      final users = await Amplify.DataStore.query(
        User.classType,
        where: User.USERNAME.eq(username),
      );

      return users.isNotEmpty ? users.first : null;
    } catch (e) {
      throw e;
    }
  }

  Future<User> createUser(
    String userId,
    String username,
  ) async {
    // TODO: add password?
    final newUser = User(id: userId, username: username);
    try {
      await Amplify.DataStore.save(newUser);
      return newUser;
    } catch (e) {
      throw e;
    }
  }
}