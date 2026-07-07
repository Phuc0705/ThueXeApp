import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(String email, String password);
  Future<Either<Failure, UserEntity>> register(String email, String password, String fullName, String? phone, String? idCard);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, void>> loginWithGoogle();
  Future<Either<Failure, UserEntity?>> getCurrentUser();
}
