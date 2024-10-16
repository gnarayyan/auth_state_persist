import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/auth_bloc.dart';
import 'bloc/auth_event.dart';
import 'services/api_service.dart';
import 'ui/home_page.dart';
import 'ui/login_page.dart';
import 'ui/otp_page.dart';
import 'ui/splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ApiService _apiService = ApiService();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(_apiService)..add(AppStarted()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/login': (context) => const LoginPage(),
          '/otp': (context) {
            final String phoneNumber =
                ModalRoute.of(context)?.settings.arguments as String;

            return OtpPage(phoneNumber: phoneNumber);
          },
          '/home': (context) => const HomePage(),
        },
      ),
    );
  }
}
