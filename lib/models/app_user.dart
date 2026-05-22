class AppUser {
  final String username;
  final String email;
  bool isVerified;
  String? verificationCode;

  AppUser({
    required this.username,
    required this.email,
    this.isVerified = false,
    this.verificationCode,
  });
}
