import 'package:get_it/get_it.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/domain/usecases/login_with_google_usecase.dart';
import 'features/auth/domain/usecases/get_current_user_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/car_browsing/data/datasources/car_remote_data_source.dart';
import 'features/car_browsing/data/repositories/car_repository_impl.dart';
import 'features/car_browsing/domain/repositories/car_repository.dart';
import 'features/car_browsing/domain/usecases/get_cars.dart';
import 'features/car_browsing/presentation/bloc/car_bloc.dart';
import 'features/booking/data/datasources/booking_remote_data_source.dart';
import 'features/booking/data/repositories/booking_repository_impl.dart';
import 'features/booking/domain/repositories/booking_repository.dart';
import 'features/booking/domain/usecases/create_booking.dart';
import 'features/booking/domain/usecases/get_my_bookings.dart';
import 'features/booking/domain/usecases/get_owner_bookings.dart';
import 'features/booking/domain/usecases/update_booking_status.dart';
import 'features/booking/presentation/bloc/booking_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/admin/data/datasources/admin_remote_data_source.dart';
import 'features/admin/data/repositories/admin_repository_impl.dart';
import 'features/admin/domain/repositories/admin_repository.dart';
import 'features/admin/presentation/bloc/admin_bloc.dart';
import 'features/car_browsing/data/datasources/favorite_local_data_source.dart';
import 'features/car_browsing/presentation/bloc/favorite_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! External
  sl.registerLazySingleton(() => Supabase.instance.client);

  //! Features - Auth
  sl.registerFactory(() => AuthBloc(
    loginUseCase: sl(), 
    registerUseCase: sl(),
    loginWithGoogleUseCase: sl(),
    getCurrentUserUseCase: sl(),
  ));
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LoginWithGoogleUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );

  //! Features - Car Browsing
  sl.registerFactory(() => CarBloc(getCars: sl()));
  sl.registerLazySingleton(() => GetCars(sl()));
  sl.registerLazySingleton<CarRepository>(
    () => CarRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<CarRemoteDataSource>(
    () => CarRemoteDataSourceImpl(sl()),
  );

  //! Features - Booking
  sl.registerFactory(() => BookingBloc(
        createBooking: sl(),
        getMyBookings: sl(),
        getOwnerBookings: sl(),
        updateBookingStatus: sl(),
      ));
  sl.registerLazySingleton(() => CreateBooking(sl()));
  sl.registerLazySingleton(() => GetMyBookings(sl()));
  sl.registerLazySingleton(() => GetOwnerBookings(sl()));
  sl.registerLazySingleton(() => UpdateBookingStatus(sl()));
  sl.registerLazySingleton<BookingRepository>(
    () => BookingRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<BookingRemoteDataSource>(
    () => BookingRemoteDataSourceImpl(sl()),
  );

  //! Features - Admin
  sl.registerFactory(() => AdminBloc(repository: sl()));
  sl.registerLazySingleton<AdminRepository>(
    () => AdminRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<AdminRemoteDataSource>(
    () => AdminRemoteDataSourceImpl(sl()),
  );

  //! Features - Favorite
  sl.registerFactory(() => FavoriteCubit(dataSource: sl()));
  sl.registerLazySingleton(() => FavoriteLocalDataSource());
}
