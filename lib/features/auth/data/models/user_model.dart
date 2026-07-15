import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.fullName,
    required super.role,
    super.phoneNumber,
    super.idCard,
    super.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'] ?? json['fullName'] ?? '',
      role: _parseRole(json['role']),
      phoneNumber: json['phone'] ?? json['phoneNumber'],
      idCard: json['id_card'] ?? json['idCard'],
      avatarUrl: json['avatar_url'] ?? json['avatarUrl'],
    );
  }

  static UserRole _parseRole(dynamic role) {
    if (role == 'admin') return UserRole.admin;
    return UserRole.user; // Mặc định tất cả (customer, owner) đều thành user
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role.toString().split('.').last,
      'phone': phoneNumber,
      'id_card': idCard,
      'avatar_url': avatarUrl,
    };
  }
}
