

/// Contact repository and login
class AuthRepository {
  Future<void> login() async {
    print("Attempting Login");
    await Future.delayed(Duration(seconds: 3));
    print("logged in");
    throw Exception("Failed login");
  }
}