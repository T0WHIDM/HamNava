abstract class AuthEvent {}

class AuthLoginEvent extends AuthEvent {
  String userName;
  String password;

  AuthLoginEvent(this.userName, this.password);
}

class AuthRegisterEvent extends AuthEvent {
  final String name;
  final String username;
  final String email;
  final String password;
  final String passwordConfirm;

  AuthRegisterEvent(
    this.name,
    this.username,
    this.email,
    this.password,
    this.passwordConfirm,
  );
}

class AuthLogOutEvent extends AuthEvent {}

