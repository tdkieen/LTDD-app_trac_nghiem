enum UserRole {
  admin,
  teacher,
  student;

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.teacher:
        return 'Giáo viên';
      case UserRole.student:
        return 'Học viên';
    }
  }

  static UserRole fromString(String? role) {
    switch (role?.toLowerCase().trim()) {
      case 'admin':
        return UserRole.admin;
      case 'teacher':
      case 'giáo viên':
      case 'giao vien':
        return UserRole.teacher;
      case 'student':
      case 'học viên':
      case 'hoc vien':
      default:
        return UserRole.student;
    }
  }
}

class AppUser {
  final String id;
  final String userName;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? avatarUrl;
  final UserRole role;
  final double diemMucTieu;
  final DateTime ngayTao;

  AppUser({
    required this.id,
    required this.userName,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.avatarUrl,
    this.role = UserRole.student,
    this.diemMucTieu = 8.0,
    DateTime? ngayTao,
  }) : ngayTao = ngayTao ?? DateTime.now();

  bool get isAdmin => role == UserRole.admin;
  bool get isTeacher => role == UserRole.teacher || role == UserRole.admin;
  bool get isStudent => role == UserRole.student;

  AppUser copyWith({
    String? id,
    String? userName,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? avatarUrl,
    UserRole? role,
    double? diemMucTieu,
    DateTime? ngayTao,
  }) {
    return AppUser(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      diemMucTieu: diemMucTieu ?? this.diemMucTieu,
      ngayTao: ngayTao ?? this.ngayTao,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userName': userName,
    'fullName': fullName,
    'email': email,
    'phoneNumber': phoneNumber,
    'avatarUrl': avatarUrl,
    'role': role.name,
    'diemMucTieu': diemMucTieu,
    'ngayTao': ngayTao.toIso8601String(),
  };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    id: json['id'] ?? '',
    userName: json['userName'] ?? '',
    fullName: json['fullName'] ?? '',
    email: json['email'] ?? '',
    phoneNumber: json['phoneNumber'],
    avatarUrl: json['avatarUrl'],
    role: UserRole.fromString(json['role']),
    diemMucTieu: (json['diemMucTieu'] as num?)?.toDouble() ?? 8.0,
    ngayTao: json['ngayTao'] != null ? DateTime.parse(json['ngayTao']) : null,
  );
}
