class User {
  String name;
  String id;
  String email;
  String token;
  String? profileImg;
  bool online;

  User({
    required this.name,
    required this.id,
    required this.email,
    required this.token,
    required this.online,
    this.profileImg = null,
  });
}
