<<<<<<< HEAD
import 'package:equatable/equatable.dart';

enum UserRole { customer, owner, admin }

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final UserRole role;
  final String? phoneNumber;
  final String? avatarUrl;

  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.phoneNumber,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, email, fullName, role, phoneNumber, avatarUrl];
}
=======
import 'package:equatable/equatable.dart';

enum UserRole { customer, owner, admin }

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String fullName;
  final UserRole role;
  final String? phoneNumber;
  final String? avatarUrl;

  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.phoneNumber,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, email, fullName, role, phoneNumber, avatarUrl];
}
>>>>>>> f0af26a1d67233fd92118103d33087d2a9916b90
