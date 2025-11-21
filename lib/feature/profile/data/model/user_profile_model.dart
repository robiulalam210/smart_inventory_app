// user_profile_model.dart
class UserProfileModel {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String fullName;
  final String role;
  final String phone;
  final String profilePicture;
  final bool isVerified;

  UserProfileModel({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.role,
    required this.phone,
    required this.profilePicture,
    required this.isVerified,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      fullName: json['full_name'] ?? '',
      role: json['role'] ?? '',
      phone: json['phone'] ?? '',
      profilePicture: json['profile_picture'] ?? '',
      isVerified: json['is_verified'] ?? false,
    );
  }
}