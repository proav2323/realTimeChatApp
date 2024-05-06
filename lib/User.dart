class User {
  String name;
  String id;
  String email;
  String socketId;
  String? profileImg;
  bool online;

  User({
    required this.name,
    required this.id,
    required this.email,
    required this.socketId,
    required this.online,
    this.profileImg = null,
  });
}
