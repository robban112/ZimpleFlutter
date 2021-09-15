class UserParameters {
  String email;
  String token;
  String company;
  String name;
  bool isAdmin;
  String? profilePicturePath;
  String? fcmToken;

  UserParameters(
      {required this.email,
      required this.token,
      required this.company,
      required this.isAdmin,
      required this.name,
      required this.profilePicturePath,
      required this.fcmToken});
}
