class AppUser {
  final String uid;
  final String email;
  final String? displayName;
  final String role; // 'buyer', 'seller', or 'both'
  final int trustScore;

  AppUser({
    required this.uid,
    required this.email,
    this.displayName,
    required this.role,
    this.trustScore = 100,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'role': role,
      'trustScore': trustScore,
    };
  }
}