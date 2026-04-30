
abstract class AuthEvent {}

class AuthLoginEvent extends AuthEvent {
 final String userName;
 final String password;

  AuthLoginEvent(this.userName, this.password);
}

class AuthRegisterEvent extends AuthEvent {
  final String name;
  final String username;
  final String email;
  final String password;
  final String passwordConfirm;
  // final File? avatarFile;

  AuthRegisterEvent(
    this.name,
    this.username,
    this.email,
    this.password,
    this.passwordConfirm,
    // this.avatarFile,
  );
}

class AuthLogOutEvent extends AuthEvent {}
