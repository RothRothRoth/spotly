class AppUser {
  final String username;
  final String email;
  bool isVerified;
  String? verificationCode;
  String? photoUrl;

  AppUser({
    required this.username,
    required this.email,
    this.isVerified = false,
    this.verificationCode,
    this.photoUrl,
  });
}
