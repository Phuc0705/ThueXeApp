import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/login_with_google_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LoginWithGoogleUseCase loginWithGoogleUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.loginWithGoogleUseCase,
    required this.getCurrentUserUseCase,
  }) : super(AuthInitial()) {
    on<CheckAuthStatus>((event, emit) async {
      emit(AuthLoading());
      final result = await getCurrentUserUseCase(NoParams());
      result.fold(
        (failure) => emit(Unauthenticated()), // Nếu không có session thì coi như chưa đăng nhập
        (user) {
          if (user != null) {
            emit(Authenticated(user));
          } else {
            emit(Unauthenticated());
          }
        },
      );
    });

    on<LoginSubmitted>((event, emit) async {
      emit(AuthLoading());
      final result = await loginUseCase(
        LoginParams(email: event.email, password: event.password),
      );
      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (user) => emit(Authenticated(user)),
      );
    });

    on<RegisterSubmitted>((event, emit) async {
      emit(AuthLoading());
      final result = await registerUseCase(
        RegisterParams(
          email: event.email,
          password: event.password,
          fullName: event.fullName,
          phoneNumber: event.phoneNumber,
          idCard: event.idCard,
        ),
      );
      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (user) => emit(Authenticated(user)),
      );
    });

    on<LoginWithGoogleRequested>((event, emit) async {
      emit(AuthLoading());
      final result = await loginWithGoogleUseCase(NoParams());
      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (_) {
          // Khi đăng nhập bằng Google thành công, trình duyệt sẽ điều hướng
          // Session sẽ được nạp lại và trigger CheckAuthStatus.
          // Tạm thời có thể không cần emit Authenticated ngay ở đây vì CheckAuthStatus sẽ xử lý.
        },
      );
    });

    on<LogoutRequested>((event, emit) {
      emit(Unauthenticated());
    });
  }
}
