abstract class IAuthDataSource {
  //login
  Future<void> login(String userName, String password);

  //register
  Future<void> register(
    String name,
    String userName,
    String email,
    String password,
    String passwordConfirm,
    // File? avatarFile,
  );

  //log out
  Future<void> logOut();
}
