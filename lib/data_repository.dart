/*
  Created By: Nathan Millwater
  Description: Holds logic for manipulating the AWS Datastore repository.
               Currently not used
 */

import 'package:amplify_flutter/amplify.dart';
import 'package:camera_app/user.dart';



class DataRepository {

  /// Returns a user from the repository queried by their id
  // Future<User> getUserById(String userId) async {
  //   try {
  //     final users = await Amplify.DataStore.query(
  //       User.classType,
  //       where: User.ID.eq(userId),
  //     );
  //     return users.isNotEmpty ? users.first : null;
  //   } catch (e) {
  //     throw e;
  //   }
  // }

  /// Creates and returns a new user while saving to the datastore repository
  // Future<User> createUser({
  //   String userId,
  //   String username,
  //   String email,
  // }) async {
  //   final newUser = User(id: userId, username: username, email: email);
  //   try {
  //     await Amplify.DataStore.save(newUser);
  //     return newUser;
  //   } catch (e) {
  //     throw e;
  //   }
  // }
}
