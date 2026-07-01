import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserEntity>> login(String email, String password) async {
    try {
      final user = await remoteDataSource.login(email, password);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register(String email, String password, String fullName) async {
    try {
      final user = await remoteDataSource.register(email, password, fullName);
      return Right(user);
    } catch (e) {
      if (e.toString().contains('violates row-level security')) {
        return const Left(ServerFailure('Lỗi phân quyền RLS. Hãy tắt tính năng Confirm Email trong Supabase.'));
      }
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      return const Right(null);
    } catch (e) {
      return const Left(ServerFailure('Lỗi khi đăng xuất.'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final supabase = (remoteDataSource as AuthRemoteDataSourceImpl).supabase;
      final session = supabase.auth.currentSession;
      
      if (session != null && session.user != null) {
        final profile = await supabase
            .from('profiles')
            .select()
            .eq('id', session.user.id)
            .single();
        return Right(UserModel.fromJson(profile));
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Lỗi khi tải phiên đăng nhập: $e'));
    }
  }
}
