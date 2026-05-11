class AppUser {
  final int id;
  final String name;
  final String email;
  final bool onboardingCompleted;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.onboardingCompleted = false,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as int,
      name: map['name'] as String,
      email: map['email'] as String,
      onboardingCompleted: (map['onboarding_completed'] as int? ?? 1) == 1,
    );
  }
}
