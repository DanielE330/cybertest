enum UserRole { teacher, student }

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.teacher:
        return 'преподаватель';
      case UserRole.student:
        return 'студент';
    }
  }

  String get apiValue {
    switch (this) {
      case UserRole.teacher:
        return 'teacher';
      case UserRole.student:
        return 'student';
    }
  }
}

UserRole userRoleFromString(String value) {
  switch (value.toLowerCase()) {
    case 'преподаватель':
    case 'teacher':
      return UserRole.teacher;
    case 'студент':
    case 'student':
      return UserRole.student;
    default:
      return UserRole.student;
  }
}

class User {
  final String username;
  final UserRole role;
  final String? id;
  final String? accessToken;

  User({
    required this.username,
    required this.role,
    this.id,
    this.accessToken,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final rawRole = json['role'] ?? json['status'] ?? 'student';

    return User(
      id: json['id']?.toString(),
      username: json['username']?.toString() ?? json['name']?.toString() ?? '',
      role: userRoleFromString(rawRole.toString()),
      accessToken: json['access_token']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'role': role.apiValue,
      'access_token': accessToken,
    };
  }

  @override
  String toString() => 'User(username: $username, role: ${role.displayName})';
}
