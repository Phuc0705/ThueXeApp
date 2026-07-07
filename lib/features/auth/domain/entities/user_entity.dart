import 'package:equatable/equatable.dart';

enum UserRole { user, admin }

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final UserRole role;
  final String? phoneNumber;
  final String? idCard;
  final String? avatarUrl;

  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.phoneNumber,
    this.idCard,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, email, fullName, role, phoneNumber, idCard, avatarUrl];
}
