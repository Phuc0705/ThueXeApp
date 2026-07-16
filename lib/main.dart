import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/car_browsing/presentation/bloc/car_bloc.dart';
import 'features/car_browsing/presentation/bloc/car_event.dart';
import 'features/booking/presentation/bloc/booking_bloc.dart';
import 'features/admin/presentation/bloc/admin_bloc.dart';
import 'features/car_browsing/presentation/bloc/favorite_cubit.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'injection_container.dart' as di;
import 'root_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load biến môi trường
  try {
    await dotenv.load(fileName: ".env");
    
    // Khởi tạo Supabase
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      publishableKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    );
  } catch (e) {
    debugPrint("Chưa có file .env hoặc cấu hình Supabase bị thiếu.");
  }

  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthBloc>()..add(CheckAuthStatus())),
        BlocProvider(create: (_) => di.sl<CarBloc>()..add(const FetchCarsEvent())),
        BlocProvider(create: (_) => di.sl<BookingBloc>()),
        BlocProvider(create: (_) => di.sl<AdminBloc>()),
        BlocProvider(create: (_) => di.sl<FavoriteCubit>()),
      ],
      child: MaterialApp(
        title: 'Thue Xe App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4A00E0)),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
            foregroundColor: Colors.white,
          ),
          scaffoldBackgroundColor: Colors.grey[50],
        ),
        home: const RootPage(),
      ),
    );
  }
}
