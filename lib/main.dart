<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/car_browsing/presentation/bloc/car_bloc.dart';
import 'features/car_browsing/presentation/bloc/car_event.dart';
import 'features/booking/presentation/bloc/booking_bloc.dart';
import 'features/car_browsing/presentation/pages/car_list_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load biến môi trường
  try {
    await dotenv.load(fileName: ".env");
    
    // Khởi tạo Supabase
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
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
        BlocProvider(create: (_) => di.sl<CarBloc>()..add(FetchCarsEvent())),
        BlocProvider(create: (_) => di.sl<BookingBloc>()),
      ],
      child: MaterialApp(
        title: 'Thue Xe App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.grey[50],
        ),
        home: const CarListScreen(),
      ),
    );
  }
}
=======
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/car_browsing/presentation/bloc/car_bloc.dart';
import 'features/car_browsing/presentation/bloc/car_event.dart';
import 'features/booking/presentation/bloc/booking_bloc.dart';
import 'features/car_browsing/presentation/pages/car_list_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load biến môi trường
  try {
    await dotenv.load(fileName: ".env");
    
    // Khởi tạo Supabase
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
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
        BlocProvider(create: (_) => di.sl<CarBloc>()..add(FetchCarsEvent())),
        BlocProvider(create: (_) => di.sl<BookingBloc>()),
      ],
      child: MaterialApp(
        title: 'Thue Xe App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.grey[50],
        ),
        home: const CarListScreen(),
      ),
    );
  }
}
>>>>>>> f0af26a1d67233fd92118103d33087d2a9916b90
