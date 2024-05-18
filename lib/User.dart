class User {
  String name;
  String id;
  String email;
  List<dynamic> token;
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
