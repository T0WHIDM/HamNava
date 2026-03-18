abstract class IAuthDataSource {
  
  Future<void> login(String userName, String password);

  Future<void> register(
    String name,
    String userName,
    String email,
    String password,
    String passwordConfirm,
  );

  Future<void> logOut();


}
