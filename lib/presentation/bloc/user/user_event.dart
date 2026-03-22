abstract class UserEvent {}

// ---------------- search user ----------------

class SearchUserEvent extends UserEvent {
  final String userName;

  SearchUserEvent(this.userName);
}

// ---------------- add friend ----------------

class AddFriendEvent extends UserEvent {
  final String userId;

  AddFriendEvent(this.userId);
}

// ---------------- friend List ----------------

class FriendListEvent extends UserEvent {
  final String userId;
  FriendListEvent(this.userId);
}
