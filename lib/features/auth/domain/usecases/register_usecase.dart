import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterParams {
  final String email;
  final String password;
  final String fullName;
  final String? phoneNumber;
  final String? idCard;

  RegisterParams({
    required this.email, 
    required this.password, 
    required this.fullName,
    this.phoneNumber,
    this.idCard,
  });
}

class RegisterUseCase implements UseCase<UserEntity, RegisterParams> {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(RegisterParams params) async {
    return await repository.register(
      params.email, 
      params.password, 
      params.fullName,
      params.phoneNumber,
      params.idCard,
    );
  }
}
