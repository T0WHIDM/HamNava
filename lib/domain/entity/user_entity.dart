class UserEntity {
  final String id;
  final String userName;
  // final String? avatar;
  final String email;
  final String name;
  final List<UserEntity> friends;

  UserEntity({
    required this.userName,
    required this.id,
    // this.avatar,
    required this.email,
    required this.name,
    required this.friends,
  });
}
